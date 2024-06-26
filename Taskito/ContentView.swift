//
//  ContentView.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 12/3/24.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var countdown = Countdown()
    @State private var isTimerRunning = false

    private let timerPolicy = StandardTimerPolicy()

    // TODO: simplify
    // TODO: remember last selection
    // TODO: back to form on Done
    var isFreshTimer: Bool {
        return !isTimerRunning && countdown.elapsedSeconds == 0
    }

    let timer = Timer.publish(every: 1, on: .main, in: .common)
        .autoconnect()

    var body: some View {
        VStack {
            if isFreshTimer {
                FormView(onSubmit: { minutes, seconds in
                             print("onSubmit")
                             resetCountdown()
                             startTimer()
                             countdown.minutes = minutes
                             countdown.seconds = seconds
                         },
                         timerPolicy: timerPolicy)
                    .transition(.opacity)
            }

            else {
                CountdownView(
                    timeRemaining: countdown.timeRemaining,
                    onPlayPause: startTimer,
                    onStop: stopTimer,
                    isTimerRunning: isTimerRunning,
                    timerPolicy: timerPolicy
                )
                .transition(.opacity)
            }
        }
        .frame(width: 450, height: 280, alignment: .center)
        .onReceive(timer) { time in
            guard isTimerRunning else { return }

            guard countdown.timeRemaining > 0 else {
                return isTimerRunning = false
            }

            countdown.elapsedSeconds += 1
            print(time)
        }
    }

    private func resetCountdown() {
        withAnimation(.interactiveSpring(duration: 0.2)) {
            countdown.elapsedSeconds = 0
        }
    }

    private func stopTimer() {
        isTimerRunning = false
        resetCountdown()
    }

    private func startTimer() {
        withAnimation(.interactiveSpring(duration: 0.2)) {
            isTimerRunning.toggle()
        }
    }
}

#Preview {
    ContentView()
}
