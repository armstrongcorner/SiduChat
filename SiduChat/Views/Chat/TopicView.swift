//
//  TopicView.swift
//  SiduChat
//
//  Created by Armstrong Liu on 10/09/2025.
//

import SwiftUI

struct TopicView<TopicVM, ModelSettingsVM>: View where TopicVM: TopicViewModelProtocol, ModelSettingsVM: ModelSettingsViewModelProtocol {
    @ObservedObject private var topicVM: TopicVM
    @ObservedObject var modelSettingsVM: ModelSettingsVM
    
    init(
        topicVM: TopicVM = TopicViewModel(),
        modelSettingsVM: ModelSettingsVM = ModelSettingsViewModel()
    ) {
        self.topicVM = topicVM
        self.modelSettingsVM = modelSettingsVM
    }
    
    // MARK: - body
    var body: some View {
        VStack {
            // New chat button
            newChatSection
            
            // Topic list
            topicSection
            
            // Current user
            userSection
        }
        .onAppear {
            Task {
                await topicVM.getTopics()
            }
        }
        .alert("New chat confirm", isPresented: $topicVM.showSwitchModel) {
            Button("OOO", role: .cancel) {
                
            }
            
            Button("PPP", role: .destructive) {
                
            }
            
            Button {
                
            } label: {
                Text("111")
            }

        } message: {
            Text("\(modelSettingsVM.currentLoadedModel?.displayName ?? "")")
        }

    }
    
    // MARK: - other UI widgets
    @ViewBuilder
    private var newChatSection: some View {
        Button {
            topicVM.showSwitchModel.toggle()
        } label: {
            HStack {
                Image(systemName: "plus.app")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25)
                Text("New Chat")
            }
            .foregroundStyle(.black)
            .padding(.horizontal)
        }
        .buttonStyle(.bordered)
        
        Divider()
    }
    
    @ViewBuilder
    private var topicSection: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(topicVM.topicMessages) { topicMessage in
                    getTopicRow(topicMessage: topicMessage)
                }
                .onDelete(perform: onDeleteTopic)
            }
            .listStyle(.plain)
            .onChange(of: topicVM.topicMessages, initial: true) {
                if let firstTopic = topicVM.topicMessages.first {
                    withAnimation(.spring) {
                        proxy.scrollTo(firstTopic.id, anchor: .top)
                    }
                }
            }
        }
        
        Divider()
    }
    
    private var userSection: some View {
        Button {
            
        } label: {
            HStack(spacing: 15) {
                ZStack(alignment: .center) {
                    Rectangle()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(.purple)
                        .clipShape(.rect(cornerRadius: 10))
                    
                    Text("A")
                        .foregroundStyle(.white)
                }
                
                Text("My username")
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Image(systemName: "ellipsis")
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
        .tint(.secondary)
        .background(.ultraThinMaterial)
    }
    
    // MARK: - functions
    private func onDeleteTopic(indexSet: IndexSet) {
        Task {
            if let topicToDelete = indexSet.map({ topicVM.topicMessages[$0] }).first {
                if await topicVM.deleteTopic(topicId: topicToDelete.id) {
                    topicVM.topicMessages.remove(atOffsets: indexSet)
                    
                    if topicVM.selectedTopic != nil && topicToDelete == topicVM.selectedTopic {
                        topicVM.selectedTopic = nil
                    }
                }
            }
        }
    }
    
    private func getTopicRow(topicMessage: TopicMessage) -> some View {
        Text(topicMessage.title)
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(.gray.opacity(topicVM.selectedTopic == topicMessage ? 0.3 : 0.01))
            )
            .padding(.horizontal, 8)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets())
            .onTapGesture {
                if modelSettingsVM.currentLoadedModel?.displayName != topicMessage.selectedModel {
                    let selectedModelForTopic = modelSettingsVM.downloadedModels.first { $0.displayName == topicMessage.selectedModel }
                    modelSettingsVM.loadModel(selectedModelForTopic)
                }
                topicVM.selectedTopic = topicMessage
                topicVM.showLastChat = true
                topicVM.showSideMenu.toggle()
            }
    }
}

// MARK: - previews
#Preview {
    let mockModelSettingsVM = ModelSettingsViewModel(
        downloadedModels: [mockModel1, mockModel2, mockModel3],
        currentLoadedModel: mockModel1
    )
    let mockTopicVM = TopicViewModel(databaseManager: DatabaseManager.sharedInMemory)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        mockTopicVM.topicMessages = mockTopicHistory
        mockTopicVM.selectedTopic = mockTopicMessage4
    }
    
    return TopicView(
        topicVM: mockTopicVM,
        modelSettingsVM: mockModelSettingsVM
    )
}
