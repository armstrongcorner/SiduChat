//
//  DownloadManager.swift
//  SiduChat
//
//  Created by Armstrong Liu on 19/09/2025.
//

import Foundation

enum DownloadStatus {
    case idle
    case downloading
    case paused
    case cancelled
    case finish
    case failure
}

enum DownloadEvent {
    case progress((Int64, Int64?))   // (totalBytesWritten, totalBytesExpectedToWrite)
    case finished(URL)               // File saved position
}

enum DownloadKey: String {
    case cacheInfo = "download-cache-info"
}

enum DownloadError: Error {
    case noResumeData
    case invalidUrl(String)
    case fileSystemError(Error)
    case encodingError(Error)
    case decodingError(Error)
    
    var localizedDescription: String {
        switch self {
        case .noResumeData:
            return "No resume data available"
        case .invalidUrl(let urlString):
            return "Invalid url error: \(urlString)"
        case .fileSystemError(let error):
            return "File system error: \(error.localizedDescription)"
        case .encodingError(let error):
            return "Fail to encode cache info: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Fail to decode cache info: \(error.localizedDescription)"
        }
    }
}

struct CacheInfo: Codable {
    let downloadLink: String
    let cacheFileName: String
    let totalBytesWritten: Int64
    let totalBytesExpectedToWrite: Int64
}

actor DownloadManager:NSObject {
    private var urlSession: URLSession!
    private var task: URLSessionDownloadTask?
    private var urlString: String = ""
    private var savePath: URL?
    private var totalBytesWritten: Int64 = 0
    private var totalBytesExpectedToWrite: Int64 = -1
    private var userDefaults: UserDefaults
    
    private var continuation: AsyncThrowingStream<DownloadEvent, Error>.Continuation?
    
    init(isEphemeral: Bool = false, userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
        
        super.init()
        
        let configuration = isEphemeral ? URLSessionConfiguration.ephemeral : URLSessionConfiguration.default
        self.urlSession = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }
    
    // MARK: - Main download functions
    func start(urlString: String, savePath: URL) -> AsyncThrowingStream<DownloadEvent, Error> {
        self.savePath = savePath
        self.urlString = urlString
        
        return AsyncThrowingStream { continuation in
            self.continuation = continuation
            
            guard let url = URL(string: urlString),
                  let scheme = url.scheme?.lowercased(),
                  ["http", "https"].contains(scheme) else {
                self.continuation?.finish(throwing: DownloadError.invalidUrl(urlString))
                return
            }
            
            do {
                if let data = self.userDefaults.data(forKey: DownloadKey.cacheInfo.rawValue) {
                    // Continue downloading
                    let cacheInfo = try JSONDecoder().decode(CacheInfo.self, from: data)
                    guard let cacheUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appending(path: cacheInfo.cacheFileName) else {
                        self.continuation?.finish(throwing: DownloadError.noResumeData)
                        return
                    }
                    
                    if FileManager.default.fileExists(atPath: cacheUrl.path()) {
                        let cacheData = try Data(contentsOf: cacheUrl)
                        self.task = urlSession.downloadTask(withResumeData: cacheData)
                    } else {
                        self.continuation?.finish(throwing: DownloadError.noResumeData)
                    }
                } else {
                    // New downloading task
                    self.task = urlSession.downloadTask(with: url)
                }
                
                self.task?.resume()
            } catch let error as DecodingError {
                self.continuation?.finish(throwing: DownloadError.decodingError(error))
            } catch let error {
                self.continuation?.finish(throwing: DownloadError.fileSystemError(error))
            }
        }
    }
    
    func pause() async {
        if let cacheData = await self.task?.cancelByProducingResumeData() {
            guard let savePath = self.savePath else { return }
            let cachedFileName = savePath.lastPathComponent.appending(".resume")
            guard let cachePath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appending(path: cachedFileName) else {
                self.continuation?.finish(throwing: DownloadError.noResumeData)
                return
            }
            
            do {
                try cacheData.write(to: cachePath)
                
                let cacheInfo = CacheInfo(
                    downloadLink: self.urlString,
                    cacheFileName: cachedFileName,
                    totalBytesWritten: totalBytesWritten,
                    totalBytesExpectedToWrite: totalBytesExpectedToWrite
                )
                let encodedData = try JSONEncoder().encode(cacheInfo)
                self.userDefaults.set(encodedData, forKey: DownloadKey.cacheInfo.rawValue)
            } catch let error as EncodingError {
                self.continuation?.finish(throwing: DownloadError.encodingError(error))
            } catch let error {
                print("Error: \(error.localizedDescription)")
                self.continuation?.finish(throwing: DownloadError.fileSystemError(error))
            }
        }
        
        self.continuation?.finish()
    }

    func cancel() {
        self.task?.cancel()
        self.task = nil
        clearCache()
        
        self.continuation?.finish()
    }
    
    func getCacheInfo() -> CacheInfo? {
        if let data = self.userDefaults.data(forKey: DownloadKey.cacheInfo.rawValue) {
            return try? JSONDecoder().decode(CacheInfo.self, from: data)
        }
        
        return nil
    }
    
    private func clearCache() {
        do {
            // Delete resume data if exist
            if let data = self.userDefaults.data(forKey: DownloadKey.cacheInfo.rawValue) {
                let cacheInfo = try JSONDecoder().decode(CacheInfo.self, from: data)
                guard let cacheUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appending(path: cacheInfo.cacheFileName) else {
                    self.continuation?.finish(throwing: DownloadError.noResumeData)
                    return
                }
                
                if FileManager.default.fileExists(atPath: cacheUrl.path()) {
                    try FileManager.default.removeItem(at: cacheUrl)
                }
            }
            // Delete cache info
            self.userDefaults.removeObject(forKey: DownloadKey.cacheInfo.rawValue)
        } catch let error as DecodingError {
            self.continuation?.finish(throwing: DownloadError.decodingError(error))
        } catch let error {
            self.continuation?.finish(throwing: DownloadError.fileSystemError(error))
        }
    }
    
    private func handleProgress(totalWritten: Int64, expected: Int64) {
        self.totalBytesWritten = totalWritten
        self.totalBytesExpectedToWrite = expected
        
        let expectedOpt: Int64? = expected > 0 ? expected : nil
        
        self.continuation?.yield(.progress((totalWritten, expectedOpt)))
    }
}

