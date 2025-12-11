//
//  ContentView.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 12/3/24.
//

import SwiftUI
import AppKit

struct MenuBarWindowContent: View {
    @ObservedObject var countdownStore: CountdownStore
    var timerPolicy: TimerPolicy

    @AppStorage("latestMinutesSelection") private var minutes = 25
    @AppStorage("latestSecondsSelection") private var seconds = 00

    var body: some View {
        VStack {
            switch countdownStore.timerState {
            case .paused,
                 .running:
                CountdownView(
                    secondsRemaining: countdownStore.secondsRemaining,
                    onPlayPause: withAnimation(.interactiveSpring(duration: 0.2)) {
                        countdownStore.togglePlayPauseTimer
                    },
                    onReset: countdownStore.cancelTimer,
                    onAddTime: countdownStore.addTime,
                    isTimerRunning: countdownStore.timerState == .running,
                    timerPolicy: timerPolicy
                )
                .transition(.blurReplace.animation(.snappy))
            case .completed,
                 .cancelled,
                 .idle:
                FormView(
                    onSubmit: {
                        countdownStore.startNewTimer(minutes: minutes, seconds: seconds)
                    },
                    minutes: $minutes,
                    seconds: $seconds,
                    timerPolicy: timerPolicy
                )
                .transition(.opacity.animation(.snappy))
            }
        }
        .frame(width: 540, height: 360, alignment: .center)
        .background(
            // Hidden button to handle Escape key
            Button("") {
                closeWindowAndRestoreFocus()
            }
            .keyboardShortcut(.escape, modifiers: [])
            .hidden()
        )
    }

    private func closeWindowAndRestoreFocus() {
        // Hide the app completely, which properly dismisses the MenuBarExtra
        // and restores focus to the previous application
        NSApp.hide(nil)
    }
}

#Preview {
    MenuBarWindowContent(
        countdownStore: CountdownStore(),
        timerPolicy: StandardTimerPolicy()
    )
}
