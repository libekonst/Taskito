//
//  SettingsView.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 23/12/25.
//

import SwiftUI
import KeyboardShortcuts

struct SettingsView: View {
    @ObservedObject var presetStore: PresetTimersStore
    @ObservedObject var settingsStore: SettingsStore
    var timerPolicy: TimerPolicy

    @State private var showingShortcutRecorder = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            Text("Settings")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .padding(.bottom, 24)

            // Settings sections

            VStack(alignment: .leading, spacing: 20) {
                // General settings section
                SettingsSectionView(title: "General") {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Start on system startup")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                            Text("Automatically launch Taskito when you log in")
                                .font(.system(size: 11, weight: .regular, design: .rounded))
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Toggle("", isOn: $settingsStore.startOnStartup)
                            .toggleStyle(.switch)
                            .labelsHidden()
                    }
                }

                // Sound settings section
                SettingsSectionView(title: "Sound") {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Play sound when timer completes")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                            Text("Plays a notification sound when the countdown reaches zero")
                                .font(.system(size: 11, weight: .regular, design: .rounded))
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Toggle("", isOn: $settingsStore.soundEnabled)
                            .toggleStyle(.switch)
                            .labelsHidden()
                    }
                }

                // Keyboard shortcuts section
                SettingsSectionView(title: "Keyboard Shortcuts") {
                    VStack(alignment: .leading, spacing: 12) {
                        // Enable/Disable Toggle
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Enable global shortcut")
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                Text("Allow opening Taskito from anywhere with a keyboard shortcut")
                                    .font(.system(size: 11, weight: .regular, design: .rounded))
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Toggle("", isOn: $settingsStore.globalShortcutEnabled)
                                .toggleStyle(.switch)
                                .labelsHidden()
                        }

                        Divider()

                        // Shortcut Recorder Button
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Customize Shortcut")
                                .font(.system(size: 13, weight: .medium, design: .rounded))

                            Button(action: {
                                showingShortcutRecorder = true
                            }) {
                                HStack {
                                    Text("Show App Window:")
                                        .font(.system(size: 13, weight: .regular, design: .rounded))
                                        .foregroundStyle(.secondary)

                                    Spacer()

                                    // Display current shortcut
                                    if let shortcut = KeyboardShortcuts.getShortcut(for: .toggleAppWindow) {
                                        Text(shortcut.description)
                                            .font(.system(size: 13, weight: .medium, design: .monospaced))
                                            .foregroundStyle(.primary)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(
                                                RoundedRectangle(cornerRadius: 5, style: .continuous)
                                                    .fill(Color.primary.opacity(0.06))
                                            )
                                    } else {
                                        Text("Not Set")
                                            .font(.system(size: 13, weight: .regular, design: .rounded))
                                            .foregroundStyle(.tertiary)
                                    }

                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundStyle(.tertiary)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                                        .fill(Color.primary.opacity(0.03))
                                )
                            }
                            .buttonStyle(.plain)
                            .disabled(!settingsStore.globalShortcutEnabled)
                        }
                        .opacity(settingsStore.globalShortcutEnabled ? 1.0 : 0.5)
                    }
                }
                .sheet(isPresented: $showingShortcutRecorder) {
                    ShortcutRecorderSheet(
                        onCancel: {
                            showingShortcutRecorder = false
                        },
                        onSave: {
                            showingShortcutRecorder = false
                        }
                    )
                }

                // Preset timers section
                SettingsSectionView(title: "Preset Timers") {
                    PresetTimersSettingsView(
                        presetStore: presetStore,
                        timerPolicy: timerPolicy
                    )
                }
            }

            Spacer()
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .alert(
            "Startup Settings Error",
            isPresented: .init(
                get: { settingsStore.startupError != nil },
                set: { if !$0 { settingsStore.startupError = nil } }
            ),
            presenting: settingsStore.startupError
        ) { _ in
            Button("OK") {
                settingsStore.startupError = nil
            }
        } message: { error in
            VStack(alignment: .leading, spacing: 8) {
                if let description = error.errorDescription {
                    Text(description)
                }
                if let suggestion = error.recoverySuggestion {
                    Text(suggestion)
                }
            }
        }
    }
}

private struct SettingsSectionView<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(0.5)

            VStack(alignment: .leading, spacing: 12) {
                content
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
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

#Preview {
    ScrollView{
        SettingsView(
            presetStore: PresetTimersStore(),
            settingsStore: SettingsStore(loginItemManager: LoginItemManager()),
            timerPolicy: StandardTimerPolicy()
        )}
    .frame(width: 600, height: 400)
}
