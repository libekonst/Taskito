//
//  TaskitoApp.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 12/3/24.
//

import SwiftUI

@main
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
                settingsStore: settingsStore
            )
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)
        .handlesExternalEvents(matching: Set([WindowIdentifier.settingsMenu]))
    }
}
