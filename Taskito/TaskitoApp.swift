//
//  TaskitoApp.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 12/3/24.
//

import SwiftUI

@main
struct TaskitoApp: App {
    @ObservedObject private var countdownStore = CountdownStore()
    @StateObject private var presetsStore = PresetTimersStore()
    private var timerPolicy = StandardTimerPolicy()
    private var audioIndication = AudioIndication()
    private let settings = SettingsStore.shared

    var body: some Scene {
        MenuBarExtra {
            MenuBarWindowContent(
                countdownStore: countdownStore,
                timerPolicy: timerPolicy,
                presetsStore: presetsStore
            )
            .onAppear {
                countdownStore.onTimerCompleted {
                    if settings.soundEnabled {
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
            PreferencesWindow(presetStore: presetsStore)
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)
        .handlesExternalEvents(matching: Set([WindowIdentifier.settingsMenu]))
    }
}
