//
//  TestHelpers.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 29/12/25.
//

import Foundation
@testable import Taskito

/// Helper utilities for test setup and cleanup
enum TestHelpers {
    /// All UserDefaults keys used by the app (for comprehensive cleanup)
    static let allAppStorageKeys: [String] = [
        // Timer keys
        AppStorageKeys.latestMinutes,
        AppStorageKeys.latestSeconds,
        AppStorageKeys.presetTimers,

        // Settings keys
        AppStorageKeys.Settings.soundEnabled,
        AppStorageKeys.Settings.globalShortcutEnabled,
        AppStorageKeys.Settings.startOnStartup,
    ]

    /// Removes all app-related keys from UserDefaults to ensure test isolation
    /// Call this in setUp to guarantee clean state even if previous test crashed
    static func cleanUserDefaults() {
        let defaults = UserDefaults.standard

        for key in allAppStorageKeys {
            defaults.removeObject(forKey: key)
        }

        // Synchronize to ensure changes are written immediately
        defaults.synchronize()
    }

    /// Removes a specific key from UserDefaults
    static func cleanUserDefaults(key: String) {
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
    }

    /// Removes multiple specific keys from UserDefaults
    static func cleanUserDefaults(keys: [String]) {
        let defaults = UserDefaults.standard
        for key in keys {
            defaults.removeObject(forKey: key)
        }
        defaults.synchronize()
    }
}
