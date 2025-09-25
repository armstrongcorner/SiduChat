//
//  Constant.swift
//  SiduChat
//
//  Created by Armstrong Liu on 02/09/2025.
//

import Foundation

final class Constant {
    // MARK: - Network
    static let defaultTimeout: TimeInterval = 120
    
    // MARK: - LLAMA
    static let contextWindowToken: Int = 2048
    static let maxGeneratedToken: Int = contextWindowToken / 2
}
