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
        .frame(width: 450, height: 300, alignment: .center)
    }
}

#Preview {
    MenuBarWindowContent(
        countdownStore: CountdownStore(),
        timerPolicy: StandardTimerPolicy()
    )
}
