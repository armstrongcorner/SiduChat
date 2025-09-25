//
//  ChatListView.swift
//  SiduChat
//
//  Created by Armstrong Liu on 08/09/2025.
//

import SwiftUI

struct ChatListView<ChatVM, TopicVM>: View where ChatVM: ChatViewModelProtocol, TopicVM: TopicViewModelProtocol {
    @ObservedObject var chatVM: ChatVM
    @ObservedObject var topicVM: TopicVM
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView() {
                ForEach(chatVM.chatHistory) { chatMessage in
                    MessageRowView(message: chatMessage)
                        .padding(.horizontal, 10)
                        .padding(.bottom, 10)
                }
                .frame(maxWidth: .infinity)
            }
            .onChange(of: chatVM.chatHistory, initial: true) {
                if let lastMessage = chatVM.chatHistory.last, (lastMessage.role == .thinking || topicVM.showLastChat) {
                    topicVM.showLastChat = false
                    withAnimation(.spring) {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }
}

#Preview {
    let mockChatVM = ChatViewModel(chatHistory: [mockChatMessage1, mockChatMessage2, mockChatMessage3, mockChatMessage4, mockThinkingMessage])
    let mockTopicVM = TopicViewModel()
    
    ChatListView(chatVM: mockChatVM, topicVM: mockTopicVM)
        .environment(\.screenSize, CGSize(width: 402.0, height: 0))
}
