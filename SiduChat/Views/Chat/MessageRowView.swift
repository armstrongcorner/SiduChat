//
//  MessageRowView.swift
//  SiduChat
//
//  Created by Armstrong Liu on 08/09/2025.
//

import SwiftUI

struct MessageRowView: View {
    @Environment(\.screenSize) private var screenSize

    let message: ChatMessage
    
    var isUser: Bool {
        message.role == .user
    }
    
    var body: some View {
        HStack(alignment: .top) {
            switch message.role {
            case .user:
                Spacer()
                bubbleView
                avatarView
                    .padding(.top, 6)
            case .assistant:
                avatarView
                    .padding(.top, 6)
                bubbleView
                Spacer()
            case .thinking:
                HStack(alignment: .center) {
                    avatarView
                    ThinkingView()
                    Spacer()
                }
            }
        }
    }
    
    private var avatarView: some View {
        if isUser {
            Image(systemName: "person.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 25)
        } else {
            Image(.gptIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 30)
        }
    }
    
    private var bubbleView: some View {
        Text(message.content)
            .textSelection(.enabled)
            .padding(12)
            .background(isUser ? Color.blue : Color.gray.opacity(0.3))
            .foregroundColor(isUser ? .white : .black)
            .cornerRadius(12)
            .frame(maxWidth: screenSize.width * 0.7, alignment: isUser ? .trailing : .leading)
    }
    
    private var thinkingView: some View {
        HStack {
            ForEach(0..<3) { i in
                Circle()
                    .frame(width: 12)
            }
        }
        .padding(10)
    }
}

struct ThinkingView: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 0.1)) { context in
            HStack(spacing: 8) {
                ForEach(0..<3) { i in
                    Circle()
                        .frame(width: 12, height: 12)
                        .scaleEffect(scale(for: i, date: context.date))
                        .animation(.easeInOut(duration: 0.6), value: context.date)
                }
            }
            .padding(10)
        }
    }

    private func scale(for index: Int, date: Date) -> CGFloat {
        let t = date.timeIntervalSinceReferenceDate
        let phase = t * 2 + Double(2 - index) * 0.4  // 每个点偏移 0.4 秒
        let sine = sin(phase * .pi)
        return 0.6 + 0.4 * max(0, sine)  // 最小缩放 0.6，最大缩放 1.0
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    Group {
        MessageRowView(message: mockChatMessage1)
        MessageRowView(message: mockChatMessage4)
        MessageRowView(message: mockChatMessage7)
        MessageRowView(message: mockThinkingMessage)
    }
    .environment(\.screenSize, CGSize(width: 402.0, height: 0))
}
