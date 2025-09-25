//
//  SiduChatApp.swift
//  SiduChat
//
//  Created by Armstrong Liu on 29/08/2025.
//

import SwiftUI
import SwiftData

@main
struct SiduChatApp: App {
    let databaseManager = DatabaseManager.shared
    
    var body: some Scene {
        WindowGroup {
            GeometryReader { proxy in
                ChatView()
                    .environment(\.screenSize, proxy.size)
                    .environment(\.databaseManager, databaseManager)
                    .environment(ToastViewObserver())
            }
        }
//        .modelContainer(databaseManager.modelContainer)
    }
}
