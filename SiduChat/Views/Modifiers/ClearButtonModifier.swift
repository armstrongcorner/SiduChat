//
//  ClearButtonModifier.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 16/03/2025.
//

import SwiftUI

struct ClearButtonModifier: ViewModifier {
    @Binding var text: String
    
    func body(content: Content) -> some View {
        HStack {
            content
            
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.trailing, 5)
            }
        }
    }
}

extension View {
    func clearButton(_ text: Binding<String>) -> some View {
        modifier(ClearButtonModifier(text: text))
    }
}
