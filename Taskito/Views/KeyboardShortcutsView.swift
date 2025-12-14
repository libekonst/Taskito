//
//  KeyboardShortcutsView.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 13/12/25.
//


import SwiftUI
import AppKit

struct KeyboardShortcutsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Keyboard Shortcuts")
                    .font(.title2.bold())
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Shortcuts list
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Global shortcuts
                    if !KeyboardShortcuts.global.isEmpty {
                        ShortcutSection(title: "Global", shortcuts: KeyboardShortcuts.global)
                    }

                    // Form view shortcuts
                    if !KeyboardShortcuts.formView.isEmpty {
                        ShortcutSection(title: "Timer Setup", shortcuts: KeyboardShortcuts.formView)
                    }

                    // Countdown view shortcuts
                    if !KeyboardShortcuts.countdownView.isEmpty {
                        ShortcutSection(title: "During Timer", shortcuts: KeyboardShortcuts.countdownView)
                    }
                }
                .padding()
            }
        }
        .frame(width: 500, height: 400)
        .background(WindowAccessor(onWindowAvailable: { window in
            window.level = .floating
        }))
    }
}

private struct ShortcutSection: View {
    let title: String
    let shortcuts: [KeyboardShortcut]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)

            VStack(spacing: 6) {
                ForEach(Array(shortcuts.enumerated()), id: \.offset) { _, shortcut in
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
                        .frame(minWidth: 80, alignment: .leading)

                        // Description
                        Text(shortcut.description)
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)

                        Spacer()
                    }
                }
            }
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

// Helper to access and configure the NSWindow
private struct WindowAccessor: NSViewRepresentable {
    let onWindowAvailable: (NSWindow) -> Void

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                self.onWindowAvailable(window)
            }
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        if let window = nsView.window {
            self.onWindowAvailable(window)
        }
    }
}

#Preview {
    KeyboardShortcutsView()
}
