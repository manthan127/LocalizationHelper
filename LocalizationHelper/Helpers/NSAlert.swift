//
//  View.swift
//  LocalizationHelper
//
//  Created by Home on 05/09/25.
//

import AppKit

func presentAlert(message: String) {
    DispatchQueue.main.async {
        let alert = NSAlert()
        alert.messageText = message
        alert.addButton(withTitle: "Ok")
        
        alert.runModal()
    }
}

func presentAlert(error: Error) {
    DispatchQueue.main.async {
        let alert = NSAlert(error: error)
        alert.addButton(withTitle: "Ok")
        
        alert.runModal()
    }
}
