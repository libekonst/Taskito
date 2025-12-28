//
//  AppStorageKeys.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 28/12/25.
//

import Foundation

/// Centralized keys for AppStorage to prevent typos and duplication
enum AppStorageKeys {
    /// Latest user selection for timer minutes
    static let latestMinutes = "latestMinutesSelection"

    /// Latest user selection for timer seconds
    static let latestSeconds = "latestSecondsSelection"

    /// Serialized preset timers data
    static let presetTimers = "presetTimers"

    /// Settings-related storage keys
    enum Settings {
        /// Whether sound is enabled for timer completion
        static let soundEnabled = "settings.soundEnabled"

        /// Whether global keyboard shortcut is enabled
        static let globalShortcutEnabled = "settings.globalShortcutEnabled"

        /// Whether app should start on system startup
        static let startOnStartup = "settings.startOnStartup"
    }
}
