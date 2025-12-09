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
    var isTimerRunning: Bool
    var timerPolicy: TimerPolicy

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 0) {
                Spacer()
                Spacer()

                Text(timerPolicy.toReadableTime(seconds: secondsRemaining))
                    .font(.system(size: 120, weight: .thin, design: .rounded))

                PlayPauseButton(
                    isTimerRunning: isTimerRunning,
                    action: onPlayPause
                )
                .padding(.top, 40)

                Spacer()
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
                .frame(width: 18, height: 18)
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
        let timeRemaining = 90

        var body: some View {
            CountdownView(
                secondsRemaining: timeRemaining,
                onPlayPause: { isTimerRunning.toggle() },
                onReset: {
                    print("X tapped", Date())
                },
                isTimerRunning: isTimerRunning,
                timerPolicy: StandardTimerPolicy()
            )
        }
    }

    return StatefulPreview()
}
