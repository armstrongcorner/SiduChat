//
//  ChatEntity.swift
//  SiduChat
//
//  Created by Armstrong Liu on 11/09/2025.
//

import Foundation
import SwiftData

typealias ChatEntity = SchemaV101.Chat

extension SchemaV101 {
    @Model
    final class Chat {
        @Attribute(.unique) var id: String
        var role: ChatRole
        var content: String
        var createTime: TimeInterval
        
        var topic: TopicEntity?
        
        init(id: String, role: ChatRole, content: String, createTime: TimeInterval, topic: TopicEntity? = nil) {
            self.id = id
            self.role = role
            self.content = content
            self.createTime = createTime
            
            self.topic = topic
        }
        
        init(fromChatMessage chatMessageModel: ChatMessage, topic: TopicEntity? = nil) {
            self.id = chatMessageModel.id
            self.role = chatMessageModel.role
            self.content = chatMessageModel.content
            self.createTime = chatMessageModel.createTime
            
            self.topic = topic
        }
    }
}

extension SchemaV100 {
    @Model
    final class Chat {
        @Attribute(.unique) var id: String
        var role: ChatRole
        var content: String
        var createTime: TimeInterval
        
        var topic: TopicEntity?
        
        init(id: String, role: ChatRole, content: String, createTime: TimeInterval, topic: TopicEntity? = nil) {
            self.id = id
            self.role = role
            self.content = content
            self.createTime = createTime
            
            self.topic = topic
        }
        
        init(fromChatMessage chatMessageModel: ChatMessage, topic: TopicEntity? = nil) {
            self.id = chatMessageModel.id
            self.role = chatMessageModel.role
            self.content = chatMessageModel.content
            self.createTime = chatMessageModel.createTime
            
            self.topic = topic
        }
    }
}
