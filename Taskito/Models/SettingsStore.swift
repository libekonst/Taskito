//
//  SettingsStore.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 11/12/25.
//

import Foundation
import SwiftUI
import AppKit

/// Manages all user preferences and settings with local persistence
class SettingsStore: ObservableObject {
    // MARK: - Sound Settings

    /// Whether to play sound when timer completes
    @AppStorage("settings.soundEnabled") var soundEnabled: Bool = true

    // MARK: - General Settings

    /// Whether to launch app on system startup
    @AppStorage("settings.startOnStartup") var startOnStartup: Bool = false {
        didSet {
            // Only update system if we're not syncing from system state
            guard !isSyncingFromSystem else { return }
            LoginItemManager.shared.setStartOnLogin(enabled: startOnStartup)
        }
    }

    // MARK: - Private Properties

    /// Flag to prevent recursive updates when syncing from system
    private var isSyncingFromSystem = false

    // MARK: - Future Settings (placeholders)

    // Custom keybindings will go here
    // Preset timer configurations will go here

    // MARK: - Singleton

    static let shared = SettingsStore()

    private init() {
        // Private initializer for singleton pattern
        // Initial sync with system state
        syncWithSystemState()

        // Monitor app becoming active to detect external changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: NSApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - System State Synchronization

    /// Sync the stored preference with actual system login item status
    private func syncWithSystemState() {
        Task { @MainActor in
            let systemIsEnabled = await LoginItemManager.shared.isEnabled()
            if startOnStartup != systemIsEnabled {
                // Set flag to prevent didSet from triggering system update
                isSyncingFromSystem = true
                startOnStartup = systemIsEnabled
                isSyncingFromSystem = false
                print("🔄 Synced login item status with system state: \(systemIsEnabled)")
            }
        }
    }

    /// Called when app becomes active - check if login item status changed externally
    @objc private func appDidBecomeActive() {
        syncWithSystemState()
    }

    // TODO add initialize on startup
    // TODO add bind to spotlight actions
}
