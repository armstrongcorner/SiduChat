//
//  TopicViewModel.swift
//  SiduChat
//
//  Created by Armstrong Liu on 10/09/2025.
//

import Foundation

//@MainActor
//protocol TopicViewModelProtocol: ObservableObject {
//    var showSideMenu: Bool { get set }
//    var showSwitchModel: Bool { get set }
//    var topicMessages: [TopicMessage] { get set }
////    var selectedTopic: TopicMessage? { get set }
//    var showLastChat: Bool { get set }
//
//    func getTopics() async
//    func deleteTopic(topicId: String) async -> Bool
//}
//
//@MainActor
//final class TopicViewModel: TopicViewModelProtocol {
//    @Published var showSideMenu: Bool
//    @Published var showSwitchModel: Bool
//    @Published var topicMessages: [TopicMessage]
////    @Published var selectedTopic: TopicMessage?
//    @Published var showLastChat: Bool
//    
//    private var databaseManager: DatabaseManager
//    
//    init(
//        databaseManager: DatabaseManager = DatabaseManager.shared,
//        showSideMenu: Bool = false,
//        showSwitchModel: Bool = false,
//        topicMessages: [TopicMessage] = [],
////        selectedTopic: TopicMessage? = nil,
//        showLastChat: Bool = false
//    ) {
//        self.databaseManager = databaseManager
//        self.showSideMenu = showSideMenu
//        self.showSwitchModel = showSwitchModel
//        self.topicMessages = topicMessages
////        self.selectedTopic = selectedTopic
//        self.showLastChat = showLastChat
//    }
//    
//    func getTopics() async {
//        let topicDbHandler = await databaseManager.topicDbHandler
//        do {
//            topicMessages = try await topicDbHandler.fetchTopics()
//        } catch let error {
//            print("Fetch topic error: \(error.localizedDescription)")
//        }
//    }
//    
//    func deleteTopic(topicId: String) async -> Bool {
//        let topicDbHandler = await databaseManager.topicDbHandler
//        do {
//            try await topicDbHandler.deleteTopic(topicMessageId: topicId)
//            return true
//        } catch let error {
//            print("Delete topic error: \(error.localizedDescription)")
//        }
//        
//        return false
//    }
//}

@MainActor
protocol TopicViewModelProtocol: ObservableObject {
    var showSideMenu: Bool { get set }
    var showSwitchModel: Bool { get set }
    var topicMessages: [TopicMessage] { get set }
    var selectedTopic: TopicMessage? { get set }
    var showLastChat: Bool { get set }

    func getTopics() async
    func deleteTopic(topicId: String) async -> Bool
}

@MainActor
final class TopicViewModel: TopicViewModelProtocol {
    @Published var showSideMenu: Bool
    @Published var showSwitchModel: Bool
    @Published var topicMessages: [TopicMessage]
    @Published var selectedTopic: TopicMessage?
    @Published var showLastChat: Bool
    
    private var databaseManager: DatabaseManager
    
    init(
        databaseManager: DatabaseManager = DatabaseManager.shared,
        showSideMenu: Bool = false,
        showSwitchModel: Bool = false,
        topicMessages: [TopicMessage] = [],
        selectedTopic: TopicMessage? = nil,
        showLastChat: Bool = false
    ) {
        self.databaseManager = databaseManager
        self.showSideMenu = showSideMenu
        self.showSwitchModel = showSwitchModel
        self.topicMessages = topicMessages
        self.selectedTopic = selectedTopic
        self.showLastChat = showLastChat
    }
    
    func getTopics() async {
        let topicDbHandler = await databaseManager.topicDbHandler
        do {
            topicMessages = try await topicDbHandler.fetchTopics()
        } catch let error {
            print("Fetch topic error: \(error.localizedDescription)")
        }
    }
    
    func deleteTopic(topicId: String) async -> Bool {
        let topicDbHandler = await databaseManager.topicDbHandler
        do {
            try await topicDbHandler.deleteTopic(topicMessageId: topicId)
            return true
        } catch let error {
            print("Delete topic error: \(error.localizedDescription)")
        }
        
        return false
    }
}
