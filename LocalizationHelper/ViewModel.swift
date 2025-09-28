//
//  ViewModel.swift
//  LocalizationHelper
//
//  Created by Home on 28/09/25.
//

import Foundation

final class ViewModel: ObservableObject {
    
    @Published var langs: [String] = []
    @Published var loading = false
    
    @Published var stringCatalogs: [StringCatalogModel] = []
    @Published var selectedInd = 0
    var selected: StringCatalogModel {
        get {
            stringCatalogs[selectedInd]
        } set {
            stringCatalogs[selectedInd] = newValue
        }
    }
    
    @Published var errors: [String: [String: String]] = [:]
    
    var strings: [String] { selected.strings }
    var sourceLanguage: String { selected.sourceLanguage }
    
    func fetchURLData(url: URL) async {
        guard url.startAccessingSecurityScopedResource() else {return}
        defer { url.stopAccessingSecurityScopedResource() }
        
        if let (stringCatalogWriter, langs) = await StringsFilesFinder.shared.startFetching(url) {
            await MainActor.run {
                (self.stringCatalogs, self.langs) = (stringCatalogWriter, langs)
            }
        } else {
            presentAlert(message: "Please select a project folder")
        }
    }
}

extension ViewModel {
    // MARK: - button clicks
    func translateTap() {
        Task {
            await withTaskGroup(of: Void.self) { group in
                for lang in langs {
                    group.addTask {
                        await self.traslate(lang: lang)
                    }
                }
            }
        }
    }
    
    func save(url: URL) {
        do {
            guard url.startAccessingSecurityScopedResource() else {
                throw URLError(.noPermissionsToReadFile)
            }
            defer {
                url.stopAccessingSecurityScopedResource()
            }
            
            try selected.save()
        } catch {
            presentAlert(error: error)
        }
    }
    
    func traslate(lang: String) async {
        let strings = strings.filter { selected[$0, lang] == nil }
        await callAPI(strings: strings, lang: lang, sourceLanguage: sourceLanguage)
    }
    
    func traslate(string: String) {
        Task {
            await withTaskGroup(of: Void.self) { group in
                for lang in langs where selected[string, lang] == nil {
                    group.addTask {
                        await self.callAPI(strings: [string], lang: lang, sourceLanguage: self.sourceLanguage)
                    }
                }
            }
        }
    }
}

extension ViewModel {
    func callAPI(strings: [String], lang: String, sourceLanguage: String) async {
        do {
            if let translations = try await translateText(originalText: strings, sourceLanguage: sourceLanguage, targetLanguage: lang) {
                await MainActor.run {
                    for (string, translation) in zip(strings, translations) {
                        self.selected[string, lang] = .translated(translation)
                    }
                }
            } else {
                await MainActor.run {
                    for string in strings {
                        self.errors[string] = [lang : "api changed"]
                    }
                }
            }
        } catch {
            await MainActor.run {
                for string in strings {
                    self.errors[string] = [lang : error.localizedDescription]
                }
            }
        }
    }
}
