//
//  ContentView.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 12/3/24.
//

import AppKit
import SwiftUI

struct MenuBarWindowContent: View {
    @ObservedObject var countdownStore: CountdownStore
    var timerPolicy: TimerPolicy
    @ObservedObject var presetsStore: PresetTimersStore

    @AppStorage("latestMinutesSelection") private var minutes = 25
    @AppStorage("latestSecondsSelection") private var seconds = 00

    // Variables are available here. Don't move further up.
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismiss) private var dismiss

    private var systemActionsStore: SystemActionsStore {
        let controller = AppKitSystemController(
            dismissAction: { dismiss() },
            openWindowById: { id in openWindow(id: id) }
        )
        return SystemActionsStore(systemController: controller)
    }

    var body: some View {
        VStack {
            switch countdownStore.timerState {
            case .paused,
                 .running:
                CountdownView(
                    secondsRemaining: countdownStore.secondsRemaining,
                    onPlayPause: {
                        withAnimation(.interactiveSpring(duration: 0.2)) {
                            _ = countdownStore.togglePlayPauseTimer()
                        }
                    },
                    onReset: {
                        countdownStore.cancelTimer()
                    },
                    onRestart: {
                        countdownStore.restartTimer()
                    },
                    onAddTime: { seconds in
                        countdownStore.addTime(seconds: seconds)
                    },
                    isTimerRunning: countdownStore.timerState == .running,
                    timerPolicy: timerPolicy
                )
                .transition(.blurReplace.animation(.snappy))
            case .completed,
                 .cancelled,
                 .idle:
                VStack {
                    FormView(
                        onSubmit: {
                            _ = countdownStore.startNewTimer(minutes: minutes, seconds: seconds)
                        },
                        minutes: $minutes,
                        seconds: $seconds,
                        timerPolicy: timerPolicy,
                        presetsStore: presetsStore
                    )
                    SystemMenuView(store: systemActionsStore)
                }
                .transition(.opacity.animation(.snappy))
            }
        }
        .frame(width: 576, height: 384, alignment: .center)
        .background(
            SystemGlobalKeyboardShortcuts(store: systemActionsStore)
        )
    }
}

#Preview {
    MenuBarWindowContent(
        countdownStore: CountdownStore(),
        timerPolicy: StandardTimerPolicy(),
        presetsStore: PresetTimersStore()
    )
}
