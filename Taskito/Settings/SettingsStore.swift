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
    @AppStorage(AppStorageKeys.Settings.soundEnabled) var soundEnabled: Bool = true

    // MARK: - Global Shortcut Settings

    /// Whether global keyboard shortcut is enabled
    @AppStorage(AppStorageKeys.Settings.globalShortcutEnabled) var globalShortcutEnabled: Bool = true

    // MARK: - General Settings

    /// Whether to launch app on system startup (read-only from UI perspective)
    @AppStorage(AppStorageKeys.Settings.startOnStartup) var startOnStartup: Bool = false

    /// Published error message for displaying alerts
    @Published var startupError: LoginItemManager.LoginItemError?

    // MARK: - Private Properties

    /// Login item manager for handling startup settings
    private let loginItemManager: LoginItemManaging

    // MARK: - Future Settings (placeholders)

    // Custom keybindings will go here
    // Preset timer configurations will go here

    // MARK: - Initialization

    init(loginItemManager: LoginItemManaging) {
        self.loginItemManager = loginItemManager

        // Initial sync with system state (async, happens in background)
        Task { @MainActor in
            await self.syncWithSystemState()
        }

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

    // MARK: - Public API

    /// Set whether the app should launch on system startup
    /// - Parameter enabled: true to enable startup on login, false to disable
    @MainActor
    func setStartOnStartup(_ enabled: Bool) async {
        let result = await loginItemManager.setStartOnLogin(enabled: enabled)

        switch result {
        case .success:
            // Update stored value on success
            startOnStartup = enabled
            startupError = nil
            print("✅ Startup setting updated: \(enabled)")
        case .failure(let error):
            // Don't update stored value, keep previous state
            startupError = error
            print("❌ Failed to set startup: \(error.localizedDescription)")
        }
    }

    // MARK: - System State Synchronization

    /// Sync the stored preference with actual system login item status
    @MainActor
    func syncWithSystemState() async {
        let systemIsEnabled = await loginItemManager.isEnabled()
        if startOnStartup != systemIsEnabled {
            startOnStartup = systemIsEnabled
            print("🔄 Synced login item status with system state: \(systemIsEnabled)")
        }
    }

    /// Called when app becomes active - check if login item status changed externally
    @objc private func appDidBecomeActive() {
        Task { @MainActor in
            await syncWithSystemState()
        }
    }

    // TODO add initialize on startup
    // TODO add bind to spotlight actions
}
