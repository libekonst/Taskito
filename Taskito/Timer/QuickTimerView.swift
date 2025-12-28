//
//  QuickTimerView.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 26/12/24.
//

import SwiftUI

/// Minimal quick-entry view for starting timers via global shortcut
struct QuickTimerView: View {
    @ObservedObject var countdownStore: CountdownStore
    var timerPolicy: TimerPolicy

    @Environment(\.dismiss) private var dismiss

    @AppStorage(AppStorageKeys.latestMinutes) private var minutes = 25
    @AppStorage(AppStorageKeys.latestSeconds) private var seconds = 0

    var body: some View {
        VStack {
            // Show different content based on timer state
            if countdownStore.timerState == .running || countdownStore.timerState == .paused {
                RunningTimerView(countdownStore: countdownStore, timerPolicy: timerPolicy)

            } else {
                // Timer setup view
                TimerFormView(
                    minutes: $minutes,
                    seconds: $seconds,
                    timerPolicy: timerPolicy,
                    variant: .medium
                ) {
                    startTimer(minutes: minutes, seconds: seconds)
                }
            }
        }
        .padding(24)
        .frame(width: 300)
        .background(
            // ESC keyboard shortcut to close window
            Button("") {
                dismiss()
            }
            .keyboardShortcut(.escape, modifiers: [])
            .hidden()
        )
    }

    private func startTimer(minutes: Int, seconds: Int) {
        switch countdownStore.startNewTimer(minutes: minutes, seconds: seconds) {
        case .success:
            dismiss()

        case .failure(.invalidDuration):
            // Should not happen due to UI validation, but handle gracefully
            break

        case .failure(.timerAlreadyRunning):
            // Timer is already running - user sees the running timer view
            // No action needed
            break
        }
    }
}

private struct RunningTimerView: View {
    @ObservedObject var countdownStore: CountdownStore
    var timerPolicy: TimerPolicy
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            // Countdown display
            Text(timerPolicy.toReadableTime(seconds: countdownStore.secondsRemaining))
                .font(.system(size: 72, weight: .thin, design: .rounded))
                .foregroundStyle(.primary)

            VStack(spacing: 4) {
                // Status text
                Text(countdownStore.timerState == .running ? "Timer Running" : "Timer Paused")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)

                // Info text
                Text("Manage this timer from the menu bar")
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button(action: {
                dismiss()
            }) {
                Text("CLOSE")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .tracking(0.5)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 40)
                    .background(
                        Capsule(style: .continuous)
                            .fill(Color.primary.opacity(0.08))
                    )
            }
            .keyboardShortcut(.defaultAction)
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    QuickTimerView(
        countdownStore: CountdownStore(),
        timerPolicy: StandardTimerPolicy()
    )
}
