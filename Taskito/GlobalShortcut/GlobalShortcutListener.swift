//
//  GlobalShortcutListener.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 7/1/26.
//

import KeyboardShortcuts
import SwiftUI

@MainActor
class GlobalShortcutListener {
    static let shared = GlobalShortcutListener()

    private var isRegistered = false

    private init() {}

    func register(
        openWindow: @escaping (String) -> Void,
        settingsStore: SettingsStore
    ) {
        guard !isRegistered else { return }
        isRegistered = true

        KeyboardShortcuts.onKeyUp(for: .toggleAppWindow) { [weak settingsStore] in
            // Check if global shortcut is enabled
            guard settingsStore?.globalShortcutEnabled == true else { return }

            // Find all QuickTimer windows
            let quickTimerWindows = NSApp.windows.filter {
                $0.identifier?.rawValue == WindowIdentifier.quickTimer
            }

            // If any QuickTimer window exists, close all of them (toggle off)
            if !quickTimerWindows.isEmpty {
                quickTimerWindows.forEach { $0.close() }
            } else {
                // No QuickTimer window exists, open one (toggle on)
                NSApp.activate(ignoringOtherApps: true)
                openWindow(WindowIdentifier.quickTimer)
            }
        }
    }
}
