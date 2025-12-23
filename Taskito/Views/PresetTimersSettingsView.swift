//
//  PresetTimersSettingsView.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 23/12/25.
//

import SwiftUI

struct PresetTimersSettingsView: View {
    @ObservedObject var presetStore: PresetTimersStore
    @State private var editingPreset: PresetTimer?
    @State private var showingAddSheet = false

    private let maxPresets = 5
    private var isAtLimit: Bool {
        presetStore.presets.count >= maxPresets
    }

    private var hasModifiedPresets: Bool {
        // Check if current presets differ from defaults
        guard presetStore.presets.count == PresetTimer.defaults.count else { return true }

        for (index, preset) in presetStore.presets.enumerated() {
            let defaultPreset = PresetTimer.defaults[index]
            if preset.name != defaultPreset.name ||
                preset.minutes != defaultPreset.minutes ||
                preset.seconds != defaultPreset.seconds
            {
                return true
            }
        }
        return false
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(presetStore.presets.enumerated()), id: \.element.id) { index, preset in
                PresetTimerRow(
                    preset: preset,
                    onEdit: {
                        editingPreset = preset
                    },
                    onDelete: {
                        presetStore.removePreset(preset)
                    }
                )

                if index < presetStore.presets.count - 1 {
                    Divider()
                }
            }

            HStack(spacing: 1) {
                // Show limit message when at maximum
                if isAtLimit {
                    Text("Maximum \(maxPresets) preset timers.")
                        .font(.system(size: 11, weight: .regular, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                
                // Show restore defaults button when presets have been modified
                if hasModifiedPresets {
                    Button("Restore defaults...") {
                        presetStore.resetToDefaults()
                    }
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .buttonStyle(.plain)
                    .foregroundStyle(.blue)
                }
            }
            
            if !isAtLimit {
                // Show add button when under limit
                Button(action: { showingAddSheet = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 13, weight: .medium))
                        Text("Add Preset Timer")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                    }
                    .foregroundStyle(.blue)
                }
                .buttonStyle(.plain)
                .padding(.top, 14)
            }
        }
        .sheet(item: $editingPreset) { preset in
            PresetEditorSheet(
                preset: preset,
                onSave: { updated in
                    presetStore.updatePreset(updated)
                    editingPreset = nil
                },
                onCancel: {
                    editingPreset = nil
                }
            )
        }
        .sheet(isPresented: $showingAddSheet) {
            PresetEditorSheet(
                preset: nil,
                onSave: { newPreset in
                    presetStore.addPreset(newPreset)
                    showingAddSheet = false
                },
                onCancel: {
                    showingAddSheet = false
                }
            )
        }
    }
}

private struct PresetTimerRow: View {
    let preset: PresetTimer
    let onEdit: () -> Void
    let onDelete: () -> Void

    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(preset.name)
                    .font(.system(size: 13, weight: .medium, design: .rounded))

                Text("\(preset.minutes)m \(preset.seconds)s")
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if isHovered {
                HStack(spacing: 8) {
                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.blue)
                    }
                    .buttonStyle(.plain)

                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.red)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.vertical, 10)
        .contentShape(Rectangle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
}

private struct PresetEditorSheet: View {
    let preset: PresetTimer? // nil for new preset
    let onSave: (PresetTimer) -> Void
    let onCancel: () -> Void

    @State private var name: String
    @State private var minutes: Int
    @State private var seconds: Int

    init(preset: PresetTimer?, onSave: @escaping (PresetTimer) -> Void, onCancel: @escaping () -> Void) {
        self.preset = preset
        self.onSave = onSave
        self.onCancel = onCancel
        _name = State(initialValue: preset?.name ?? "")
        _minutes = State(initialValue: preset?.minutes ?? 25)
        _seconds = State(initialValue: preset?.seconds ?? 0)
    }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && (minutes > 0 || seconds > 0)
    }

    var body: some View {
        VStack(spacing: 20) {
            Text(preset == nil ? "New Preset Timer" : "Edit Preset Timer")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .padding(.top, 20)

            VStack(alignment: .leading, spacing: 8) {
                // Name field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Name")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)

                    TextField("e.g., Pomodoro", text: $name)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 13, design: .rounded))
                }

                // Duration fields
                VStack(alignment: .leading, spacing: 8) {
                    Text("Duration")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)

                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Minutes")
                                .font(.system(size: 11, weight: .regular, design: .rounded))
                                .foregroundStyle(.secondary)

                            TextField("0", value: $minutes, format: .number)
                                .textFieldStyle(.roundedBorder)
                                .font(.system(size: 13, design: .rounded))
                                .frame(width: 80)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Seconds")
                                .font(.system(size: 11, weight: .regular, design: .rounded))
                                .foregroundStyle(.secondary)

                            TextField("0", value: $seconds, format: .number)
                                .textFieldStyle(.roundedBorder)
                                .font(.system(size: 13, design: .rounded))
                                .frame(width: 80)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)

            Spacer()

            // Buttons
            HStack(spacing: 12) {
                Button("Cancel") {
                    onCancel()
                }
                .keyboardShortcut(.cancelAction)

                Button(preset == nil ? "Add" : "Save") {
                    let updatedPreset = PresetTimer(
                        id: preset?.id ?? UUID(),
                        name: name.trimmingCharacters(in: .whitespaces),
                        minutes: max(0, minutes),
                        seconds: max(0, min(59, seconds))
                    )
                    onSave(updatedPreset)
                }
                .keyboardShortcut(.defaultAction)
                .disabled(!isValid)
            }
            .padding(.bottom, 20)
        }
        .frame(width: 400, height: 300)
    }
}

#Preview {
    PresetTimersSettingsView(presetStore: PresetTimersStore())
}
