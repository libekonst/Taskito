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

    @State private var selectedMinutes = 30
    @State private var selectedSeconds = 00
    var totalSecondsCountdown: Int {
        return minutesToSeconds(selectedMinutes) + selectedSeconds
    }

    var secondsRemaining: Int {
        if timeElapsed < totalSecondsCountdown {
            return totalSecondsCountdown - timeElapsed
        }
        else { return 0 }
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
                HStack {
                    TextField("Minutes", value: $selectedMinutes, formatter: TimeFormatter.Restrictions.minutes, onEditingChanged: { _ in
                        resetCountdown()
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    Text(":")
                    TextField("Seconds", value: $selectedSeconds, formatter: TimeFormatter.Restrictions.seconds, onEditingChanged: { _ in
                        resetCountdown()
                    })
                    .padding()
                }
            }

            else { HStack {
                Text(formattedTime)

                Text("\(secondsRemaining)")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)
                    .background(.black.opacity(0.75))
                    .clipShape(.capsule)
                Text(":")
                Text(Date(), style: .date)
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
                else {
                    Button("Play") {
                        startTimer()
                    }
                }
            }
        }
        .padding()
        .onReceive(timer) { time in
            guard isCounting else { return }

            guard timeElapsed < selectedSeconds else {
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

func minutesToSeconds(_ minutes: Int) -> Int {
    return minutes * 60
}



#Preview {
    ContentView()
}
