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
        switch countdownStore.timerState {
        case .completed:
            FlashingDoneView()
        case .cancelled:
            IdleView()
        case .idle:
            IdleView()
        case .running:
            CountingView(
                timeLeft: timerPolicy.toReadableTime(
                    seconds: countdownStore.secondsRemaining
                )
            )
        case .paused:
            PauseView(
                timeLeft: timerPolicy.toReadableTime(
                    seconds: countdownStore.secondsRemaining
                )
            )
        }
    }
}

private struct IdleView: View {
    var body: some View {
        HStack {
            Text("(｡◕‿◕｡)")
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
            Image(systemName: "clock.badge")
            Text(timeLeft)
        }
    }
}

private struct DoneView: View {
    var body: some View {
        HStack {
            Text("٩(ˊᗜˋ)ﾉ")
        }
    }
}

private struct FlashingDoneView: View {
    @State private var isShowingClockView = false
    @State private var runCount = 0

    let timer = Timer.publish(every: 1, tolerance: 7800, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack {
            Image(systemName: "stopwatch")
            if isShowingClockView {
                Text("00:00")
            }
            else {
                Text(" ٩(ˊᗜˋ)ﾉ")
            }
        }
        .onReceive(timer) { _ in
            runCount += 1
            isShowingClockView.toggle()

            if runCount == 5 {
                timer.upstream.connect().cancel()
            }
        }
    }
}

#Preview {
    VStack {
        Group {
            IdleView()

            CountingView(timeLeft: "20:15")

            PauseView(timeLeft: "19:23")
            
            DoneView()

            FlashingDoneView()
        }
        .padding()
        .background(.gray.opacity(0.1))
        .cornerRadius(8)
    }
    .frame(width: 200, height: 400)
}
