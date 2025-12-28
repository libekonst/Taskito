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
                    TextField(
                        "Minutes",
                        value: $minutes,
                        formatter: timerPolicy.formatter
                    )
                    .labelsHidden()
                    .textFieldStyle(.plain)
                    .font(.system(size: config.fontSize, weight: config.fontWeight, design: .rounded))
                    .multilineTextAlignment(.trailing)
                    .focused($focusedField, equals: .minutes)

                    Text(":")
                        .font(.system(size: config.fontSize, weight: .thin, design: .rounded))
                        .foregroundStyle(.secondary)
                        .frame(height: config.fontSize)

                    TextField(
                        "Seconds",
                        value: $seconds,
                        formatter: timerPolicy.formatter
                    )
                    .labelsHidden()
                    .textFieldStyle(.plain)
                    .font(.system(size: config.fontSize, weight: config.fontWeight, design: .rounded))
                    .multilineTextAlignment(.leading)
                    .focused($focusedField, equals: .seconds)
                }
                .onAppear {
                    // Auto-focus minutes field when view appears
                    DispatchQueue.main.async {
                        focusedField = .minutes
                    }
                }
                .onChange(of: minutes) {
                    // Switch to seconds field when minutes reaches digit limit
                    if String(minutes).count >= timerPolicy.limits.digitCount {
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
                Color(red: 90/255, green: 159/255, blue: 134/255), // #5A9F86
                Color(red: 94/255, green: 127/255, blue: 154/255), // #5E7F9A
                Color(red: 81/255, green: 64/255, blue: 168/255) // #5140A8
            ]
        } else {
            return [
                Color(red: 167/255, green: 220/255, blue: 201/255), // #A7DCC9
                Color(red: 169/255, green: 199/255, blue: 226/255), // #A9C7E2
                Color(red: 180/255, green: 169/255, blue: 242/255) // #B4A9F2
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

