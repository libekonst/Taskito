//
//  CountdownView.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 22/3/24.
//

import SwiftUI

struct CountdownView: View {
    var secondsRemaining: Int
    var onPlayPause: () -> Void
    var onReset: () -> Void
    var onAddTime: (Int) -> Void
    var isTimerRunning: Bool
    var timerPolicy: TimerPolicy

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 16) {
                Spacer()
                VStack(spacing: 0) {
                    Text(timerPolicy.toReadableTime(seconds: secondsRemaining))
                        .font(.system(size: 120, weight: .thin, design: .rounded))
                        .foregroundStyle(Color.primary.opacity(isTimerRunning ? 1 : 0.6))
                        .scaleEffect(isTimerRunning ? 1.0 : 0.85)
                        .animation(.spring(response: isTimerRunning ? 0.4 : 0.6, dampingFraction: isTimerRunning ? 0.65 : 0.8), value: isTimerRunning)

                    // Time adjustment buttons - visually grouped with timer
                    HStack(spacing: 12) {
                        TimeAdjustButton(label: "+1 min", action: {
                            onAddTime(60)
                        })

                        TimeAdjustButton(label: "+3 min", action: {
                            onAddTime(180)
                        })
                    }
                }
                .padding(.bottom, 26)

                PlayPauseButton(
                    isTimerRunning: isTimerRunning,
                    action: onPlayPause
                ).padding(.bottom, 22)

//                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            ResetButton(action: onReset)
                .padding(12)
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
            Image(systemName: isTimerRunning ? "stop.fill" : "play.fill")
                .font(.system(size: 18, weight: .medium))
                .frame(width: 24, height: 24)
                .padding(.leading, isTimerRunning ? 0 : 2)
                .padding(18)
                .id(isTimerRunning)
                .transition(.scale.animation(.interpolatingSpring))
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
    }
}

private struct TimeAdjustButton: View {
    let label: String
    let action: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
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
    }
}

#Preview {
    struct StatefulPreview: View {
        @State var isTimerRunning = false
        @State var timeRemaining = 90

        var body: some View {
            CountdownView(
                secondsRemaining: timeRemaining,
                onPlayPause: { isTimerRunning.toggle() },
                onReset: {
                    print("X tapped", Date())
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
