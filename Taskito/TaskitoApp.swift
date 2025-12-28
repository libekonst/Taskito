//
//  TaskitoApp.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 12/3/24.
//

import KeyboardShortcuts
import SwiftUI

// MARK: - Keyboard Shortcut Handler Singleton

@MainActor
class KeyboardShortcutHandler {
    static let shared = KeyboardShortcutHandler()

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

@main
@MainActor
struct TaskitoApp: App {
    private let loginItemManager = LoginItemManager()
    @StateObject private var settingsStore: SettingsStore
    @Environment(\.openWindow) private var openWindow
    @ObservedObject private var countdownStore = CountdownStore()
    @StateObject private var presetsStore = PresetTimersStore()
    private var timerPolicy = StandardTimerPolicy()
    private var audioIndication = AudioIndication()

    init() {
        // Initialize settings store with dependencies
        let settingsStore = SettingsStore(loginItemManager: loginItemManager)
        _settingsStore = StateObject(wrappedValue: settingsStore)
    }

    var body: some Scene {
        MenuBarExtra {
            MenuBarWindowContent(
                countdownStore: countdownStore,
                timerPolicy: timerPolicy,
                presetsStore: presetsStore
            )
        } label: {
            MenuBarLabel(
                countdownStore: countdownStore,
                timerPolicy: timerPolicy
            )
            .task {
                // Register keyboard shortcut handler on app launch
                KeyboardShortcutHandler.shared.register(
                    openWindow: { id in
                        openWindow(id: id)
                    },
                    settingsStore: settingsStore
                )

                // Register audio completion handler
                countdownStore.onTimerCompleted { [weak settingsStore] in
                    if settingsStore?.soundEnabled == true {
                        audioIndication.play()
                    }
                }
            }
        }
        .menuBarExtraStyle(.window)

        // Settings window
        WindowGroup(id: WindowIdentifier.settingsMenu) {
            PreferencesWindow(
                presetStore: presetsStore,
                settingsStore: settingsStore,
                timerPolicy: timerPolicy
            )
            .windowIdentifier(WindowIdentifier.settingsMenu)
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)
        .handlesExternalEvents(matching: Set([WindowIdentifier.settingsMenu]))

        // Quick timer window opened through the global shortcut
        WindowGroup(id: WindowIdentifier.quickTimer) {
            QuickTimerView(
                countdownStore: countdownStore,
                timerPolicy: timerPolicy
            )
            .windowIdentifier(WindowIdentifier.quickTimer)
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)
        .handlesExternalEvents(matching: Set([WindowIdentifier.quickTimer]))
        .commandsRemoved() // Prevent multiple windows via menu commands
    }
}
