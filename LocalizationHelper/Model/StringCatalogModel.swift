//
//  StringCatalogModel.swift
//  LocalizationHelper
//
//  Created by Home on 30/08/25.
//

import Foundation
import AppKit

enum StringKeyValue {
    case translated(String)
    case shouldTranslate(Bool)
    
    var hoverString: String {
        switch self {
        case .translated(let string): string
        case .shouldTranslate: "Translate this text, no need there is."
        }
    }
}

struct StringCatalogModel: Hashable {
    static func == (lhs: StringCatalogModel, rhs: StringCatalogModel) -> Bool {
        lhs.url == rhs.url
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }
    
    var data: [String: Any]
    
    let sourceLanguage: String
    let strings: [String]
    let url: URL
    
    init?(url: URL) throws {
        let data = try Data(contentsOf: url)
        guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let sourceLanguage = dict["sourceLanguage"] as? String,
              let strings = (dict["strings"] as? [String: Any])?.keys else {
            return nil
        }
        
        self.data = dict
        self.sourceLanguage = sourceLanguage
        self.strings = Array(strings)
        self.url = url
    }
    
    subscript(key: String, lang: String) -> StringKeyValue? {
        get {
            let stringDict = (data["strings"] as? [String: Any])?[key] as? [String: Any]
            
            if stringDict?["shouldTranslate"] as? Bool == false {
                return .shouldTranslate(false)
            }
            
            guard let translation = (((
                stringDict?["localizations"] as? [String: Any]
            )?[lang] as? [String: Any]
            )?["stringUnit"] as? [String: String]
            )?["value"] else {
                return nil
            }
            
            return .translated(translation)
        }
        set {
            var strings = data["strings"] as? [String: Any] ?? [:]
            var stringDict = strings[key] as? [String: Any] ?? [:]
            
            switch newValue {
            case .shouldTranslate(let shouldTranslate):
                if shouldTranslate {
                    stringDict["shouldTranslate"] = nil
                } else {
                    stringDict["shouldTranslate"] = false
                }
            case .translated(let string):
                // ✅ Ensure we preserve or initialize the `localizations` key
                var localizations = stringDict["localizations"] as? [String: Any] ?? [:]
                var langDict = localizations[lang] as? [String: Any] ?? [:]
                var stringUnit = langDict["stringUnit"] as? [String: String] ?? [:]
                
                stringUnit["value"] = string
                stringUnit["state"] = "translated"
                
                langDict["stringUnit"] = stringUnit
                localizations[lang] = langDict
                stringDict["localizations"] = localizations
            case nil: break
            }
            
            strings[key] = stringDict
            data["strings"] = strings
        }
    }
}

extension StringCatalogModel {
    func save() throws {
        let data = try JSONSerialization.data(withJSONObject: data)
        try data.write(to: url)
    }
}

// TODO: Handle diffrence in diffrent device
//"Translate Selected File" : {
//  "localizations" : {
//    "ko" : {
//      "variations" : {
//        "device" : {
//          "ipod" : {
//            "stringUnit" : {
//              "state" : "needs_review",
//              "value" : "wefasdvzsdfhb "
//            }
//          },
//          "other" : {
//            "stringUnit" : {
//              "state" : "translated",
//              "value" : "wefasdvzsdfhb "
//            }
//          }
//        }
//      }
//    }
//  }
//}
