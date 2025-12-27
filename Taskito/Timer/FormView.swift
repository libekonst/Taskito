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

    @FocusState private var focus: FocusedField?

    var body: some View {
        VStack {
            // Preset Buttons
            PresetButtonsView(
                presets: presetsStore.presets,
                onPresetSelected: { preset in
                    minutes = preset.minutes
                    seconds = preset.seconds
                    onSubmit()
                }
            )
            .padding(.top, 14)

            Spacer()
            Form {
                VStack {
                    // Input
                    HStack(alignment: .top, content: {
                        TextField(
                            "Minutes",
                            value: $minutes,
                            formatter: timerPolicy.formatter
                        )
                        .textFieldStyle(PlainNumericInputStyle(justify: .trailing))
                        .focused($focus, equals: .minutes)

                        Text(":")
                            .font(.system(size: 120, weight: .thin, design: .rounded))
                            .frame(height: 120)
                            .padding(.horizontal, -8)

                        TextField(
                            "Seconds",
                            value: $seconds,
                            formatter: timerPolicy.formatter
                        )
                        .textFieldStyle(PlainNumericInputStyle())
                        .focused($focus, equals: .seconds)
                    })

                    // Submit
                    HStack {
                        Spacer()

                        StartButton(action: onSubmit)

                        Spacer()
                    }
                    .padding(.top, 4)
                }
            }
            .onChange(of: minutes) {
                if String(minutes).count >= timerPolicy.limits.digitCount {
                    focus = .seconds
                }
            }
            .onSubmit {
                onSubmit()
            }

            Spacer()
        }
        .onAppear {
            // Delay to ensure TextField is ready before setting focus
            DispatchQueue.main.async {
                focus = .minutes
            }
        }
    }
}

private enum FocusedField: Hashable {
    case minutes, seconds
}

private struct PlainNumericInputStyle: TextFieldStyle {
    var justify: TextAlignment = .leading

    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .labelsHidden()
            .textFieldStyle(.plain)
            .font(.system(size: 120, weight: .thin, design: .rounded))
            .multilineTextAlignment(justify)
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

private struct StartButton: View {
    let action: () -> Void
    @State private var isHovered = false
    @FocusState private var isFocused: Bool

    @Environment(\.colorScheme) private var colorScheme

    private var activeGradientColors: [Color] {
        if colorScheme == .dark {
            return [
                Color(red: 90/255, green: 159/255, blue: 134/255), // #5A9F86
                Color(red: 94/255, green: 127/255, blue: 154/255), // #5E7F9A
                Color(red: 81/255, green: 64/255, blue: 168/255)   // #5140A8

            ]
        } else {
            return [
                Color(red: 167/255, green: 220/255, blue: 201/255), // #A7DCC9
                Color(red: 169/255, green: 199/255, blue: 226/255), // #A9C7E2
                Color(red: 180/255, green: 169/255, blue: 242/255)  // #B4A9F2

            ]
        }
    }

    var body: some View {
        Button(action: action) {
            Text("START")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .tracking(0.6)
                .padding(.vertical, 12)
                .padding(.horizontal, 56)
                .background(
                    Capsule(style: .continuous)
                        .fill(
                            (isHovered || isFocused) ?
                                LinearGradient(
                                    colors: activeGradientColors,
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) :
                                LinearGradient(
                                    colors: [
                                        Color.primary.opacity(0.09),
                                        Color.primary.opacity(0.09)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                        )
                        .animation(.easeInOut(duration: 0.2), value: isFocused)
                        .animation(.easeInOut(duration: 0.15), value: isHovered)
                )
                .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 1)
        }
        .keyboardShortcut(.defaultAction)
        .buttonStyle(.plain)
        .focused($isFocused)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
        .help("Start Timer (Enter)")
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
