//
//  ContentView.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 12/3/24.
//

import SwiftUI

// TODO: add both minutes and seconds input
struct ContentView: View {
    @State private var timeElapsed = 0
    @State private var isCounting = false

    @ObservedObject private var countdown = Countdown()

    var secondsRemaining: Int {
        guard timeElapsed < countdown.secondsTotal else { return 0 }

        return countdown.secondsTotal - timeElapsed
    }

    var isFreshTimer: Bool {
        return !isCounting && timeElapsed == 0
    }

    var formattedTime: String {
        return TimeFormatter.formatSeconds(secondsRemaining)
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
                    Text(formattedTime)
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

                if isCounting {
                    Button("Pause") {
                        pauseTimer()
                    }
                }
            }
        }
        .padding()
        .onReceive(timer) { time in
            guard isCounting else { return }

            guard timeElapsed < countdown.secondsTotal else {
                return pauseTimer()
            }

            timeElapsed += 1
            print(time)
        }
    }

    private func resetCountdown() {
        timeElapsed = 0
    }

    private func pauseTimer() {
        isCounting = false
    }

    private func stopTimer() {
        pauseTimer()
        timeElapsed = 0
    }

    private func startTimer() {
        isCounting = true
    }
}

#Preview {
    ContentView()
}
