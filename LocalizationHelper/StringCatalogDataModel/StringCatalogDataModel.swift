//
//  StringCatalogDataModel.swift
//  LocalizationHelper
//
//  Created by Home on 30/08/25.
//

import Foundation

// MARK: - below model are not used, they are only to get a reference on what data looks like
// MARK: - not usnig this models because some data might be removed if any key is forgotten in model
struct Root: Codable {
    let sourceLanguage: String
    let version: String
    var strings: [String: LocalizedString]
}

struct LocalizedString: Codable {
    let extractionState: String?
    var localizations: [String: LocalizationEntry]?

    enum CodingKeys: String, CodingKey {
        case extractionState
        case localizations
    }
}

struct LocalizationEntry: Codable {
    let stringUnit: StringUnit
}

struct StringUnit: Codable {
    let state: String?
    let value: String?
}
