//
//  CountdownDurationForm.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 22/3/24.
//

import SwiftUI

struct CountdownDurationForm: View {
    var onSubmit: (_ minutes: Int, _ seconds: Int) -> Void

    @State private var minutes = 30
    @State private var seconds = 00

    var body: some View {
        Form {
            HStack {
                Section(header: Text("Select time")) {
                    TextField("Minutes", value: $minutes, formatter: TimeFormatter.Restrictions.minutes)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    Text(":")
                    TextField("Seconds", value: $seconds, formatter: TimeFormatter.Restrictions.seconds)
                        .padding()
                }
            }
            Button("Start") {
                print("Play clicked")
                onSubmit(minutes, seconds)
            }
        }.onSubmit {
            print("form submitted")
            onSubmit(minutes, seconds)
        }
    }
}

#Preview {
    CountdownDurationForm(onSubmit: { _, _ in
        print("onSubmit called")
    })
}
