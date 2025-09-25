//
//  BaseResponse.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 15/03/2025.
//

import Foundation

struct BaseResponse<T: Codable & Sendable>: Codable & Sendable {
    let value: T?
    let failureReason: String?
    let isSuccess: Bool
}
