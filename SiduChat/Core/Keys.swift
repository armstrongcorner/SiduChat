//
//  Keys.swift
//  SiduChat
//
//  Created by Armstrong Liu on 08/09/2025.
//

import SwiftUI

private struct ScreenSizeKey: EnvironmentKey {
    static let defaultValue: CGSize = .zero
}

extension EnvironmentValues {
    var screenSize: CGSize {
        get { self[ScreenSizeKey.self] }
        set { self[ScreenSizeKey.self] = newValue }
    }
}

private struct DatabaseManagerKey: EnvironmentKey {
    static let defaultValue: DatabaseManager = DatabaseManager.shared
}

extension EnvironmentValues {
    var databaseManager: DatabaseManager {
        get { self[DatabaseManagerKey.self] }
        set { self[DatabaseManagerKey.self] = newValue }
    }
}
