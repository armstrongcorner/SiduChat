//
//  Model.swift
//  SiduChat
//
//  Created by Armstrong Liu on 31/08/2025.
//

import Foundation

enum ModelStatus: String {
    case downloaded
    case loaded
    case none
}

struct Model: Identifiable, Hashable {
    var id: String = UUID().uuidString
    let displayName: String
    let url: String?
    let localFilePath: String?
    let filename: String
    let status: ModelStatus
//    var llamaModel: LLamaModel?
    
//    mutating func update(model: LLamaModel) {
//        self.llamaModel = model
//    }
}
