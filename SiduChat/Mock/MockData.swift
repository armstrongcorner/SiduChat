//
//  MockData.swift
//  SiduChat
//
//  Created by Armstrong Liu on 01/09/2025.
//

import Foundation

// MARK: mock models
let mockModel1 = Model(id: "1", displayName: "TinyLlama-1.1B-Q4_0", url: nil, localFilePath: "", filename: "TinyLlama-1.1B.gguf", status: .downloaded)
let mockModel2 = Model(id: "2", displayName: "Phi-2.7B-Q8_0", url: nil, localFilePath: "", filename: "Phi-2.7B-Q8_0.gguf", status: .downloaded)
let mockModel3 = Model(id: "3", displayName: "Mistral-7B-v0.1-Q4_0", url: nil, localFilePath: "", filename: "Mistral-7B-v0.1-Q4_0.gguf", status: .downloaded)

// MARK: mock topic messages
let mockTopicMessage1 = TopicMessage(title: "Working with SwiftData in the Background", selectedModel: "TinyLlama-1.1B.gguf", selectedModelType: .local)
let mockTopicMessage2 = TopicMessage(title: "Getting started with llama.cpp", selectedModel: "TinyLlama-1.1B.gguf", selectedModelType: .local)
let mockTopicMessage3 = TopicMessage(title: "some vs any vs Generic", selectedModel: "TinyLlama-1.1B.gguf", selectedModelType: .local)
let mockTopicMessage4 = TopicMessage(title: "ViSQOL低码率语音编码", selectedModel: "TinyLlama-1.1B.gguf", selectedModelType: .local)
let mockTopicMessage5 = TopicMessage(title: "NFC读取FreeStyle传感器信息", selectedModel: "TinyLlama-1.1B.gguf", selectedModelType: .local)

let mockTopicHistory = [mockTopicMessage1, mockTopicMessage2, mockTopicMessage3, mockTopicMessage4, mockTopicMessage5]

// MARK: mock chat messages
let mockChatMessage1 = ChatMessage(role: .user, content: "User input content 1")
let mockChatMessage2 = ChatMessage(role: .assistant, content: "Assistant response content 1")
let mockChatMessage3 = ChatMessage(role: .user, content: "User input content 2")
let mockChatMessage4 = ChatMessage(role: .assistant, content: "LLMFarm is an iOS and MacOS app to work with large language models (LLM). It allows you to load different LLMs with certain parameters.With LLMFarm, you can test the performance of different LLMs on iOS and macOS and find the most suitable model for your project.")
let mockChatMessage5 = ChatMessage(role: .user, content: "Give me a poet")
let mockChatMessage6 = ChatMessage(role: .assistant, content: "Life never gives anything for nothing, and that a price is always exacted for what fate bestows")
let mockChatMessage7 = ChatMessage(role: .user, content: "中文的用户提问")
let mockChatMessage8 = ChatMessage(role: .assistant, content: "\"所有命运的馈赠早已暗中标好了价格\" 并非源自一首英文原诗，而是出自奥地利作家 斯蒂芬·茨威格（Stefan Zweig）的小说《断头王后》（Maria Antoinette），原文为英文的直译句子，意为“所有命运的馈赠，早已暗中被标好了价格”或“没有什么是免费的，命运所给予的一切都有其价格”")
let mockChatMessage9 = ChatMessage(role: .user, content: "User input content 5")
let mockChatMessage10 = ChatMessage(role: .assistant, content: "Assistant response content 5")
let mockChatMessage11 = ChatMessage(role: .user, content: "User input content 6")
let mockChatMessage12 = ChatMessage(role: .assistant, content: "Assistant response content 6")

let mockThinkingMessage = ChatMessage(role: .thinking, content: "")

let mockMessageHistory = [mockChatMessage1, mockChatMessage2, mockChatMessage3, mockChatMessage4, mockChatMessage5, mockChatMessage6, mockChatMessage7, mockChatMessage8, mockChatMessage9, mockChatMessage10, mockChatMessage11, mockChatMessage12]
