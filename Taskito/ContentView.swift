//
//  ContentView.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 12/3/24.
//

import SwiftUI

struct ContentView: View {
    private let timerPolicy = StandardTimerPolicy()

    @ObservedObject var countdownStore: CountdownStore

    init(countdownStore: CountdownStore) {
        self.countdownStore = countdownStore

        self.countdownStore.onTimerStarted {
            print("Timer started ⏱️")
        }

        self.countdownStore.onTimerCompleted {
            print("Timer done ✅")
        }
    }

    var body: some View {
        VStack {
            if countdownStore.isTimerDepleted {
                FormView(
                    onSubmit: { minutes, seconds in
                        countdownStore.createNewTimer(
                            minutes: minutes,
                            seconds: seconds
                        )
                    },
                    timerPolicy: timerPolicy
                )
                .transition(.opacity)
            }

            else {
                // TODO: rename
                CountdownView(
                    secondsRemaining: countdownStore.secondsRemaining,
                    onPlayPause: withAnimation(.interactiveSpring(duration: 0.2)) {
                        countdownStore.toggleTimer
                    },
                    onReset: countdownStore.resetTimer,
                    isTimerRunning: countdownStore.isRunning,
                    timerPolicy: timerPolicy
                )
                .transition(.opacity)
            }
        }
        .frame(width: 450, height: 280, alignment: .center)
    }
}

#Preview {
    ContentView(countdownStore: CountdownStore())
}
