//
//  Cell.swift
//  LocalizationHelper
//
//  Created by Home on 28/09/25.
//

import SwiftUI

struct Cell: View {
    let error: String?
    let value: StringKeyValue?
    
    var body: some View {
        if let value {
            translationValueCellView(translation: value)
                .textHover(text: value.hoverString)
        } else if let error {
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
    
}
