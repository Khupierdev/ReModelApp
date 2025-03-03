//
//  DynamicIslandManagerKey.swift
//  ReModel
//
//  Created by Khupier on 17/1/25.
//


import SwiftUI

private struct DynamicIslandManagerKey: EnvironmentKey {
    static let defaultValue = DynamicIslandManager.shared
}

extension EnvironmentValues {
    var dynamicIslandManager: DynamicIslandManager {
        get { self[DynamicIslandManagerKey.self] }
        set { self[DynamicIslandManagerKey.self] = newValue }
    }
}

