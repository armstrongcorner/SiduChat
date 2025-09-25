//
//  ChatView.swift
//  SiduChat
//
//  Created by Armstrong Liu on 31/08/2025.
//

import SwiftUI

struct ChatView<ChatVM, TopicVM, ModelSettingsVM>: View where ChatVM: ChatViewModelProtocol, TopicVM: TopicViewModelProtocol, ModelSettingsVM: ModelSettingsViewModelProtocol {
    @Environment(ToastViewObserver.self) var toastViewObserver
    @Environment(\.databaseManager) private var databaseManager: DatabaseManager
    
    @StateObject private var chatVM: ChatVM
    @StateObject private var topicVM: TopicVM
    @StateObject private var modelSettingsVM: ModelSettingsVM
    
    init(
        chatVM: @autoclosure @escaping () -> ChatVM = ChatViewModel(),
        topicVM: @autoclosure @escaping () -> TopicVM = TopicViewModel(),
        modelSettingsVM: @autoclosure @escaping () -> ModelSettingsVM = ModelSettingsViewModel()
    ) {
        _chatVM = StateObject(wrappedValue: chatVM())
        _topicVM = StateObject(wrappedValue: topicVM())
        _modelSettingsVM = StateObject(wrappedValue: modelSettingsVM())
    }
    
    // MARK: - body
    var body: some View {
        ZStack {
            // Chat secion
            NavigationStack {
                VStack {
                    ChatListView(chatVM: chatVM, topicVM: topicVM)
                    
                    UserInputView(chatVM: chatVM, topicVM: topicVM)
                        .padding(.leading)
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        titleSection
                    }
                    
                    ToolbarItem(placement: .topBarLeading) {
                        sideMenuButton
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        settingButton
                    }
                }
            }
            .sheet(isPresented: $chatVM.showModelSettings) {
                ModelSettingsView(modelSettingsVM: modelSettingsVM)
                    .onAppear {
                        modelSettingsVM.onModelLoaded = onModelLoaded
                    }
            }
            
            // Side menu view
            SideMenuView($topicVM.showSideMenu) {
                TopicView(topicVM: topicVM, modelSettingsVM: modelSettingsVM)
            }
        }
        .onChange(of: topicVM.selectedTopic, initial: true) { _, newValue in
            Task {
                if let newValue {
                    // New selected topic, get the related chats
                    await chatVM.getChats(byTopicId: newValue.id)
                } else {
                    // Current selected topic is nil, empty the chat list
                    chatVM.clearChat()
                }
            }
        }
        .onChange(of: modelSettingsVM.currentLoadedModel, initial: true) {
            print("current model: \(modelSettingsVM.currentLoadedModel?.displayName ?? "nil")")
            onModelLoaded(model: modelSettingsVM.currentLoadedModel)
        }
//        .onChange(of: chatVM.errorMsg, { oldValue, newValue in
//            if let errorMsg = chatVM.errorMsg {
//                toastViewObserver.showToast(message: errorMsg)
//                chatVM.errorMsg = nil
//            }
//        })
        .toastView(toastViewObserver: toastViewObserver)
    }
    
    // MARK: - other UI widgets
    private var titleSection: some View {
        VStack {
            Text("Chat")
                .font(.headline)
            
            if let displayName = modelSettingsVM.currentLoadedModel?.displayName {
                Text(displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else if let unavailableModelName = topicVM.selectedTopic?.selectedModel, unavailableModelName != "" {
                HStack {
                    Text(unavailableModelName)
                        .font(.caption)
                        .foregroundStyle(.red)
                    
                    Image(systemName: "exclamationmark.triangle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.red)
                }
            }
        }
    }
    
    private var sideMenuButton: some View {
        Button {
            topicVM.showSideMenu.toggle()
        } label: {
            Image(systemName: "line.3.horizontal")
                .foregroundStyle(.black)
        }
    }
    
    private var settingButton: some View {
        Button {
            chatVM.showModelSettings.toggle()
        } label: {
            Image(systemName: "gearshape.fill")
                .foregroundStyle(.black)
        }
    }
    
    // MARK: - functions
    func onModelLoaded(model: Model?) {
        if let modelPath = model?.localFilePath {
            chatVM.initializeLlama(modelPath: modelPath, contextSize: Constant.contextWindowToken)
        }
    }
}

// MARK: - previews
#Preview {
    let mockChatVM = ChatViewModel(
        databaseManager: DatabaseManager.sharedInMemory,
        chatHistory: mockMessageHistory
    )
    let mockTopicVM = TopicViewModel(databaseManager: DatabaseManager.sharedInMemory)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        mockTopicVM.topicMessages = mockTopicHistory
        mockTopicVM.selectedTopic = mockTopicMessage1
    }
    
    return GeometryReader { proxy in
        ChatView(
            chatVM: mockChatVM,
            topicVM: mockTopicVM,
            modelSettingsVM: ModelSettingsViewModel()
        )
        .environment(\.screenSize, proxy.size)
        .environment(\.databaseManager, DatabaseManager.sharedInMemory)
        .environment(ToastViewObserver())
    }
}
