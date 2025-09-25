//
//  SideMenuView.swift
//  SiduChat
//
//  Created by Armstrong Liu on 10/09/2025.
//

import SwiftUI

struct SideMenuView<Content>: View where Content: View {
    @Binding var showSideMenu: Bool
    
    let content: Content
    
    init(
        _ showSideMenu: Binding<Bool>,
        @ViewBuilder content: () -> Content
    ) {
        _showSideMenu = showSideMenu
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                if showSideMenu {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showSideMenu = false
                        }
                    
                    content
                        .transition(.move(edge: .leading))
                        .frame(width: proxy.size.width * 2 / 3)
                        .background(.white)
                }
            }
            .animation(.easeInOut, value: showSideMenu)
        }
    }
}

#Preview {
    SideMenuView(.constant(true)) {
        List {
            ForEach(0..<50) {
                Text("index: \($0)")
            }
        }
        .listStyle(.plain)
    }
}
