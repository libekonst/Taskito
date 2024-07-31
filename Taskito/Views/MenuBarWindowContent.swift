//
//  ContentView.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 12/3/24.
//

import SwiftUI

struct MenuBarWindowContent: View {
    @ObservedObject var countdownStore: CountdownStore
    var timerPolicy: TimerPolicy

    @State private var minutes = 25
    @State private var seconds = 00

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
                    isTimerRunning: countdownStore.timerState == .running,
                    timerPolicy: timerPolicy
                )
                .transition(.opacity)
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
                .transition(.opacity)
            }
        }
        .frame(width: 450, height: 280, alignment: .center)
    }
}

#Preview {
    MenuBarWindowContent(
        countdownStore: CountdownStore(),
        timerPolicy: StandardTimerPolicy()
    )
}
