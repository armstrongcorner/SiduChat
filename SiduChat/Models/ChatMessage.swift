//
//  ChatMessage.swift
//  SiduChat
//
//  Created by Armstrong Liu on 01/09/2025.
//

import Foundation

enum ChatRole: String, Codable {
    case user = "user"
    case assistant = "assistant"
    case thinking = "thinking"
}

struct ChatMessage: Identifiable, Hashable {
    let id: String
    let role: ChatRole
    var content: String
    let createTime: TimeInterval
    
    init(
        id: String = UUID().uuidString,
        role: ChatRole,
        content: String,
        createTime: TimeInterval = Date().timeIntervalSince1970
    ) {
        self.id = id
        self.role = role
        self.content = content
        self.createTime = createTime
    }
    
    func toPrompt() -> String {
        let prompt: String
        
        switch role {
        case .user:
            prompt = "<|user|>\(content)"
        case .assistant:
            prompt = "<|assistant|>\(content)"
        default:
            prompt = ""
        }
        
        return prompt
    }
}
