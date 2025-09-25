//
//  ChatViewModel.swift
//  SiduChat
//
//  Created by Armstrong Liu on 31/08/2025.
//

import Foundation
import Combine

@MainActor
protocol ChatViewModelProtocol: ObservableObject {
    var showModelSettings: Bool { get set }
    var inputText: String { get set }
    var inputValid: Bool { get }
    var chatHistory: [ChatMessage] { get }
    
    func initializeLlama(modelPath: String, contextSize: Int)
    func clearChat()
    func sendChat<TopicVM: TopicViewModelProtocol>(withTopicVM topicVM: TopicVM) async
    func send() async
    func getChats(byTopicId topicId: String) async
}

@MainActor
final class ChatViewModel: ChatViewModelProtocol {
    @Published var inputValid: Bool = false
    @Published var showModelSettings: Bool = false
    @Published var inputText: String = ""
    @Published var chatHistory: [ChatMessage]
    
    private let databaseManager: DatabaseManager
    
    var llama: LLama? = nil
    private var totalTokenSize: Int = 0
    
    var cancellables = Set<AnyCancellable>()
    
    init(
        databaseManager: DatabaseManager = DatabaseManager.shared,
//        showModelSettings: Bool = false,
//        inputText: String = "",
        chatHistory: [ChatMessage] = []
    ) {
        self.databaseManager = databaseManager
//        self.showModelSettings = showModelSettings
//        self.inputText = inputText
        self.chatHistory = chatHistory
        
        validateInput()
    }
    
    private func validateInput() {
        $inputText
            .map { text in
                let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
                return !trimmedText.isEmpty
            }
            .sink { [weak self] isValid in
                self?.inputValid = isValid
            }
            .store(in: &cancellables)
    }
    
    func initializeLlama(modelPath: String, contextSize: Int = Constant.contextWindowToken) {
        do {
            self.llama = try LLama(modelPath: modelPath, contextSize: contextSize)
            totalTokenSize = contextSize
        } catch let error {
            print("Load model and init llama fail: \(error.localizedDescription)")
        }
    }
    
    func clearChat() {
        chatHistory.removeAll()
    }
    
    func sendChat<TopicVM: TopicViewModelProtocol>(withTopicVM topicVM: TopicVM) async {
        guard let llama else {
            print("Llama model or context not initialized...")
            return
        }
        let modelName = await llama.getModelName()
        
        do {
            let userMsg = ChatMessage(role: .user, content: inputText)
            chatHistory.append(userMsg)
            await trimHistoryIfNeeded()
            let prompt = makePrompt()
            
            inputText = ""
            var result = ""
            chatHistory.append(ChatMessage(role: .thinking, content: ""))
            for try await token in await llama.infer(prompt: prompt, maxGeneratedTokens: Int32(Constant.maxGeneratedToken)) {
                if let lastMsg = chatHistory.last, lastMsg.role == .thinking {
                    // Remove the 'thinking' message first
                    chatHistory.removeLast()
                    // Then put an empty 'assistant' message
                    chatHistory.append(ChatMessage(role: .assistant, content: ""))
                    // Ignore the first generated token '\n'
                    if token == "\n" {
                        continue
                    }
                }
                print(token, terminator: "")
                result.append(token)
                // Update and append the 'assistant' message content with the new generated token
                chatHistory[chatHistory.endIndex - 1].content.append(token)
            }
            print("\n\nFinal result: \(result)")
            // When finish generating token, save it to the database
            if var currentTopic = topicVM.selectedTopic {
                if currentTopic.selectedModel != modelName {
                    // Update the current topic with current model name
                    currentTopic.selectedModel = modelName
                    try await databaseManager.topicDbHandler.updateTopic(currentTopic)
                    topicVM.selectedTopic = currentTopic
                }
            } else {
                // No current topic, create first
                let newTopicMsg = TopicMessage(title: userMsg.content, selectedModel: modelName, selectedModelType: .local)
                try await databaseManager.topicDbHandler.insertTopic(newTopicMsg)
                topicVM.selectedTopic = newTopicMsg
            }
            // Save the user chat and generated chat with the selected topicId
            try await databaseManager.chatDbHandler.batchInsertChat(chatHistory.suffix(2), topicId: topicVM.selectedTopic?.id ?? "")
        } catch let error {
            chatHistory.removeLast(2)    // User input & failed generated token
            print("Prompt: \(inputText)")
            print("Model infer error: \(error.localizedDescription)")
        }
    }
    
    func getChats(byTopicId topicId: String) async {
        let chatDbHandler = await databaseManager.chatDbHandler
        do {
            chatHistory = try await chatDbHandler.fetchChats(byTopicId: topicId)
        } catch let error {
            print("Failed to fetch chats for topic: \(topicId), error: \(error.localizedDescription)")
        }
    }
    
    func send() async {
        do {
            chatHistory.append(ChatMessage(role: .user, content: inputText))
            try await databaseManager.topicDbHandler.insertTopic(TopicMessage(title: inputText, selectedModel: "", selectedModelType: .local))
            inputText = ""
        } catch let error {
            print("Model infer error: \(error.localizedDescription)")
        }
    }
    
    private func makePrompt() -> String {
        chatHistory.map { $0.toPrompt() }.joined(separator: "\n").appending("\n<|assistant|>")
    }

    private func trimHistoryIfNeeded() async {
        var totalTokens = await countTotalTokens()
        while totalTokens > (totalTokenSize - Constant.maxGeneratedToken) {
            // Keep 1/3 of max tokens for the new generated content
            if !chatHistory.isEmpty {
                chatHistory.removeFirst()
                totalTokens = await countTotalTokens()
            } else {
                break
            }
        }
    }
    
    /// Estimate the tokens count, roughly
    private func countTotalTokens() async -> Int {
        let fullPrompt = makePrompt()
        if let llama {
            let tokens = await llama.tokenize(text: fullPrompt, add_bos: true)
            return tokens.count
        } else {
            return 0
        }
    }
}
