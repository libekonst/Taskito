//
//  SettingsStore.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 11/12/25.
//

import Foundation
import SwiftUI

/// Manages all user preferences and settings with local persistence
class SettingsStore: ObservableObject {
    // MARK: - Sound Settings

    /// Whether to play sound when timer completes
    @AppStorage("settings.soundEnabled") var soundEnabled: Bool = true

    // MARK: - Future Settings (placeholders)

    // Custom keybindings will go here
    // Preset timer configurations will go here

    // MARK: - Singleton

    static let shared = SettingsStore()

    private init() {
        // Private initializer for singleton pattern
    }
    
    // TODO add initialize on startup
    // TODO add bind to spotlight actions 
}
