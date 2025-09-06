//
//  ContentView.swift
//  LocalizationHelper
//
//  Created by Home on 31/07/25.
//

import SwiftUI

struct ContentView: View {
    let url: URL
    
    @State private var langs: [String] = []
    @State private var loading = false
    @AppStorage("apiKey") private var apiKey: String = ""
    
    @State private var stringCatalogs: [StringCatalogModel] = []
    @State private var selectedInd = 0
    var selected: StringCatalogModel {
        get {
            stringCatalogs[selectedInd]
        }
    }
    @State private var errors: [String: [String: String]] = [:]
    
    var body: some View {
//            NavigationSplitView {
//                List(stringCatalogWriter, id: \.url.absoluteString, selection: $selected) { url in
//                    Text(url.url.lastPathComponent)
//                }
//            } detail: {
        VStack {
            HStack( content: {
                TextField("Enter Google API Key here", text: $apiKey)
                Button("Paste") {
                    if let clipboardText = NSPasteboard.general.string(forType: .string) {
                        apiKey = clipboardText
                    }
                }
            })
            .padding()
            
            if !stringCatalogs.isEmpty {
                ExcelTableView(
                    columnHeaders: langs,
                    rowHeaders: selected.strings,
                    cellContent: cellView,
                    columnMenu: langsMenu(lang:),
                    rowMenu: stringsMenu(string:)
                )
                
                buttonsView
            }
            else {
                Text("Couldn't get the strings file")
                    .frame(maxHeight: .infinity)
            }
        }
        .frame(minWidth: 500, minHeight: 400)
//                }
        .padding()
        .task{ await fetchURLData() }
    }
}

// MARK: - Views
private extension ContentView {
    // MARK: - Cell Views
    @ViewBuilder
    func cellView(string: String, lang: String) -> some View {
        if let translation = selected[string, lang] {
            translationValueCellView(translation: translation)
                .textHover(text: translation.hoverString)
        } else if let error = errors[string]?[lang] {
            Image(systemName: "xmark")
                .textHover(text: error)
        } else {
            Color.clear
        }
    }
    
    @ViewBuilder
    func translationValueCellView(translation: StringKeyValue) -> some View {
        let image = switch translation {
        case .translated: "checkmark.circle.fill"
        case .shouldTranslate: "checkmark.circle.badge.xmark"
        }
        
        Image(systemName: image)
    }
    
    // MARK: - Menu View
    @ViewBuilder
    func stringsMenu(string: String) -> some View {
        Button("translate \(string)") {
            traslate(string: string)
        }
    }
    
    @ViewBuilder
    func langsMenu(lang: String) -> some View {
        Button("translate \(lang)") {
            traslate(lang: lang)
        }
    }
    
    // MARK: - Buttons view
    var buttonsView: some View {
        HStack {
            Button("Translate Selected File", action: translateTap)
            Button("Save", action: save)
        }
    }
}

// MARK: - Functions
private extension ContentView {
    // MARK: - on appear
    func fetchURLData() async {
        guard url.startAccessingSecurityScopedResource() else {return}
        defer { url.stopAccessingSecurityScopedResource() }
        
        if let (stringCatalogWriter, langs) = await StringsFilesHandler.shared.startFetching(url) {
            (self.stringCatalogs, self.langs) = (stringCatalogWriter, langs)
        } else {
            presentAlert(message: "Please select a project folder")
        }
    }
    
    // MARK: - button clicks
    func translateTap() {
        let strings = selected.strings
        let sourceLanguage = selected.sourceLanguage
        
        Task {
            await withTaskGroup(of: Void.self) { group in
                for lang in langs {
                    for string in strings where selected[string, lang] == nil {
                        group.addTask {
                            await callAPI(string: string, lang: lang, sourceLanguage: sourceLanguage)
                        }
                    }
                }
            }
        }
    }
    
    func traslate(lang: String) {
        let strings = selected.strings
        let sourceLanguage = selected.sourceLanguage
        Task {
            await withTaskGroup(of: Void.self) { group in
                for string in strings where selected[string, lang] == nil {
                    group.addTask {
                        await callAPI(string: string, lang: lang, sourceLanguage: sourceLanguage)
                    }
                }
            }
        }
    }
    
    func traslate(string: String) {
        let sourceLanguage = selected.sourceLanguage
        Task {
            await withTaskGroup(of: Void.self) { group in
                for lang in langs where selected[string, lang] == nil {
                    group.addTask {
                        await callAPI(string: string, lang: lang, sourceLanguage: sourceLanguage)
                    }
                }
            }
        }
    }
    
    func save() {
        do {
            try selected.save()
        } catch {
            presentAlert(error: error)
        }
    }
}

private extension ContentView {
    func callAPI(string: String, lang: String, sourceLanguage: String) async {
        do {
            if let translation = try await translateText(originalText: string, sourceLanguage: sourceLanguage, targetLanguage: lang) {
                await MainActor.run {
                    self.stringCatalogs[selectedInd][string, lang] = .translated(translation)
                }
            } else {
                await MainActor.run {
                    self.errors[string]?[lang] = "api changed"
                }
            }
        } catch {
            await MainActor.run {
                self.errors[string]?[lang] = error.localizedDescription
            }
        }
    }
}

#Preview {
    ContentView(url: URL(string: "/Users/home/Desktop/macOS/LocalizationHelper")!)
}


#if DEBUG
let isPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
#else
let isPreview = false
#endif
