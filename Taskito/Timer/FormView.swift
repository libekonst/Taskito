//
//  CountdownDurationForm.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 22/3/24.
//

import Combine
import SwiftUI

struct FormView: View {
    var onSubmit: () -> Void
    @Binding var minutes: Int
    @Binding var seconds: Int
    var timerPolicy: TimerPolicy
    @ObservedObject var presetsStore: PresetTimersStore

    var body: some View {
        VStack {
            // Preset Buttons
            PresetButtonsView(
                presets: presetsStore.presets,
                onPresetSelected: { preset in
                    // Clamp values to valid range for defense against corrupted data
                    minutes = max(timerPolicy.minutesLimits.min, min(timerPolicy.minutesLimits.max, preset.minutes))
                    seconds = max(timerPolicy.secondsLimits.min, min(timerPolicy.secondsLimits.max, preset.seconds))
                    onSubmit()
                }
            )
            .padding(.top, 14)

            Spacer()

            TimerFormView(
                minutes: $minutes,
                seconds: $seconds,
                timerPolicy: timerPolicy,
                variant: .large
            ) {
                onSubmit()
            }

            Spacer()
        }
    }
}

private struct PresetButtonsView: View {
    let presets: [PresetTimer]
    let onPresetSelected: (PresetTimer) -> Void

    @State private var hoveredPreset: UUID?

    var body: some View {
        HStack(spacing: 10) {
            ForEach(Array(presets.enumerated()), id: \.element.id) { index, preset in
                Button(action: {
                    onPresetSelected(preset)
                }, label: {
                    VStack(spacing: 3) {
                        Text(preset.name)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                        Text(formatTime(preset))
                            .font(.system(size: 11, weight: .medium, design: .rounded)).opacity(0.5)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 14)
                    .frame(minWidth: 80)
                    .background(
                        ZStack {
                            // Minimal color accent on hover
                            if hoveredPreset == preset.id {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color(red: 132/255, green: 137/255, blue: 216/255).opacity(0.15))
                            }

                            // Transparent border with subtle color
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .strokeBorder(
                                    Color(red: 132/255, green: 137/255, blue: 216/255).opacity(hoveredPreset == preset.id ? 0.6 : 0.3),
                                    lineWidth: 1
                                )
                        }
                    )
                    .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 1)
                })
                .buttonStyle(.plain)
                .onHover { isHovered in
                    withAnimation(.easeInOut(duration: 0.15)) {
                        hoveredPreset = isHovered ? preset.id : nil
                    }
                }
                .help("Start \(preset.name) (⌘\(index + 1))")
                .background(
                    Group {
                        // Hidden button for preset keyboard shortcut
                        if let shortcut = AppKeyboardShortcuts.preset(at: index) {
                            Button("") {
                                onPresetSelected(preset)
                            }
                            .appKeyboardShortcut(shortcut)
                            .hidden()
                        }
                    }
                )
            }
        }
    }

    private func formatTime(_ preset: PresetTimer) -> String {
        if preset.seconds == 0 {
            return "\(preset.minutes)m"
        } else {
            return "\(preset.minutes)m \(preset.seconds)s"
        }
    }
}

#Preview {
    struct StatefulPreview: View {
        @State var minutes = 1
        @State var seconds = 10
        @StateObject var presetsStore = PresetTimersStore()

        var body: some View {
            FormView(
                onSubmit: {
                    print("onSubmit called")
                },
                minutes: $minutes,
                seconds: $seconds,
                timerPolicy: StandardTimerPolicy(),
                presetsStore: presetsStore
            )
        }
    }

    return StatefulPreview()
}
