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

    var body: some View {
        VStack {
            VStack {
                Spacer()
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

                        Button(
                            action: {
                                onSubmit()
                            },
                            label: {
                                Text("START")
                                    .padding(.vertical, 6)
                                    .padding(.horizontal)
                                    .background(.black.opacity(0.1))
                                    .containerShape(Capsule())
                            }
                        )
                        .keyboardShortcut(.defaultAction)
                        .buttonStyle(.plain)

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

private struct OptionsMenuView: View {
    var body: some View {
        Section {
            HStack {
                Button(action: {
                    NSApplication.shared.terminate(nil)
                }, label: {
                    HStack {
                        Label("Quit", systemImage: "power")
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    .padding(.horizontal, 3)
                })
            }
            .buttonStyle(AccessoryBarButtonStyle())
        }
        .padding(.bottom, 8)
        .padding(.horizontal, 7)
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
