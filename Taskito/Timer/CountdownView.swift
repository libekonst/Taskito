//
//  CountdownView.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 22/3/24.
//

import SwiftUI

// Single-prop keyboard shortcut wrapper (matches our KeyboardShortcuts constants)
typealias ShortcutTuple = (key: KeyEquivalent, modifiers: EventModifiers)

struct CountdownView: View {
    var secondsRemaining: Int
    var onPlayPause: () -> Void
    var onReset: () -> Void
    var onRestart: () -> Void
    var onAddTime: (Int) -> Void
    var isTimerRunning: Bool
    var timerPolicy: TimerPolicy

    @State private var timeAddedTrigger = false

    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 0) {
                Text(timerPolicy.toReadableTime(seconds: secondsRemaining))
                    .font(.system(size: 146, weight: .thin, design: .rounded))
                    .foregroundStyle(Color.primary.opacity(isTimerRunning ? 1 : 0.6))
                    .scaleEffect({
                        let baseScale = isTimerRunning ? 1.0 : 0.8
                        return timeAddedTrigger ? baseScale + 0.04 : baseScale
                    }())
                    .animation(.spring(response: 0.25, dampingFraction: 0.7), value: timeAddedTrigger)
                    .animation(.spring(response: isTimerRunning ? 0.45 : 0.6, dampingFraction: isTimerRunning ? 0.7 : 0.8), value: isTimerRunning)
                    .padding(.bottom, -4)
                    .overlay(alignment: .bottom) {
                        // Paused indicator (positioned absolutely to not affect layout)
                        Text("PAUSED")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)
                            .tracking(1.5)
                            .offset(y: -16)
                            .opacity(isTimerRunning ? 0 : 0.6)
                            .scaleEffect(isTimerRunning ? 0.8 : 1)
                            .animation(.spring(response: 0.45, dampingFraction: 0.7), value: isTimerRunning)
                    }

                // Time adjustment buttons - visually grouped with timer
                HStack(spacing: 12) {
                    TimeAdjustButton(
                        label: "+1 min",
                        tooltip: "Add 1 Minute (+)",
                        shortcut: AppKeyboardShortcuts.addOneMinute,
                        action: { addTimeWithAnimation(60) }
                    )

                    TimeAdjustButton(
                        label: "+3 min",
                        tooltip: "Add 3 Minutes (⇧+)",
                        shortcut: AppKeyboardShortcuts.addThreeMinutes,
                        action: { addTimeWithAnimation(180) }
                    )
                }
            }.padding(.top, 18)
            Spacer()
            PlayPauseButton(
                isTimerRunning: isTimerRunning,
                action: onPlayPause
            ).padding(.bottom, 18)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .topLeading) {
            ResetButton(action: onReset)
                .padding(12)
        }
        .overlay(alignment: .topTrailing) {
            RestartButton(action: onRestart)
                .padding(12)
        }
    }

    private func addTimeWithAnimation(_ seconds: Int) {
        onAddTime(seconds)

        // Brief scale pulse
        timeAddedTrigger = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            timeAddedTrigger = false
        }
    }
}

private struct PlayPauseButton: View {
    let isTimerRunning: Bool
    let action: () -> Void
    @State private var isHovered = false
    @FocusState private var isFocused: Bool

    var body: some View {
        Button(action: action) {
            ZStack {
                Image(systemName: "play.fill")
                    .font(.system(size: 22, weight: .medium))
                    .opacity(isTimerRunning ? 0 : 1)
                    .scaleEffect(isTimerRunning ? 0.5 : 1)

                Image(systemName: "stop.fill")
                    .font(.system(size: 26, weight: .medium))
                    .opacity(isTimerRunning ? 1 : 0)
                    .scaleEffect(isTimerRunning ? 1 : 0.5)
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isTimerRunning)
            .frame(width: 28, height: 28)
            .padding(18)
            .background(
                ZStack {
                    // Subtle fill on hover/focus
                    if isHovered || isFocused {
                        Circle()
                            .fill(Color.primary.opacity(0.08))
                    }

                    // Border
                    Circle()
                        .strokeBorder(
                            Color.primary.opacity((isHovered || isFocused) ? 0.35 : 0.20),
                            lineWidth: 1.5
                        )
                }
                .animation(.easeInOut(duration: 0.15), value: isHovered)
                .animation(.easeInOut(duration: 0.2), value: isFocused)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 1)
        }
        .buttonStyle(.plain)
        .focused($isFocused)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
        .help(isTimerRunning ? "Pause (Space)" : "Play (Space)")
        .background(
            // Hidden button for play/pause
            Button("") {
                action()
            }
            .appKeyboardShortcut(AppKeyboardShortcuts.playPause)
            .hidden()
        )
    }
}

private struct TimeAdjustButton: View {
    let label: String
    let tooltip: String
    let shortcut: ShortcutTuple
    let action: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(
                    ZStack {
                        // Subtle fill on hover
                        if isHovered {
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(Color.primary.opacity(0.06))
                        }

                        // Border
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .strokeBorder(
                                Color.primary.opacity(isHovered ? 0.25 : 0.15),
                                lineWidth: 1
                            )
                    }
                )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
        .help(tooltip)
        .background(
            Button("") {
                action()
            }
            .appKeyboardShortcut(shortcut)
            .hidden()
        )
    }
}

private struct ResetButton: View {
    let action: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(role: .cancel, action: action) {
            Image(systemName: "xmark")
                .font(.system(size: 14, weight: .medium))
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(Color.primary.opacity(isHovered ? 0.06 : 0))
                )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
        .help("Cancel Timer (⌃C)")
        .background(
            // Hidden button for cancel timer
            Button("") {
                action()
            }
            .appKeyboardShortcut(AppKeyboardShortcuts.cancelTimer)
            .hidden()
        )
    }
}

private struct RestartButton: View {
    let action: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            Image(systemName: "arrow.clockwise")
                .font(.system(size: 14, weight: .medium))
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(Color.primary.opacity(isHovered ? 0.06 : 0))
                )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
        .help("Restart Timer (⌘R)")
        .background(
            Button("") {
                action()
            }
            .appKeyboardShortcut(AppKeyboardShortcuts.restartTimer)
            .hidden()
        )
    }
}

#Preview {
    struct StatefulPreview: View {
        @State var isTimerRunning = true
        @State var timeRemaining = 90

        var body: some View {
            CountdownView(
                secondsRemaining: timeRemaining,
                onPlayPause: { isTimerRunning.toggle() },
                onReset: {
                    print("X tapped", Date())
                },
                onRestart: {
                    timeRemaining = 90
                    print("Restart tapped", Date())
                },
                onAddTime: { seconds in
                    timeRemaining += seconds
                    print("Added \(seconds) seconds")
                },
                isTimerRunning: isTimerRunning,
                timerPolicy: StandardTimerPolicy()
            )
        }
    }

    return StatefulPreview()
}
