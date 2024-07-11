//
//  MenuBarLabel.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 28/4/24.
//

import SwiftUI

struct MenuBarLabel: View {
    @ObservedObject var countdownStore: CountdownStore
    @State private var view: ViewState = .idle
    var timerPolicy: TimerPolicy

    var body: some View {
        Group {
            switch view {
            case .idle:
                DefaultView()
            case .timerRunning:
                CountingView(timeLeft: timerPolicy.toReadableTime(seconds: countdownStore.secondsRemaining))
            case .timerDone:
                DoneView()
            }
        }.onAppear {
            // TODO: fix onReset should go on .idle view
            countdownStore.onTimerStarted {
                view = .timerRunning
            }

            countdownStore.onTimerCompleted {
                view = .timerDone
            }
        }
    }
}

private struct DefaultView: View {
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
            Image(systemName: "stopwatch")
            Text(timeLeft)
        }
    }
}

private struct DoneView: View {
    var body: some View {
        HStack {
            Image(systemName: "clock.badge.checkmark.fill")
            Text(" Done!")
        }
    }
}

private enum ViewState {
    case idle
    case timerRunning
    case timerDone
}

#Preview {
    VStack {
        Group {
            DefaultView()

            CountingView(timeLeft: "20:15")

            DoneView()
        }
        .padding()
        .background(.gray.opacity(0.1))
        .cornerRadius(8)
    }
    .frame(width: 200, height: 200)
}
