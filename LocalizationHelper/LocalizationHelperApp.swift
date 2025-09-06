//
//  LocalizationHelperApp.swift
//  LocalizationHelper
//
//  Created by Home on 31/07/25.
//

import SwiftUI
import FolderManager

@main
struct LocalizationHelperApp: App {
    var body: some Scene {
        WindowGroup {
            FolderManagerView(filter: {
                do {
                    return try $0.children().contains(where: {$0.pathExtension == .xcodeproj})
                } catch {
                    presentAlert(error: error)
                    return false
                }
            }) { url in
                ContentView(url: url)
            }
        }
    }
}