// MARK: - URLSessionDownloadDelegate
extension DownloadManager: URLSessionDownloadDelegate {
    // Progress callback
    nonisolated func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        Task { [weak self] in
            await self?.handleProgress(totalWritten: totalBytesWritten, expected: totalBytesExpectedToWrite)
        }
    }

    // Complete callback
    nonisolated func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        /// Important: Must handle the download location in the callback thread, which means we must keep the 'location' into a temp file in the callback.
        /// Then in the other thread, retrieve the actual 'savePath' and move temp file to the 'savePath'.
        guard let tempPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appending(path: "tempfile") else { return }
        
        do {
            if FileManager.default.fileExists(atPath: tempPath.path()) {
                try FileManager.default.removeItem(at: tempPath)
            }
            try FileManager.default.moveItem(at: location, to: tempPath)
            
            Task {
                guard let savePath = await self.savePath else { return }
                try FileManager.default.moveItem(at: tempPath, to: savePath)
                
                // Clean the cache
                await self.clearCache()
                
                await self.continuation?.yield(.finished(savePath))
                await self.continuation?.finish()
            }
        } catch let error {
            Task {
                await self.continuation?.finish(throwing: error)
            }
        }
    }
    
    // Failure callback
    nonisolated func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: (any Error)?
    ) {
        if let error = error as? NSError, error.code != NSURLErrorCancelled {
            Task { [weak self] in
                await self?.continuation?.finish(throwing: error)
            }
        }
    }
}
