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

    @AppStorage("latestMinutesSelection") private var minutes = 25
    @AppStorage("latestSecondsSelection") private var seconds = 0

    @FocusState private var focusedField: FocusedField?

    @State private var pendingTimerMinutes: Int?
    @State private var pendingTimerSeconds: Int?

    var body: some View {
        VStack(spacing: 20) {
            // Title
            Text("Quick Timer")
                .font(.system(size: 20, weight: .semibold, design: .rounded))

            // Show different content based on timer state
            if countdownStore.timerState == .running || countdownStore.timerState == .paused {
                // Running timer view
                VStack(spacing: 16) {
                    // Countdown display
                    Text(timerPolicy.toReadableTime(seconds: countdownStore.secondsRemaining))
                        .font(.system(size: 56, weight: .thin, design: .rounded))
                        .foregroundStyle(countdownStore.timerState == .running ? .primary : .secondary)

                    // Status text
                    Text(countdownStore.timerState == .running ? "Timer Running" : "Timer Paused")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)

                    // Info text
                    Text("Manage this timer from the menu bar")
                        .font(.system(size: 11, weight: .regular, design: .rounded))
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)

                    // Close button
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
            } else {
                // Timer setup view
                VStack(spacing: 24) {
                    // Timer input
                    HStack(spacing: 12) {
                        VStack(spacing: 8) {
                            Text("Minutes")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundStyle(.secondary)

                            TextField("0", value: $minutes, formatter: timerPolicy.formatter)
                                .textFieldStyle(.roundedBorder)
                                .font(.system(size: 48, weight: .medium, design: .rounded))
                                .multilineTextAlignment(.center)
                                .frame(width: 100)
                                .focused($focusedField, equals: .minutes)
                        }

                        Text(":")
                            .font(.system(size: 48, weight: .thin, design: .rounded))
                            .foregroundStyle(.secondary)
                            .padding(.top, 20)

                        VStack(spacing: 8) {
                            Text("Seconds")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundStyle(.secondary)

                            TextField("0", value: $seconds, formatter: timerPolicy.formatter)
                                .textFieldStyle(.roundedBorder)
                                .font(.system(size: 48, weight: .medium, design: .rounded))
                                .multilineTextAlignment(.center)
                                .frame(width: 100)
                                .focused($focusedField, equals: .seconds)
                        }
                    }

                    // Start button
                    Button(action: {
                        startTimer(minutes: minutes, seconds: seconds)
                    }) {
                        Text("START")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .tracking(0.5)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 50)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(Color.accentColor)
                            )
                            .foregroundStyle(.white)
                    }
                    .keyboardShortcut(.defaultAction)
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(24)
        .frame(width: 300)
        .onAppear {
            // Auto-focus minutes field when view appears
            DispatchQueue.main.async {
                focusedField = .minutes
            }
        }
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
        // Check if a timer is already running
        if countdownStore.timerState == .running || countdownStore.timerState == .paused {
            // Store pending timer and show alert
            pendingTimerMinutes = minutes
            pendingTimerSeconds = seconds
        } else {
            // No conflict, start immediately
            countdownStore.startNewTimer(minutes: minutes, seconds: seconds)
            dismiss()
        }
    }

    private func confirmStartTimer() {
        guard let minutes = pendingTimerMinutes,
              let seconds = pendingTimerSeconds else { return }

        countdownStore.startNewTimer(minutes: minutes, seconds: seconds)

        // Clear pending state
        pendingTimerMinutes = nil
        pendingTimerSeconds = nil
        dismiss()
    }
}

private enum FocusedField: Hashable {
    case minutes, seconds
}

#Preview {
    QuickTimerView(
        countdownStore: CountdownStore(),
        timerPolicy: StandardTimerPolicy()
    )
}
