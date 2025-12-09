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

    @FocusState private var focus: FocusedField?
    @StateObject private var presetsStore = PresetTimersStore()

    var body: some View {
        VStack {
            VStack {
                Spacer()

                // Preset Buttons
                PresetButtonsView(
                    presets: presetsStore.presets,
                    onPresetSelected: { preset in
                        minutes = preset.minutes
                        seconds = preset.seconds
                        onSubmit()
                    }
                )
                .padding(.bottom, 8)

                Form {
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
                            .font(.system(size: 72, weight: .thin, design: .rounded))
                            .frame(height: 72)
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
                    .padding(.top)
                }
                .onChange(of: minutes) {
                    if String(minutes).count >= timerPolicy.limits.digitCount {
                        focus = .seconds
                    }
                }
                .onAppear {
                    focus = .minutes
                }
                .onSubmit {
                    onSubmit()
                }

                Spacer()

            }.frame(maxWidth: .infinity, maxHeight: .infinity)

            Divider().padding(.horizontal)
            OptionsMenuView()
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
            .font(.system(size: 72, weight: .thin, design: .rounded))
            .multilineTextAlignment(justify)
    }
}

private struct PresetButtonsView: View {
    let presets: [PresetTimer]
    let onPresetSelected: (PresetTimer) -> Void

    @State private var hoveredPreset: UUID?

    var body: some View {
        HStack(spacing: 10) {
            ForEach(presets) { preset in
                Button(action: {
                    onPresetSelected(preset)
                }, label: {
                    VStack(spacing: 3) {
                        Text(preset.name)
                            .font(.system(size: 11.5, weight: .semibold, design: .rounded))
                        Text(formatTime(preset))
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 14)
                    .frame(minWidth: 80)
                    .background(
                        ZStack {
                            // Minimal color accent on hover
                            if hoveredPreset == preset.id {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color.accentColor.opacity(0.08))
                            }

                            // Transparent border with subtle color
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .strokeBorder(
                                    Color.accentColor.opacity(hoveredPreset == preset.id ? 0.4 : 0.2),
                                    lineWidth: 1
                                )
                        }
                    )
                    .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 1)
                })
                .buttonStyle(.plain)
                .focusable(false)
                .onHover { isHovered in
                    withAnimation(.easeInOut(duration: 0.15)) {
                        hoveredPreset = isHovered ? preset.id : nil
                    }
                }
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

    var body: some View {
        Button(action: action) {
            Text("START")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .tracking(0.6)
                .padding(.vertical, 11)
                .padding(.horizontal, 36)
                .background(
                    ZStack {
                        // Clean material base
                        Capsule(style: .continuous)
                            .fill(.regularMaterial)

                        // Flat color tint
                        Capsule(style: .continuous)
                            .fill(Color.accentColor.opacity(isHovered ? 0.38 : 0.30))
                    }
                )
                .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
        }
        .keyboardShortcut(.defaultAction)
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
}

private struct OptionsMenuView: View {
    var body: some View {
        Section {
            HStack {
                QuitButton()
            }
        }
        .padding(.bottom, 8)
        .padding(.horizontal, 7)
    }
}

private struct QuitButton: View {
    @State private var isHovered = false

    var body: some View {
        Button(action: {
            NSApplication.shared.terminate(nil)
        }) {
            HStack(spacing: 6) {
                Image(systemName: "power")
                    .font(.system(size: 11, weight: .medium))
                Text("Quit")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                Spacer()
            }
            .padding(.vertical, 7)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
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
        @State var minutes = 1
        @State var seconds = 10

        var body: some View {
            FormView(
                onSubmit: {
                    print("onSubmit called")
                },
                minutes: $minutes,
                seconds: $seconds,
                timerPolicy: StandardTimerPolicy()
            )
        }
    }

    return StatefulPreview()
}
