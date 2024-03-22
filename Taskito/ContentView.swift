//
//  ContentView.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 12/3/24.
//

import SwiftUI

// TODO: add both minutes and seconds input
struct ContentView: View {
    @ObservedObject private var countdown = Countdown()

    @State private var isTimerRunning = false

    // @todo simplify
    var isFreshTimer: Bool {
        return !isTimerRunning && countdown.elapsedSeconds == 0
    }

    let timer = Timer.publish(every: 1, on: .main, in: .common)
        .autoconnect()

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Spacer()

            if isFreshTimer {
                CountdownDurationForm(onSubmit: { minutes, seconds in
                    print("onSubmit")
                    resetCountdown()
                    startTimer()
                    countdown.minutes = minutes
                    countdown.seconds = seconds
                })
            }

            else {
                CountdownView(
                    countdown: countdown,
                    onPlay: startTimer,
                    onPause: pauseTimer,
                    onStop: stopTimer,
                    isTimerRunning: isTimerRunning
                )
            }
        }
        .padding()
        .onReceive(timer) { time in
            guard isTimerRunning else { return }

            guard countdown.timeRemaining > 0 else {
                return pauseTimer()
            }

            countdown.elapsedSeconds += 1
            print(time)
        }
    }

    private func resetCountdown() {
        countdown.elapsedSeconds = 0
    }

    private func pauseTimer() {
        isTimerRunning = false
    }

    private func stopTimer() {
        pauseTimer()
        resetCountdown()
    }

    private func startTimer() {
        isTimerRunning = true
    }
}

#Preview {
    ContentView()
}

