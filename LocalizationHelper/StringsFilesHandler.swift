//
//  FilesHandler.swift
//  ReduceProjectSize
//
//  Created by Home on 29/01/25.
//

import Foundation

//grep -oE '[^ ]+\.swift' ReduceProjectSize.xcodeproj/project.pbxproj | sort -u | wc -l
final class StringsFilesHandler {
    static var shared: StringsFilesHandler {
        StringsFilesHandler()
    }
    
    //TODO: - handle the error properly instead of using `try?`
     func startFetching(_ urls: URL) async -> ([StringCatalogModel], [String])? {
         guard let xcodeproj = try? urls.children().first(where: {$0.pathExtension == .xcodeproj}),
                let pbxproj = try? xcodeproj.children().first(where: {$0.pathExtension == .pbxproj}),
               var langs = try? extractKnownRegions(from: pbxproj)
         else {
             return nil
         }
         
         let catalogs = startFetchingFiles(for: urls).compactMap{ try? StringCatalogModel(url: $0) }
         
         // removing source language assuming that there is same source language in every file
         let sourceLang = catalogs.first?.sourceLanguage.lowercased()
         langs.removeAll(where: {
             let l = $0.lowercased()
             return l == "base" || l == sourceLang
         })
         
         return (catalogs, langs)
    }
}

private extension StringsFilesHandler {
    func extractKnownRegions(from filePath: URL) throws -> [String]? {
        let content = try String(contentsOf: filePath, encoding: .utf8)
        
        // Look for "knownRegions = (" pattern
        guard let rangeStart = content.range(of: "knownRegions = (") else { return nil}
        
        let afterStart = content[rangeStart.upperBound...]
        guard let rangeEnd = afterStart.range(of: ");") else { return nil}
        
        let regionList = afterStart[..<rangeEnd.lowerBound]
        
        // Split by lines and clean up
        let lines = regionList.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && !$0.hasPrefix("//") } // skip comments if any
            .map { $0.trimmingCharacters(in: CharacterSet(charactersIn: ",\"")) }
        
        return lines
    }
    
    func startFetchingFiles(for fileURL: URL)-> [URL] {
        switch fileURL.pathExtension {
        case .xcstrings: [fileURL]
        default:
            if fileURL.hasDirectoryPath, let urls = try? fileURL.children(options: [.skipsHiddenFiles, .skipsPackageDescendants]).flatMap({ startFetchingFiles(for: $0) }) {
                urls
            } else {
                []
            }
        }
    }
}

func translateText(originalText: String, sourceLanguage: String, targetLanguage: String) async throws -> String? {
    let urlString = "https://translation.googleapis.com/language/translate/v2?key=..."
    guard let url = URL(string: urlString) else { throw URLError(.badURL) }
    
    let body: [String: Any] = [
        "q": originalText,
        "source": sourceLanguage,
        "target": targetLanguage,
        "format": "text"
    ]
    let bodyData = try? JSONSerialization.data(withJSONObject: body)
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = bodyData
    
    let (data, _) = try await URLSession.shared.data(for: request)
    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
       let data = json["data"] as? [String: Any],
       let translations = data["translations"] as? [[String: Any]],
       let translatedText = translations.first?["translatedText"] as? String {
        return translatedText
    } else {
        return nil
    }
}
