//
//  ModelSettingsView.swift
//  SiduChat
//
//  Created by Armstrong Liu on 31/08/2025.
//

import SwiftUI

struct ModelSettingsView<ModelSettingsVM>: View where ModelSettingsVM: ModelSettingsViewModelProtocol {
    @Environment(\.dismiss) var dismiss
    @Environment(ToastViewObserver.self) var toastViewObserver
    
    @ObservedObject var modelSettingsVM: ModelSettingsVM
    
    private var downloadBtnText: String {
        switch modelSettingsVM.downloadStatus {
        case .idle, .cancelled, .finish:
            return "Download"
        case .downloading:
            return modelSettingsVM.downloadProgress
        case .paused:
            let progressStr = modelSettingsVM.downloadProgress
            if let percentage = StringUtil.extractParenthesisContent(from: progressStr) {
                return "Resume (\(percentage))"
            } else {
                return "Resume"
            }
        case .failure:
            return "Retry"
        }
    }
    
    private var downloadLinkEditable: Bool {
        switch modelSettingsVM.downloadStatus {
        case .idle, .cancelled, .finish:
            return true
        default:
            return false
        }
    }
    
    var body: some View {
        List {
            downloadOperationSection
            
            loadModelSection
        }
        .listStyle(.grouped)
        .onChange(of: modelSettingsVM.toastMsg, { oldValue, newValue in
            if let toastMsg = modelSettingsVM.toastMsg {
                toastViewObserver.showToast(message: toastMsg)
                modelSettingsVM.toastMsg = nil
            }
        })
        .toastView(toastViewObserver: toastViewObserver)
    }
    
    // MARK: - other UI widgets
    private var downloadOperationSection: some View {
        Section("Download Model from URL") {
            TextField("Paste download model URL", text: $modelSettingsVM.downloadLink)
                .padding(.horizontal)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(downloadLinkEditable ? .clear : .gray.opacity(0.3))
                        .stroke(.gray, lineWidth: 1.0)
                )
                .disabled(downloadLinkEditable ? false : true)
                .listRowSeparator(.hidden)
            
            Button {
                switch modelSettingsVM.downloadStatus {
                case .idle, .cancelled, .finish:
                    modelSettingsVM.startDownload()
                case .downloading:
                    modelSettingsVM.pauseDownload()
                case .paused:
                    modelSettingsVM.resumeDownload()
                case .failure:
                    modelSettingsVM.startDownload()
                }
            } label: {
                Text(downloadBtnText)
                    .foregroundStyle(.white)
                    .frame(height: 40)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                        
                    )
            }
            .buttonStyle(.plain)
            .foregroundStyle(.blue)
        }
    }
    
    private var loadModelSection: some View {
        Section("Downloaded Models (Click to load)") {
            ForEach(modelSettingsVM.downloadedModels) { model in
                Button {
                    modelSettingsVM.loadModel(model)
                    dismiss()
                } label: {
                    Text("\(model.displayName)")
                }
            }
            .onDelete(perform: onDeleteModel)
        }
    }
    
    // MARK: - functions
    private func onDeleteModel(indexSet: IndexSet) {
        if let modelToDelete = indexSet.map({ modelSettingsVM.downloadedModels[$0] }).first {
            modelSettingsVM.deleteModel(modelToDelete)
            modelSettingsVM.downloadedModels.remove(atOffsets: indexSet)
        }
    }
}

#Preview {
    let mockVM = ModelSettingsViewModel(downloadedModels: [mockModel1, mockModel2, mockModel3])
    
    return ModelSettingsView(modelSettingsVM: mockVM)
}
