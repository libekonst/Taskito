//
//  CountdownView.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 22/3/24.
//

import SwiftUI

struct CountdownView: View {
    var countdown: Countdown
    var onPlay: () -> Void
    var onPause: () -> Void
    var onStop: () -> Void
    var isTimerRunning: Bool

    var body: some View {
        VStack {
            Button("Reset Timer", systemImage: "pencil", action: onStop)
                .labelStyle(.iconOnly)
                .padding(.all, 8)
                .font(.title2)
                .focusEffectDisabled()
                .buttonStyle(.plain)

            HStack {
                Text(TimeFormatter.formatSeconds(countdown.timeRemaining))
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)
                    .background(.black.opacity(0.75))
                    .clipShape(.capsule)
            }

            Spacer()

            if isTimerRunning {
                Button("Pause") {
                    onPause()
                }
            } else {
                Button("Play") {
                    onPlay()
                }
            }
        }
    }
}

#Preview {
    CountdownView(countdown: Countdown(),
                  onPlay: {},
                  onPause: {},
                  onStop: {},
                  isTimerRunning: false)
}
