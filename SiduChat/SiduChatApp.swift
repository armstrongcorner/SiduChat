//
//  SiduChatApp.swift
//  SiduChat
//
//  Created by Armstrong Liu on 29/08/2025.
//

import SwiftUI

@main
struct SiduChatApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
