//
//  CountdownView.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 22/3/24.
//

import SwiftUI

struct CountdownView: View {
    var timeRemaining: Int
    var onPlayPause: () -> Void
    var onStop: () -> Void
    var isTimerRunning: Bool

    var body: some View {
        VStack(alignment: .trailing) {
            Button(action: onStop, label: {
                Image(systemName: "xmark")
                    .frame(minWidth: 36, minHeight: 36)
                    .contentShape(Rectangle())
                    .font(.system(size: 16))
            })
            .buttonStyle(.plain)
            .labelStyle(.iconOnly)
            .padding([.trailing, .top], 3)
            .focusEffectDisabled()
            



            VStack {
                Spacer()

                Text(TimeFormatter.formatSeconds(timeRemaining))
                    .font(.system(size: 72, weight: .thin, design: .rounded))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)
                    .background(.black.opacity(0.1))
                    .clipShape(.capsule)
                    .offset(CGSize(width: 0, height: -24))

                Spacer()

                Image(systemName: isTimerRunning ? "stop.fill" : "play.fill")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .id(isTimerRunning)
                    .transition(.scale.animation(.interpolatingSpring))
            }
            .frame(maxWidth: .infinity,
                   maxHeight: .infinity)
            .padding(.bottom, 12)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onPlayPause()
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
                timeRemaining: timeRemaining,
                onPlayPause: { isTimerRunning.toggle() },
                onStop: {},
                isTimerRunning: isTimerRunning
            )
        }
    }

    return StatefulPreview()
}
