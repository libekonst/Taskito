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
                HStack {
                    Text(TimeFormatter.formatSeconds(countdown.timeRemaining))
                        .font(.largeTitle)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 5)
                        .background(.black.opacity(0.75))
                        .clipShape(.capsule)
                }
            }

            Spacer()
            HStack {
                if !isFreshTimer {
                    Button("Stop") {
                        stopTimer()
                    }
                }

                if isTimerRunning {
                    Button("Pause") {
                        pauseTimer()
                    }
                }
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
        countdown.elapsedSeconds = 0
    }

    private func startTimer() {
        isTimerRunning = true
    }
}

#Preview {
    ContentView()
}
