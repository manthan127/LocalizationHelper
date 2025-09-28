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
//            NavigationSplitView {
//                List(stringCatalogs, id: \.url.absoluteString, selection: $selected) { url in
//                    Text(url.url.lastPathComponent)
//                }
//            } detail: {
        VStack {
            if !vm.stringCatalogs.isEmpty {
                ExcelTableView(
                    columnHeaders: vm.langs,
                    rowHeaders: vm.selected.strings,
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
        .task{ await vm.fetchURLData(url: url) }
    }
}

// MARK: - Views
private extension ContentView {
    // MARK: - Cell Views
    func cellView(string: String, lang: String) -> some View {
        Cell(error: vm.errors[string]?[lang], value: vm.selected[string, lang])
    }
    
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
                await vm.traslate(lang: lang)
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
