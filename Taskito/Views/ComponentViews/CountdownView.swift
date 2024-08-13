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
            VStack {
                Spacer()

                Text(timerPolicy.toReadableTime(seconds: secondsRemaining))
                    .font(.system(size: 84, weight: .thin, design: .rounded))
                    .padding(.vertical, 4)

                Button(action: onPlayPause, label: {
                    VStack {
                        Image(systemName: isTimerRunning ? "stop.fill" : "play.fill")
                            .resizable()
                            .frame(width: 18, height: 18)
                            .padding(.leading, isTimerRunning ? 0 : 4)
                            .id(isTimerRunning)
                            .transition(.scale.animation(.interpolatingSpring))
                    }.padding(20)
                        .background(.black.opacity(0.1))
                        .transition(.opacity.animation(.easeInOut))
                        .clipShape(.circle)
                })
                .buttonStyle(.plain)
                .labelStyle(.iconOnly)

                Spacer()
            }
            .frame(maxWidth: .infinity,
                   maxHeight: .infinity)

            Button(role: .cancel, action: onReset, label: {
                Image(systemName: "xmark")
                    .frame(minWidth: 36, minHeight: 36)
                    .contentShape(Rectangle())
                    .font(.system(size: 14))
            })
            .buttonStyle(.plain)
            .labelStyle(.iconOnly)
            .focusEffectDisabled()
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
