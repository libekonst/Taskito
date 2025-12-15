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
    private var timerPolicy = StandardTimerPolicy()
    private var audioIndication = AudioIndication()
    private let settings = SettingsStore.shared

    @Environment(\.openWindow) var openWindow
    @Environment(\.dismiss) var dismiss

    private var systemActionsStore: SystemActionsStore {
        let controller = AppKitSystemController(
            dismissAction: { dismiss() },
            openWindowById: { id in openWindow(id: id) }
        )
        return SystemActionsStore(systemController: controller)
    }

    var body: some Scene {
        MenuBarExtra {
            MenuBarWindowContent(
                countdownStore: countdownStore,
                timerPolicy: timerPolicy,
                systemActionsStore: systemActionsStore
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
            KeyboardShortcutsView()
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)
    }
}
