//
//  SettingsView.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 23/12/25.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject private var settings = SettingsStore.shared
    @StateObject private var presetStore = PresetTimersStore()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            Text("Settings")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .padding(.bottom, 24)

            // Settings sections
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // General settings section
                    SettingsSectionView(title: "General") {
                        Toggle(isOn: $settings.startOnStartup) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Start on system startup")
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                Text("Automatically launch Taskito when you log in")
                                    .font(.system(size: 11, weight: .regular, design: .rounded))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .toggleStyle(.switch)
                    }

                    // Sound settings section
                    SettingsSectionView(title: "Sound") {
                        Toggle(isOn: $settings.soundEnabled) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Play sound when timer completes")
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                Text("Plays a notification sound when the countdown reaches zero")
                                    .font(.system(size: 11, weight: .regular, design: .rounded))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .toggleStyle(.switch)
                    }

                    // Preset timers section
                    SettingsSectionView(title: "Preset Timers") {
                        PresetTimersSettingsView(presetStore: presetStore)
                    }
                }
            }

            Spacer()
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .alert(
            "Startup Settings Error",
            isPresented: .init(
                get: { settings.startupError != nil },
                set: { if !$0 { settings.startupError = nil } }
            ),
            presenting: settings.startupError
        ) { _ in
            Button("OK") {
                settings.startupError = nil
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
    SettingsView()
        .frame(width: 600, height: 400)
}
