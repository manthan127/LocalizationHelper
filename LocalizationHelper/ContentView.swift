//
//  ContentView.swift
//  LocalizationHelper
//
//  Created by Home on 31/07/25.
//

import SwiftUI

struct ContentView: View {
    let url: URL
    @StateObject var vm = ViewModel()
    
    var body: some View {
        NavigationSplitView {
            List(vm.stringCatalogs, id: \.self, selection: $vm.selected) { url in
                Text(url.url.lastPathComponent)
            }
        } detail: {
            content
        }
        .padding()
        .task{ await vm.fetchURLData(url: url) }
    }
    
    private var content: some View {
        VStack {
            if let selected = vm.selected {
                ExcelTableView(
                    columnHeaders: vm.langs,
                    rowHeaders: selected.strings,
                    cellContent: { string, lang in
                        Cell(error: vm.errors[string]?[lang], value: selected[string, lang])
                    },
                    columnMenu: langsMenu(lang:),
                    rowMenu: stringsMenu(string:)
                )
                
                buttonsView
            } else {
                Text("Couldn't get the strings file")
                    .frame(maxHeight: .infinity)
            }
        }
        .frame(minWidth: 500, minHeight: 400)
    }
}

// MARK: - Views
private extension ContentView {
    // MARK: - Cell Views
    func translationValueCellView(translation: StringKeyValue) -> some View {
        let image = switch translation {
        case .translated: "checkmark.circle.fill"
        case .shouldTranslate: "checkmark.circle.badge.xmark"
        }
        
        return Image(systemName: image)
    }
    
    // MARK: - Menu View
    @ViewBuilder
    func stringsMenu(string: String) -> some View {
        Button("translate \(string)") {
            vm.traslate(string: string)
        }
    }
    
    @ViewBuilder
    func langsMenu(lang: String) -> some View {
        Button("translate \(lang)") {
            Task {
                await vm.traslate(lang: lang, stringCatalog: nil)
            }
        }
    }
    
    // MARK: - Buttons view
    var buttonsView: some View {
        HStack {
            Button("Translate Selected File", action: vm.translateTap)
            Button("Save", action: {
                vm.save(url: url)
            })
        }
    }
}

#Preview {
    ContentView(url: URL(string: "/Users/home/Desktop/macOS/LocalizationHelper")!)
}
