//
//  MenuBarLabel.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 28/4/24.
//

import SwiftUI

struct MenuBarLabel: View {
    var body: some View {
        DefaultView()
    }
}

private struct DefaultView: View {
    var body: some View {
        HStack {
            Image(systemName: "stopwatch")
            Text("Taskito")
        }
    }
}

private struct CountingView: View {
    var timeLeft: String = "Taskito"

    var body: some View {
        HStack {
            Image(systemName: "stopwatch")
            Text(timeLeft)
        }
    }
}

private struct DoneView: View {
    var body: some View {
        HStack {
            Image(systemName: "clock.badge.checkmark.fill")
            Text(" Done!")
        }
    }
}

#Preview {
    VStack {
        Group {
            DefaultView()

            CountingView(timeLeft: "20:15")

            DoneView()
        }
        .padding()
        .background(.gray.opacity(0.1))
        .cornerRadius(8)
    }
    .frame(width: 200, height: 200)
}
