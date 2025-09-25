//
//  TopicEntity.swift
//  SiduChat
//
//  Created by Armstrong Liu on 11/09/2025.
//

import Foundation
import SwiftData

typealias TopicEntity = SchemaV101.Topic

extension SchemaV101 {
    @Model
    final class Topic {
        @Attribute(.unique) var id: String
        var title: String
        var createTime: TimeInterval
        var selectedModel: String = ""
        var selectedModelType: String = ModelType.local.rawValue
        
        @Relationship(deleteRule: .cascade) var chats: [ChatEntity]
        
        init(
            id: String,
            title: String,
            createTime: TimeInterval,
            selectedModel: String,
            selectedModelType: String,
            chats: [ChatEntity] = []
        ) {
            self.id = id
            self.title = title
            self.createTime = createTime
            self.selectedModel = selectedModel
            self.selectedModelType = selectedModelType
            
            self.chats = chats
        }
        
        init(fromTopicMessage topicMessageModel: TopicMessage, chats: [ChatEntity] = []) {
            self.id = topicMessageModel.id
            self.title = topicMessageModel.title
            self.createTime = topicMessageModel.createTime
            self.selectedModel = topicMessageModel.selectedModel
            self.selectedModelType = topicMessageModel.selectedModelType.rawValue
            
            self.chats = chats
        }
        //    init(fromContextModel topicMessageModel: TopicMessage, user: User? = nil, chats: [Chat] = []) {
        //        self.id = topicMessageModel.id
        //        self.title = topicMessageModel.title
        //        self.createTime = topicMessageModel.createTime
        //        self.isComplete = topicMessageModel.isComplete
        //
        //        self.user = user
        //        self.chats = chats
        //    }
    }
}

extension SchemaV100 {
    @Model
    final class Topic {
        @Attribute(.unique) var id: String
        var title: String
        var createTime: TimeInterval
        
        @Relationship(deleteRule: .cascade) var chats: [ChatEntity]
        
        init(id: String, title: String, createTime: TimeInterval, chats: [ChatEntity] = []) {
            self.id = id
            self.title = title
            self.createTime = createTime
            
            self.chats = chats
        }
        
        init(fromTopicMessage topicMessageModel: TopicMessage, chats: [ChatEntity] = []) {
            self.id = topicMessageModel.id
            self.title = topicMessageModel.title
            self.createTime = topicMessageModel.createTime
            
            self.chats = chats
        }
        //    init(fromContextModel topicMessageModel: TopicMessage, user: User? = nil, chats: [Chat] = []) {
        //        self.id = topicMessageModel.id
        //        self.title = topicMessageModel.title
        //        self.createTime = topicMessageModel.createTime
        //        self.isComplete = topicMessageModel.isComplete
        //
        //        self.user = user
        //        self.chats = chats
        //    }
    }
}
