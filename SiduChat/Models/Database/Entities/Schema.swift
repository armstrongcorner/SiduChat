//
//  SchemaV1.swift
//  SiduChat
//
//  Created by Armstrong Liu on 12/09/2025.
//

import Foundation
import SwiftData

typealias CurrentSchema = SchemaV101

enum SchemaV101: VersionedSchema {
    static var models: [any PersistentModel.Type] {
        [Topic.self, Chat.self]
    }
    
    static var versionIdentifier: Schema.Version {
        .init(1, 0, 1)
    }
}

enum SchemaV100: VersionedSchema {
    static var models: [any PersistentModel.Type] {
        [Topic.self, Chat.self]
    }
    
    static var versionIdentifier: Schema.Version {
        .init(1, 0, 0)
    }
}
