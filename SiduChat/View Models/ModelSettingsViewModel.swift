//
//  ModelSettingsViewModel.swift
//  SiduChat
//
//  Created by Armstrong Liu on 31/08/2025.
//

import Foundation

@MainActor
protocol ModelSettingsViewModelProtocol: ObservableObject {
    var toastMsg: String? { get set }
    var downloadLink: String { get set }
    var downloadProgress: String { get }
    var downloadStatus: DownloadStatus { get }
    
    var downloadedModels: [Model] { get set }
    var currentLoadedModel: Model? { get }
    var onModelLoaded: ((Model?) -> ())? { get set }
    
    func startDownload()
    func pauseDownload()
    func resumeDownload()
    func cancelDownload()
    
    func getDownloadedModels()
    func deleteModel(_ model: Model)
    func loadModel(_ model: Model?)
}

@MainActor
final class ModelSettingsViewModel: ModelSettingsViewModelProtocol {
    @Published var toastMsg: String?
    @Published var downloadLink: String
    @Published var downloadProgress: String = ""
    @Published var downloadStatus: DownloadStatus = .idle
    
    @Published var downloadedModels: [Model]
    @Published var currentLoadedModel: Model? {
        didSet {
            onModelLoaded?(currentLoadedModel)
        }
    }
    
    private let downloader: DownloadManager
//    var downloadTask: URLSessionDownloadTask?
//    var observation: NSKeyValueObservation?
    
    var onModelLoaded: ((Model?) -> ())?
    
    init(
        toastMsg: String? = nil,
//        downloadLink: String = "https://huggingface.co/ValueFX9507/Tifa-DeepsexV2-7b-MGRPO-GGUF-Q4/resolve/main/Tifa-DeepsexV2-7b-Q4_KM.gguf",
//        downloadLink: String = "https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q8_0.gguf",
//        downloadLink: String = "https://huggingface.co/TheBloke/TinyLlama-1.1B-1T-OpenOrca-GGUF/resolve/main/tinyllama-1.1b-1t-openorca.Q4_0.gguf",
//        downloadLink: String = "https://downloads.raspberrypi.com/raspios_oldstable_lite_arm64/images/raspios_oldstable_lite_arm64-2025-05-07/2025-05-06-raspios-bullseye-arm64-lite.img.xz",
//        downloadLink: String = "https://downloads.raspberrypi.com/imager/rpi-imager-amd64_1.9.6_amd64.deb",
        downloadLink: String = "",
        downloader: DownloadManager = DownloadManager(),
        downloadStatus: DownloadStatus = .idle,
        downloadedModels: [Model] = [],
        currentLoadedModel: Model? = nil
    ) {
        self.toastMsg = toastMsg
        self.downloadLink = downloadLink
        self.downloader = downloader
        self.downloadStatus = downloadStatus
        self.downloadedModels = downloadedModels
        self.currentLoadedModel = currentLoadedModel
        
        getDownloadedModels()
        checkDownloadCache()
    }
    
    // MARK: - Download functions
    func startDownload() {
        guard let filename = downloadLink.split(separator: "/").last else { return }
        guard !(downloadedModels.contains { $0.filename == filename }) else {
            toastMsg = "This model already downloaded"
            return
        }
//        let filename = "aaa.gguf"
        guard let savePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appending(path: filename) else { return }
        
        Task {
            do {
                for try await event in await downloader.start(urlString: downloadLink, savePath: savePath) {
                    switch event {
                    case .progress((let current, let total)):
                        downloadStatus = .downloading
                        if let total {
                            let percentage = Int(Double(current) / Double(total) * 100)
                            downloadProgress = "\(current) / \(total) (\(percentage)%)"
                        } else {
                            downloadProgress = "\(current) / unknown"
                        }
                        print("Progress: \(downloadProgress)")
                    case .finished(_):
                        downloadStatus = .finish
                        getDownloadedModels()
                    }
                }
            } catch let error {
                downloadStatus = .failure
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func pauseDownload() {
        Task {
            await downloader.pause()
            downloadStatus = .paused
        }
    }
    
    func resumeDownload() {
        startDownload()
    }
    
    func cancelDownload() {
        Task {
            await downloader.cancel()
        }
    }
    
    private func checkDownloadCache() {
        Task {
            if let cacheInfo = await downloader.getCacheInfo() {
                self.downloadStatus = .paused
                self.downloadLink = cacheInfo.downloadLink
                
                let current = cacheInfo.totalBytesWritten
                let total = cacheInfo.totalBytesExpectedToWrite
                let percentage = Int(Double(current) / Double(total) * 100)
                self.downloadProgress = "\(current) / \(total) (\(percentage)%)"
            } else {
                self.downloadStatus = .idle
            }
        }
    }
    
    // MARK: - Operate downloaded models
    func getDownloadedModels() {
        // Get from Document directory
        guard let documentUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("No document directory...")
            return
        }
        do {
            let fileUrls = try FileManager.default.contentsOfDirectory(at: documentUrl, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
            let ggufFiles = fileUrls.filter { $0.pathExtension.lowercased() == "gguf" }
            downloadedModels.removeAll()
            for url in ggufFiles {
                let model = Model(
                    displayName: url.lastPathComponent,
                    url: nil,
                    localFilePath: url.path(),
                    filename: url.lastPathComponent,
                    status: .none
                )
                print("Model: \(model)")
                downloadedModels.append(model)
            }
        } catch let error {
            print("Get files error: \(error.localizedDescription)")
        }
    }
    
    func deleteModel(_ model: Model) {
        guard let filePath = model.localFilePath else { return }
        do {
            try FileManager.default.removeItem(atPath: filePath)
        } catch let error {
            print("Delete file error: \(error.localizedDescription)")
        }
    }
    
    func loadModel(_ model: Model?) {
        currentLoadedModel = model
    }
}
