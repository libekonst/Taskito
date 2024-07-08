//
//  CountdownDurationForm.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 22/3/24.
//

import Combine
import SwiftUI

struct FormView: View {
    var onSubmit: (_ minutes: Int, _ seconds: Int) -> Void
    var timerPolicy: TimerPolicy

    // TODO: remember last selection
    @State private var minutes = 25
    @State private var seconds = 00

    @FocusState private var focus: FocusedField?

    var body: some View {
        VStack {
            Form {
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

                HStack {
                    Spacer()

                    Button(action: {
                        onSubmit(minutes, seconds)
                    }, label: {
                        Text("START")
                            .padding(.vertical, 6)
                            .padding(.horizontal)
                            .background(.black.opacity(0.1))
                            .containerShape(Capsule())
                    })
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
                onSubmit(minutes, seconds)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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

#Preview {
    FormView(onSubmit: { _, _ in
                 print("onSubmit called")
             },
             timerPolicy: StandardTimerPolicy())
}
