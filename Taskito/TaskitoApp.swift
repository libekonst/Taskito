//
//  TaskitoApp.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 12/3/24.
//

import SwiftUI

// MARK: - Keyboard Shortcut Handler Singleton


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
            // Register on MenuBarLabel, to make sure registration happens on app start.
            .task {
                // Register keyboard shortcut handler on app launch
                GlobalShortcutListener.shared.register(
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
