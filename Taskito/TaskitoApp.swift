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
    // MARK: - Dependencies

    private let loginItemManager = LoginItemManager()
    @StateObject private var settingsStore: SettingsStore

    // MARK: - Stores

    @ObservedObject private var countdownStore = CountdownStore()
    @StateObject private var presetsStore = PresetTimersStore()

    // MARK: - Services

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
            .onAppear {
                countdownStore.onTimerCompleted {
                    if settingsStore.soundEnabled {
                        audioIndication.play()
                    }
                }
            }
            .background(
                KeyboardShortcutRegistrationView(settingsStore: settingsStore)
            )
        } label: {
            MenuBarLabel(
                countdownStore: countdownStore,
                timerPolicy: timerPolicy
            )
        }
        .menuBarExtraStyle(.window)

        WindowGroup(id: WindowIdentifier.settingsMenu) {
            PreferencesWindow(
                presetStore: presetsStore,
                settingsStore: settingsStore,
                timerPolicy: timerPolicy
            )
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)
        .handlesExternalEvents(matching: Set([WindowIdentifier.settingsMenu]))

        WindowGroup(id: WindowIdentifier.quickTimer) {
            QuickTimerView(
                countdownStore: countdownStore,
                timerPolicy: timerPolicy
            )
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)
        .handlesExternalEvents(matching: Set([WindowIdentifier.quickTimer]))
        .commandsRemoved() // Prevent multiple windows via menu commands
    }
}

// MARK: - Keyboard Shortcut Registration View

private struct KeyboardShortcutRegistrationView: View {
    @Environment(\.openWindow) private var openWindow
    @ObservedObject var settingsStore: SettingsStore

    var body: some View {
        Color.clear
            .frame(width: 0, height: 0)
            .task {
                // Register the keyboard shortcut handler once using .task
                KeyboardShortcutHandler.shared.register(
                    openWindow: { id in
                        openWindow(id: id)
                    },
                    settingsStore: settingsStore
                )
            }
    }
}

