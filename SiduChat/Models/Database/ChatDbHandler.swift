//
//  ChatDbHandler.swift
//  SiduChat
//
//  Created by Armstrong Liu on 12/09/2025.
//

import Foundation
import SwiftData

@ModelActor
actor ChatDbHandler {
    private var context: ModelContext { modelExecutor.modelContext }
    
    init(container: ModelContainer) {
        self.modelContainer = container
        self.modelExecutor = DefaultSerialModelExecutor(modelContext: ModelContext(container))
    }
    
    @discardableResult
    func insertChat(_ data: ChatMessage, topicId: String) throws -> PersistentIdentifier {
        let chatEntity = ChatEntity(fromChatMessage: data)
        let fetchDescriptor = FetchDescriptor<TopicEntity>(
            predicate: #Predicate { $0.id == topicId }
        )
        let topicEntities = try context.fetch(fetchDescriptor)
        
        chatEntity.topic = topicEntities.first
        
        context.insert(chatEntity)
        try save()
        
        return chatEntity.persistentModelID
    }
    
    func batchInsertChat(_ data: [ChatMessage], topicId: String) throws {
        let fetchDescriptor = FetchDescriptor<TopicEntity>(
            predicate: #Predicate { $0.id == topicId }
        )
        let topicEntities = try context.fetch(fetchDescriptor)
        
        for chatMessage in data {
            let chatEntity = ChatEntity(fromChatMessage: chatMessage, topic: topicEntities.first)
            context.insert(chatEntity)
        }
        
        try save()
    }
    
    func fetchChats(byTopicId topicId: String) throws -> [ChatMessage] {
        let fetchDescriptor = FetchDescriptor<ChatEntity>(
            predicate: #Predicate { $0.topic?.id == topicId },
            sortBy: [SortDescriptor(\.createTime, order: .forward)]
        )
        let chatEntities = try context.fetch(fetchDescriptor)
        
        return chatEntities.map { chat in
            let chatMsg = ChatMessage(
                id: chat.id,
                role: chat.role,
                content: chat.content,
                createTime: chat.createTime
            )
            return chatMsg
        }
    }
    
    private func save() throws {
        if context.hasChanges {
            try context.save()
        }
    }
}
