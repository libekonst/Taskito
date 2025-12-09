//
//  PresetTimer.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 13/11/25.
//


import Foundation
import SwiftUI

/// Manages preset timer storage and retrieval
class PresetTimersStore: ObservableObject {
    @AppStorage("presetTimers") private var presetsData: Data = Data()

    @Published var presets: [PresetTimer] = []

    init() {
        loadPresets()
    }

    private func loadPresets() {
        if presetsData.isEmpty {
            // First launch - use defaults
            presets = PresetTimer.defaults
            savePresets()
        } else {
            // Load from storage
            if let decoded = try? JSONDecoder().decode([PresetTimer].self, from: presetsData) {
                presets = decoded
            } else {
                // Fallback to defaults if decoding fails
                presets = PresetTimer.defaults
            }
        }
    }

    private func savePresets() {
        if let encoded = try? JSONEncoder().encode(presets) {
            presetsData = encoded
        }
    }

    func addPreset(_ preset: PresetTimer) {
        presets.append(preset)
        savePresets()
    }

    func removePreset(_ preset: PresetTimer) {
        presets.removeAll { $0.id == preset.id }
        savePresets()
    }

    func resetToDefaults() {
        presets = PresetTimer.defaults
        savePresets()
    }
}
