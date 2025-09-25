//
//  DatabaseManager.swift
//  SiduChat
//
//  Created by Armstrong Liu on 11/09/2025.
//

import Foundation
import SwiftData

actor DatabaseManager {
    static let shared = DatabaseManager()
    static let sharedInMemory = DatabaseManager(inMemory: true)
    
    let modelContainer: ModelContainer
    
    init(inMemory: Bool = false) {
        let schema = Schema(CurrentSchema.models, version: CurrentSchema.versionIdentifier)
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)
        
        do {
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch let error {
            fatalError("Failed to create ModelContainer: \(error.localizedDescription)")
        }
    }
    
    var topicDbHandler: TopicDbHandler {
        TopicDbHandler(container: modelContainer)
    }
    
    var chatDbHandler: ChatDbHandler {
        ChatDbHandler(container: modelContainer)
    }
    
//    let sharedModelContainer: ModelContainer = {
//        let schema = Schema(CurrentSchema.models, version: CurrentSchema.versionIdentifier)
//        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
//        
//        do {
//            return try ModelContainer(for: schema, configurations: [modelConfiguration])
//        } catch let error {
//            fatalError("Failed to create ModelContainer: \(error.localizedDescription)")
//        }
//    }()
//    
//    let inMemoryModelContainer: ModelContainer = {
//        let schema = Schema(CurrentSchema.models, version: CurrentSchema.versionIdentifier)
//        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
//        
//        do {
//            return try ModelContainer(for: schema, configurations: [modelConfiguration])
//        } catch let error {
//            fatalError("Failed to create ModelContainer for preview: \(error.localizedDescription)")
//        }
//    }()
//    
//    func createTopicDbHandler(/*inMemory: Bool = false*/) -> TopicDbHandler {
////        let container = inMemory ? inMemoryModelContainer : sharedModelContainer
//        return TopicDbHandler(container: modelContainer)
//    }
//    
//    func createChatDbHandler(/*inMemory: Bool = false*/) -> ChatDbHandler {
////        let container = inMemory ? inMemoryModelContainer : sharedModelContainer
//        return ChatDbHandler(container: modelContainer)
//    }
}
