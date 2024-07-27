//
//  MenuBarLabel.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 28/4/24.
//

import SwiftUI

struct MenuBarLabel: View {
    @ObservedObject var countdownStore: CountdownStore
    var timerPolicy: TimerPolicy

    var body: some View {
        if countdownStore.isRunning {
            CountingView(
                timeLeft: timerPolicy.toReadableTime(
                    seconds: countdownStore.secondsRemaining
                )
            )
        }

        else if !countdownStore.isTimerDepleted {
            PauseView(
                timeLeft: timerPolicy.toReadableTime(
                    seconds: countdownStore.secondsRemaining
                )
            )
        }

        else if countdownStore.isTimerDepleted {
            FlashingDoneView()
        }

        else {
            IdleView()
        }
    }
}

private struct IdleView: View {
    var body: some View {
        HStack {
            Image(systemName: "stopwatch")
            Text("Taskito")
        }
    }
}

private struct CountingView: View {
    var timeLeft: String

    var body: some View {
        HStack {
            Image(systemName: "stopwatch.fill")
            Text(timeLeft)
        }
    }
}

private struct PauseView: View {
    var timeLeft: String

    var body: some View {
        HStack {
            Image(systemName: "stopwatch")
            Text(timeLeft + " ᶘ ᵒᴥᵒᶅ")
        }
    }
}

private struct FlashingDoneView: View {
    @State private var isShowingClockView = false
    @State private var isTimerActive = true

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack {
            Image(systemName: "stopwatch")
            if isTimerActive && !isShowingClockView {
                Text(" ٩(ˊᗜˋ*)ﾉ")
            }
            else {
                Text("00:00")
            }
        }
        .onReceive(timer, perform: { _ in
            isShowingClockView.toggle()
        })
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 7.8) {
                invalidateTimer()
            }
        }
        .onDisappear {
            invalidateTimer()
        }
        .onTapGesture { // TODO: invalidate when the window opens
            invalidateTimer()
        }
    }

    private func invalidateTimer() {
        isTimerActive = false
        timer.upstream.connect().cancel()
    }
}

#Preview {
    VStack {
        Group {
            IdleView()

            CountingView(timeLeft: "20:15")

            PauseView(timeLeft: "19:23")

            FlashingDoneView()
        }
        .padding()
        .background(.gray.opacity(0.1))
        .cornerRadius(8)
    }
    .frame(width: 200, height: 400)
}
