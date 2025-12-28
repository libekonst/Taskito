//
//  ShortcutRecorderSheet.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 27/12/25.
//

import SwiftUI
import KeyboardShortcuts

struct ShortcutRecorderSheet: View {
    let onCancel: () -> Void
    let onSave: () -> Void

    @State private var temporaryShortcut: KeyboardShortcuts.Shortcut?

    init(onCancel: @escaping () -> Void, onSave: @escaping () -> Void) {
        self.onCancel = onCancel
        self.onSave = onSave
        // Initialize with current shortcut
        _temporaryShortcut = State(initialValue: KeyboardShortcuts.getShortcut(for: .toggleAppWindow))
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Customize Global Shortcut")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .padding(.top, 20)

            VStack(alignment: .leading, spacing: 12) {
                Text("Set your preferred keyboard shortcut to open Taskito from anywhere.")
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                KeyboardShortcuts.Recorder(for: .toggleAppWindow) {
                    Text("Show App Window:")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                }
                .padding(.top, 8)

                Text("This shortcut works system-wide, even when Taskito is in the background.")
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundStyle(.tertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 20)

            Spacer()

            // Buttons
            HStack(spacing: 12) {
                Button("Cancel") {
                    // Restore original shortcut
                    KeyboardShortcuts.setShortcut(temporaryShortcut, for: .toggleAppWindow)
                    onCancel()
                }
                .keyboardShortcut(.cancelAction)

                Button("Save") {
                    // Shortcut is already saved in real-time by Recorder
                    onSave()
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding(.bottom, 20)
        }
        .frame(width: 400, height: 300)
    }
}

#Preview {
    ShortcutRecorderSheet(
        onCancel: {},
        onSave: {}
    )
}
