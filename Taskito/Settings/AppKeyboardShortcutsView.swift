//
//  KeyboardShortcutsView.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 13/12/25.
//

import SwiftUI

struct AppKeyboardShortcutsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            Text("Keyboard Shortcuts")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .padding(.bottom, 24)

            // Shortcuts sections
            VStack(alignment: .leading, spacing: 20) {
                // System global shortcuts
                if !AppKeyboardShortcuts.systemGlobal.isEmpty {
                    ShortcutSection(title: "System-Wide", shortcuts: AppKeyboardShortcuts.systemGlobal)
                }

                // Global shortcuts
                if !AppKeyboardShortcuts.global.isEmpty {
                    ShortcutSection(title: "Global", shortcuts: AppKeyboardShortcuts.global)
                }

                // Form view shortcuts
                if !AppKeyboardShortcuts.formView.isEmpty {
                    ShortcutSection(title: "Timer Setup", shortcuts: AppKeyboardShortcuts.formView)
                }

                // Countdown view shortcuts
                if !AppKeyboardShortcuts.countdownView.isEmpty {
                    ShortcutSection(title: "During Timer", shortcuts: AppKeyboardShortcuts.countdownView)
                }
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

private struct ShortcutSection: View {
    let title: String
    let shortcuts: [AppKeyboardShortcut]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(0.5)

            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(shortcuts.enumerated()), id: \.offset) { index, shortcut in
                    HStack(spacing: 12) {
                        // Shortcut keys as individual components
                        HStack(spacing: 4) {
                            // Display modifier keys individually
                            ForEach(Array(shortcut.modifiers), id: \.self) { modifier in
                                KeyIcon(label: String(modifier))
                            }

                            // Display main key
                            KeyIcon(label: shortcut.key)
                        }
                        .frame(minWidth: 90, alignment: .leading)

                        // Description
                        Text(shortcut.description)
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundStyle(.primary)

                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 16)

                    if index < shortcuts.count - 1 {
                        Divider()
                            .padding(.leading, 16)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.primary.opacity(0.03))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.5)
            )
        }
    }
}

private struct KeyIcon: View {
    let label: String

    var body: some View {
        Text(label)
            .font(.system(size: 13, weight: .medium, design: .monospaced))
            .foregroundStyle(.primary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(Color.primary.opacity(0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.12), lineWidth: 0.5)
            )
    }
}

#Preview {
    AppKeyboardShortcutsView()
        .frame(width: 600, height: 500)
}
