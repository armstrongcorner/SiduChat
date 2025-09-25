//
//  TopicMessage.swift
//  SiduChat
//
//  Created by Armstrong Liu on 12/09/2025.
//

import Foundation

enum ModelType: String {
    case local = "local"
    case remote = "remote"
}

struct TopicMessage: Identifiable, Hashable {
    let id: String
    let title: String
    let createTime: TimeInterval
    var selectedModel: String
    var selectedModelType: ModelType
    
    init(
        id: String = UUID().uuidString,
        title: String,
        createTime: TimeInterval = Date().timeIntervalSince1970,
        selectedModel: String,
        selectedModelType: ModelType
    ) {
        self.id = id
        self.title = title
        self.createTime = createTime
        self.selectedModel = selectedModel
        self.selectedModelType = selectedModelType
    }
}
