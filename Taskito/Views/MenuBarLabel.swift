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

    private var view: ViewState {
        if countdownStore.isRunning {
            return .timerRunning
        }

        if !countdownStore.isTimerDepleted {
            return .timerPaused
        }

        return .idle
    }

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

        else {
            IdleView()
        }
    }
}

private struct IdleView: View {
    var body: some View {
        HStack {
            Image(systemName: "stopwatch")
            Text("Taskito ヾ(＾ᴥ＾)ノ")
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

private enum ViewState {
    case idle
    case timerRunning
    case timerPaused
}

#Preview {
    VStack {
        Group {
            IdleView()

            CountingView(timeLeft: "20:15")

            PauseView(timeLeft: "19:23")
        }
        .padding()
        .background(.gray.opacity(0.1))
        .cornerRadius(8)
    }
    .frame(width: 200, height: 200)
}
