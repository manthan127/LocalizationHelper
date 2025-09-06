//
//  TextHoverModifier.swift
//  LocalizationHelper
//
//  Created by Home on 05/09/25.
//

import SwiftUI

private struct TextHoverModifier: ViewModifier {
    @State private var showingPopover = false
    let text: String
    
    func body(content: Content) -> some View {
        content
            .popover(isPresented: $showingPopover, content: {
                Text(text)
                    .padding(10)
            })
            .onHover { hover in
                showingPopover = hover
            }
    }
}

extension View {
    func textHover(text: String) -> some View {
        self.modifier(TextHoverModifier(text: text))
    }
}
