//
//  KeyboardShortcuts.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 11/12/25.
//

import SwiftUI
import KeyboardShortcuts

// MARK: - Global MacOS Shortcuts
extension KeyboardShortcuts.Name {
    /// Global shortcut to toggle the app window visibility
    /// Default: Option+Space (can be customized by user)
    static let toggleAppWindow = Self("toggleAppWindow", default: .init(.space, modifiers: [.option]))
}

/// Represents a single keyboard shortcut with its metadata
struct AppKeyboardShortcut {
    let key: String
    let modifiers: String // Use macOS symbols: ⌘ (Command), ⌃ (Control), ⌥ (Option), ⇧ (Shift)
    let description: String
    let scope: Scope

    enum Scope {
        case global // Works everywhere in the app
        case systemGlobal // Works system-wide (even when app not focused)
        case formView // Only works in the timer setup form
        case countdownView // Only works during active countdown
    }

    /// Returns a formatted display string (e.g., "⌘R", "Space", "⌃C")
    var displayString: String {
        modifiers.isEmpty ? key : "\(modifiers)\(key)"
    }
}

/// Centralized registry of all app-level keyboard shortcuts (view shortcuts)
enum AppKeyboardShortcuts {
    /// All keyboard shortcuts used in the app (view-only)
    static let all: [AppKeyboardShortcut] = [
        // MARK: - Global In-App Shortcuts

        AppKeyboardShortcut(
            key: "Esc",
            modifiers: "",
            description: "Close window and restore focus",
            scope: .global
        ),
        AppKeyboardShortcut(
            key: "Q",
            modifiers: "⌘",
            description: "Quit application",
            scope: .global
        ),
        AppKeyboardShortcut(
            key: ",",
            modifiers: "⌘",
            description: "Open settings",
            scope: .global
        ),

        // MARK: - Form View Shortcuts

        AppKeyboardShortcut(
            key: "1",
            modifiers: "⌘",
            description: "Select first preset timer",
            scope: .formView
        ),
        AppKeyboardShortcut(
            key: "2",
            modifiers: "⌘",
            description: "Select second preset timer",
            scope: .formView
        ),
        AppKeyboardShortcut(
            key: "3",
            modifiers: "⌘",
            description: "Select third preset timer",
            scope: .formView
        ),

        // MARK: - Countdown View Shortcuts

        AppKeyboardShortcut(
            key: "C",
            modifiers: "⌃",
            description: "Cancel timer",
            scope: .countdownView
        ),
        AppKeyboardShortcut(
            key: "R",
            modifiers: "⌘",
            description: "Restart timer from beginning",
            scope: .countdownView
        ),
        AppKeyboardShortcut(
            key: "Space",
            modifiers: "",
            description: "Play/pause timer",
            scope: .countdownView
        ),
        AppKeyboardShortcut(
            key: "+",
            modifiers: "",
            description: "Add 1 minute to timer",
            scope: .countdownView
        ),
        AppKeyboardShortcut(
            key: "+",
            modifiers: "⇧",
            description: "Add 3 minutes to timer",
            scope: .countdownView
        ),
    ]

    // MARK: - Convenience Accessors

    /// Global shortcuts that work anywhere in the app
    static var global: [AppKeyboardShortcut] {
        all.filter { $0.scope == .global }
    }

    /// Shortcuts specific to the form view
    static var formView: [AppKeyboardShortcut] {
        all.filter { $0.scope == .formView }
    }

    /// Shortcuts specific to the countdown view
    static var countdownView: [AppKeyboardShortcut] {
        all.filter { $0.scope == .countdownView }
    }

    /// System-wide global shortcuts
    static var systemGlobal: [AppKeyboardShortcut] {
        if let shortcut = systemGlobalShortcut() {
            return [shortcut]
        }
        return []
    }

    // MARK: - System Global Shortcuts

    /// Converts a Carbon key code to its string representation
    private static func keyCodeToString(_ keyCode: Int) -> String {
        // Map of common Carbon key codes to characters
        let keyCodeMap: [Int: String] = [
            0: "A", 1: "S", 2: "D", 3: "F", 4: "H", 5: "G", 6: "Z", 7: "X", 8: "C", 9: "V",
            11: "B", 12: "Q", 13: "W", 14: "E", 15: "R", 16: "Y", 17: "T",
            18: "1", 19: "2", 20: "3", 21: "4", 22: "6", 23: "5", 24: "=", 25: "9", 26: "7",
            27: "-", 28: "8", 29: "0", 30: "]", 31: "O", 32: "U", 33: "[", 34: "I", 35: "P",
            37: "L", 38: "J", 39: "'", 40: "K", 41: ";", 42: "\\", 43: ",", 44: "/", 45: "N",
            46: "M", 47: ".", 50: "`",
            // Function keys
            122: "F1", 120: "F2", 99: "F3", 118: "F4", 96: "F5", 97: "F6",
            98: "F7", 100: "F8", 101: "F9", 109: "F10", 103: "F11", 111: "F12"
        ]

        return keyCodeMap[keyCode] ?? "Key\(keyCode)"
    }

    /// Returns the current global shortcut for toggling app window
    /// This is dynamic because users can customize it
    private static func systemGlobalShortcut() -> AppKeyboardShortcut? {
        guard let shortcut = KeyboardShortcuts.getShortcut(for: .toggleAppWindow) else {
            return nil
        }

        // Convert KeyboardShortcuts.Shortcut to our format
        let modifiers = shortcut.modifiers
        var modifierString = ""
        if modifiers.contains(.control) { modifierString += "⌃" }
        if modifiers.contains(.option) { modifierString += "⌥" }
        if modifiers.contains(.shift) { modifierString += "⇧" }
        if modifiers.contains(.command) { modifierString += "⌘" }

        // Get the key string
        let keyString: String = {
            guard let key = shortcut.key else {
                return "?"
            }

            switch key {
            case .space:
                return "Space"
            case .return:
                return "Return"
            case .tab:
                return "Tab"
            case .escape:
                return "Esc"
            case .delete:
                return "Delete"
            case .upArrow:
                return "↑"
            case .downArrow:
                return "↓"
            case .leftArrow:
                return "←"
            case .rightArrow:
                return "→"
            default:
                // For regular keys, convert Carbon key code to character
                return keyCodeToString(key.rawValue)
            }
        }()

        return AppKeyboardShortcut(
            key: keyString,
            modifiers: modifierString,
            description: "Open Taskito from anywhere",
            scope: .systemGlobal
        )
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
    func appKeyboardShortcut(_ shortcut: (key: KeyEquivalent, modifiers: EventModifiers)) -> some View {
        keyboardShortcut(shortcut.key, modifiers: shortcut.modifiers)
    }
}
