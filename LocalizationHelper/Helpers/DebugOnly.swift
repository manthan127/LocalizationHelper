//
//  File.swift
//  LocalizationHelper
//
//  Created by Home on 28/09/25.
//

import Foundation

#if DEBUG
let isPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
#else
let isPreview = false
#endif

func prettyPrint(dictionary: [String: Any]) {
#if DEBUG
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            print(jsonString)
        } else {
            print("Error: Could not convert JSON data to string.")
        }
    } catch {
        print("Error pretty printing dictionary: \(error.localizedDescription)")
    }
#endif
}
