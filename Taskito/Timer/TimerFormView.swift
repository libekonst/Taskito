//
//  TimerInputView.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 28/12/25.
//

import SwiftUI

struct TimerFormView: View {
    @Binding var minutes: Int
    @Binding var seconds: Int

    let timerPolicy: TimerPolicy
    let config: Variant
    let onSubmit: () -> Void

    @FocusState private var focusedField: FocusedField?

    private enum FocusedField: Hashable {
        case minutes, seconds
    }

    struct Variant {
        enum ButtonSize { case small, large }
        let fontSize: CGFloat
        let fontWeight: Font.Weight
        let spacing: CGFloat
        let buttonSize: ButtonSize

        /// Large style for main form view
        static let large = Variant(
            fontSize: 120,
            fontWeight: .thin,
            spacing: -8,
            buttonSize: .large
        )

        /// Medium style for quick timer view
        static let medium = Variant(
            fontSize: 58,
            fontWeight: .thin,
            spacing: 4,
            buttonSize: .small
        )
    }

    init(
        minutes: Binding<Int>,
        seconds: Binding<Int>,
        timerPolicy: TimerPolicy,
        variant: Variant,
        onSubmit: @escaping () -> Void
    ) {
        self._minutes = minutes
        self._seconds = seconds
        self.timerPolicy = timerPolicy
        self.config = variant
        self.onSubmit = onSubmit
    }

    var body: some View {
        Form {
            VStack {
                HStack(alignment: .top, spacing: config.spacing) {
                    VStack(spacing: 4) {
                        Text("Minutes")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .trailing)

                        TextField(
                            "Minutes",
                            value: $minutes,
                            formatter: timerPolicy.minutesFormatter
                        )
                        .labelsHidden()
                        .textFieldStyle(.plain)
                        .font(.system(size: config.fontSize, weight: config.fontWeight, design: .rounded))
                        .multilineTextAlignment(.trailing)
                        .focused($focusedField, equals: .minutes)
                    }

                    Text(":")
                        .font(.system(size: config.fontSize, weight: .thin, design: .rounded))
                        .foregroundStyle(.secondary)
                        .frame(height: config.fontSize)
                        .padding(.top, 15)

                    VStack(spacing: 4) {
                        Text("Seconds")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        TextField(
                            "Seconds",
                            value: $seconds,
                            formatter: timerPolicy.secondsFormatter
                        )
                        .labelsHidden()
                        .textFieldStyle(.plain)
                        .font(.system(size: config.fontSize, weight: config.fontWeight, design: .rounded))
                        .multilineTextAlignment(.leading)
                        .focused($focusedField, equals: .seconds)
                    }
                }
                .onAppear {
                    // Auto-focus minutes field when view appears
                    DispatchQueue.main.async {
                        focusedField = .minutes
                    }
                }
                .onChange(of: minutes) {
                    // Switch to seconds field when minutes reaches digit limit
                    if String(minutes).count >= timerPolicy.minutesLimits.digitCount {
                        focusedField = .seconds
                    }
                }
                .onSubmit {
                    onSubmit()
                }

                HStack {
                    Spacer()
                    StartButton(size: config.buttonSize, action: onSubmit)
                    Spacer()
                }
                .padding(.top, 4)
            }
        }
    }
}

private struct StartButton: View {
    let size: TimerFormView.Variant.ButtonSize
    let action: () -> Void
    @State private var isHovered = false
    @FocusState private var isFocused: Bool

    @Environment(\.colorScheme) private var colorScheme

    private var activeGradientColors: [Color] {
        if colorScheme == .dark {
            return [
                Color(red: 106/255, green: 86/255, blue: 163/255), // #6A56A3
                Color(red: 58/255, green: 138/255, blue: 122/255) // #3A8A7A
            ]
        } else {
            return [
                Color(red: 220/255, green: 198/255, blue: 250/255), // #DCC6FA
                Color(red: 190/255, green: 237/255, blue: 226/255) // #BEEDE2
            ]
        }
    }

    var body: some View {
        Button(action: action) {
            Text("START")
                .font(.system(size: size == .large ? 20 : 16, weight: .semibold, design: .rounded))
                .tracking(size == .large ? 0.6 : 0.5)
                .padding(.vertical, size == .large ? 12 : 10)
                .padding(.horizontal, size == .large ? 56 : 40)
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
