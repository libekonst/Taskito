//
//  KeyboardShortcuts.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 11/12/25.
//

import SwiftUI

/// Represents a single keyboard shortcut with its metadata
struct KeyboardShortcut {
    let key: String
    let modifiers: String // Use macOS symbols: ⌘ (Command), ⌃ (Control), ⌥ (Option), ⇧ (Shift)
    let description: String
    let scope: Scope

    enum Scope {
        case global // Works everywhere in the app
        case formView // Only works in the timer setup form
        case countdownView // Only works during active countdown
    }

    /// Returns a formatted display string (e.g., "⌘R", "Space", "⌃C")
    var displayString: String {
        modifiers.isEmpty ? key : "\(modifiers)\(key)"
    }
}

/// Centralized registry of all keyboard shortcuts
enum KeyboardShortcuts {
    /// All keyboard shortcuts used in the app (view-only)
    static let all: [KeyboardShortcut] = [
        // MARK: - Global Shortcuts

        KeyboardShortcut(
            key: "Esc",
            modifiers: "",
            description: "Close window and restore focus",
            scope: .global
        ),
        KeyboardShortcut(
            key: "Q",
            modifiers: "⌘",
            description: "Quit application",
            scope: .global
        ),
        KeyboardShortcut(
            key: ",",
            modifiers: "⌘",
            description: "Open settings",
            scope: .global
        ),

        // MARK: - Form View Shortcuts

        KeyboardShortcut(
            key: "1",
            modifiers: "⌘",
            description: "Select first preset timer",
            scope: .formView
        ),
        KeyboardShortcut(
            key: "2",
            modifiers: "⌘",
            description: "Select second preset timer",
            scope: .formView
        ),
        KeyboardShortcut(
            key: "3",
            modifiers: "⌘",
            description: "Select third preset timer",
            scope: .formView
        ),

        // MARK: - Countdown View Shortcuts

        KeyboardShortcut(
            key: "C",
            modifiers: "⌃",
            description: "Cancel timer",
            scope: .countdownView
        ),
        KeyboardShortcut(
            key: "R",
            modifiers: "⌘",
            description: "Restart timer from beginning",
            scope: .countdownView
        ),
        KeyboardShortcut(
            key: "Space",
            modifiers: "",
            description: "Play/pause timer",
            scope: .countdownView
        ),
        KeyboardShortcut(
            key: "+",
            modifiers: "",
            description: "Add 1 minute to timer",
            scope: .countdownView
        ),
        KeyboardShortcut(
            key: "+",
            modifiers: "⇧",
            description: "Add 3 minutes to timer",
            scope: .countdownView
        ),
    ]

    // MARK: - Convenience Accessors

    /// Global shortcuts that work anywhere in the app
    static var global: [KeyboardShortcut] {
        all.filter { $0.scope == .global }
    }

    /// Shortcuts specific to the form view
    static var formView: [KeyboardShortcut] {
        all.filter { $0.scope == .formView }
    }

    /// Shortcuts specific to the countdown view
    static var countdownView: [KeyboardShortcut] {
        all.filter { $0.scope == .countdownView }
    }

    // MARK: - Implementation Helpers (for use in views)

    /// Close window shortcut (Esc)
    static let closeWindow = (key: KeyEquivalent.escape, modifiers: EventModifiers())

    /// Cancel timer shortcut (⌃C)
    static let cancelTimer = (key: KeyEquivalent("c"), modifiers: EventModifiers.control)

    /// Restart timer shortcut (⌘R)
    static let restartTimer = (key: KeyEquivalent("r"), modifiers: EventModifiers.command)

    /// Play/pause timer shortcut (Space)
    static let playPause = (key: KeyEquivalent.space, modifiers: EventModifiers())

    /// Preset 1 shortcut (⌘1)
    static let preset1 = (key: KeyEquivalent("1"), modifiers: EventModifiers.command)

    /// Preset 2 shortcut (⌘2)
    static let preset2 = (key: KeyEquivalent("2"), modifiers: EventModifiers.command)

    /// Preset 3 shortcut (⌘3)
    static let preset3 = (key: KeyEquivalent("3"), modifiers: EventModifiers.command)

    /// Add 1 minute shortcut (+)
    static let addOneMinute = (key: KeyEquivalent("="), modifiers: EventModifiers())

    /// Add 3 minutes shortcut (⇧+)
    static let addThreeMinutes = (key: KeyEquivalent("="), modifiers: EventModifiers.shift)

    /// Returns the keyboard shortcut for a preset at the given index (0-based)
    static func preset(at index: Int) -> (key: KeyEquivalent, modifiers: EventModifiers)? {
        switch index {
        case 0: return preset1
        case 1: return preset2
        case 2: return preset3
        default: return nil
        }
    }

    /// Settings shortcut (⌘,)
    static let openSettings = (key: KeyEquivalent(","), modifiers: EventModifiers.command)
}

// MARK: - View Extension for Cleaner Usage

extension View {
    /// Applies a keyboard shortcut from a tuple of (KeyEquivalent, EventModifiers)
    func keyboardShortcut(_ shortcut: (key: KeyEquivalent, modifiers: EventModifiers)) -> some View {
        keyboardShortcut(shortcut.key, modifiers: shortcut.modifiers)
    }
}
