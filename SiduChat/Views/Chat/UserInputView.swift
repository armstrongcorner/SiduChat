//
//  UserInputView.swift
//  SiduChat
//
//  Created by Armstrong Liu on 31/08/2025.
//

import SwiftUI

struct UserInputView<ChatVM, TopicVM>: View where ChatVM: ChatViewModelProtocol, TopicVM: TopicViewModelProtocol {
    @ObservedObject var chatVM: ChatVM
    @ObservedObject var topicVM: TopicVM
    
    var body: some View {
        HStack(alignment: .bottom) {
            TextEditor(text: $chatVM.inputText)
                .font(.body)
                .frame(minHeight: 40, maxHeight: 120)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.leading, 5)
                .padding(3)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(.gray, lineWidth: 1)
                )
            
            Button {
                Task {
                    await chatVM.sendChat(withTopicVM: topicVM)
//                    await chatVM.send()
                }
            } label: {
                Image(systemName: "paperplane.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25)
                    .padding(.trailing, 8)
                    .padding(.bottom, 10)
            }
            .buttonStyle(.plain)
            .disabled(!chatVM.inputValid)
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    let mockChatVM = ChatViewModel()
    let mockTopicVM = TopicViewModel()
    
    return UserInputView(chatVM: mockChatVM, topicVM: mockTopicVM)
}
