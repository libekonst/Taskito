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
                    .font(.system(size: 60, weight: .thin, design: .rounded))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)

                Spacer()

                Image(systemName: isTimerRunning ? "stop.fill" : "play.fill")
                    .resizable()
                    .frame(width: 16, height: 16)
                    .id(isTimerRunning)
                    .transition(.scale.animation(.interpolatingSpring))
            }
            .frame(maxWidth: .infinity,
                   maxHeight: .infinity)
            .padding(.bottom, 12)
            .contentShape(Rectangle())
            .onTapGesture {
                onPlayPause()
            }

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

//        .blur(radius: 1)
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
