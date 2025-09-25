//
//  TopicDbHandler.swift
//  SiduChat
//
//  Created by Armstrong Liu on 12/09/2025.
//

import Foundation
import SwiftData

@ModelActor
actor TopicDbHandler {
    private var context: ModelContext { modelExecutor.modelContext }
    
    init(container: ModelContainer) {
        self.modelContainer = container
        self.modelExecutor = DefaultSerialModelExecutor(modelContext: ModelContext(container))
    }
    
    @discardableResult
    func insertTopic(_ data: TopicMessage) throws -> String {
        let topicEntity = TopicEntity(fromTopicMessage: data)
        
        context.insert(topicEntity)
        try save()
        
        return topicEntity.id
    }
    
    func fetchTopics() throws -> [TopicMessage] {
        let fetchDescriptor = FetchDescriptor<TopicEntity>(
            sortBy: [SortDescriptor(\.createTime, order: .reverse)]
        )
        let topicEntities = try context.fetch(fetchDescriptor)
        
        return topicEntities.map { topic in
            TopicMessage(
                id: topic.id,
                title: topic.title,
                createTime: topic.createTime,
                selectedModel: topic.selectedModel,
                selectedModelType: ModelType(rawValue: topic.selectedModelType) ?? .local
            )
        }
    }
    
    func updateTopic(_ data: TopicMessage) throws {
        let topicId = data.id
        let fetchDescriptor = FetchDescriptor<TopicEntity>(
            predicate: #Predicate { $0.id == topicId }
        )
        let topicEntities = try context.fetch(fetchDescriptor)
        if let topicToUpdate = topicEntities.first {
            topicToUpdate.title = data.title
            topicToUpdate.selectedModel = data.selectedModel
            topicToUpdate.selectedModelType = data.selectedModelType.rawValue
            topicToUpdate.createTime = data.createTime
            
            try save()
        }
    }
    
    func deleteTopic(id: PersistentIdentifier) throws {
        guard let topic = self[id, as: TopicEntity.self] else { return }
        
        context.delete(topic)
        try save()
    }
    
    func deleteTopic(topicMessageId: String) throws {
        let fetchDescriptor = FetchDescriptor<TopicEntity>(
            predicate: #Predicate { $0.id == topicMessageId }
        )
        let topicEntities = try context.fetch(fetchDescriptor)
        if let topicToDelete = topicEntities.first {
            context.delete(topicToDelete)
            try save()
        }
    }
    
    private func save() throws {
        if context.hasChanges {
            try context.save()
        }
    }
}
