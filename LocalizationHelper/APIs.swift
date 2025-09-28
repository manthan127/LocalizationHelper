//
//  APIs.swift
//  LocalizationHelper
//
//  Created by Home on 06/09/25.
//

import Foundation

// TODO: - make proper models for API response

// TODO: - DO some thing about key or ask from user
// TODO: - API can handle multiple strings

let v2BaseURL = "https://translation.googleapis.com/language/translate/v2"

enum APIEndPoint {
    case transLate(originalTexts: [String], sourceLanguage: String, targetLanguage: String)
    case languageList
    
    var httpMethod: String {
        switch self {
        case .transLate: "POST"
        case .languageList: "GET"
        }
    }
    
    var endPoint: String {
        switch self {
        case .transLate: ""
        case .languageList: "/languages"
        }
    }
    
    var body: [String: Any]? {
        switch self {
        case .transLate(let originalText, let sourceLanguage, let targetLanguage):
            [
                "q": originalText,
                "source": sourceLanguage,
                "target": targetLanguage,
                "format": "text"
            ]
        case .languageList: nil
        }
    }
}

func makeUrlRequest(endPoint: APIEndPoint) throws -> URLRequest {
    let url = URL(string: v2BaseURL)?.appending(path: endPoint.endPoint).appending(queryItems: [
        .init(name: "key", value: PrivateKeys.googleKey)
    ])
    
    guard let url = url else { throw URLError(.badURL) }
    var request = URLRequest(url: url)
    request.httpMethod = endPoint.httpMethod
    
    request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer " + PrivateKeys.googleAccessToken, forHTTPHeaderField: "Authorization")
    request.setValue(PrivateKeys.googleProjectID, forHTTPHeaderField: "x-goog-user-project")
    
    if let body = endPoint.body {
        let bodyData = try? JSONSerialization.data(withJSONObject: body)
        request.httpBody = bodyData
    }
    
    return request
}

// TODO: - assuming API's response will be the same size of array as input
func translateText(originalText: [String], sourceLanguage: String, targetLanguage: String) async throws -> [String]? {
//    try await Task.sleep(for: .seconds(Double.random(in: 0...5)))
    
    let r = Int.random(in: 1...2)
    switch r {
    case 0: 
        return nil
    case 1:
        throw URLError(.badURL)
    default:
        return originalText.map{ $0 + "< mark Translated>" }
    }
    
////    POST https://translation.googleapis.com/v3/projects/PROJECT_NUMBER_OR_ID:translateText
//    let request = try makeUrlRequest(endPoint: .transLate(originalTexts: originalText, sourceLanguage: sourceLanguage, targetLanguage: targetLanguage))
//    
//    let (data, _) = try await URLSession.shared.data(for: request)
//    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
//       let data = json["data"] as? [String: Any],
//       let translations = data["translations"] as? [[String: Any]],
//       let translatedText = translations.first?["translatedText"] as? String {
//        return translatedText
//    }
//    return nil
}

// TODO: - call this api before fetching details of file or project and store the value in global
func getAvailableLanguages() async throws -> [String] {
    let urlString = v2BaseURL + "/languages"
    guard let url = URL(string: urlString) else { throw URLError(.badURL) }
    
    let (data, _) = try await URLSession.shared.data(from: url)
    
    let dataDecoded = try JSONDecoder().decode(LanguageListRes.self, from: data)
    return dataDecoded.languages.map({$0.language})
}


struct LanguageListRes: Decodable {
    let languages: [Language]
    struct Language: Decodable {
        let language: String
    }
}
