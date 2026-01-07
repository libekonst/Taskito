//
//  GlobalShortcut.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 7/1/26.
//

import Foundation
import KeyboardShortcuts

public enum GlobalShortcut {
    @MainActor static func getDescription() -> String? {
        return KeyboardShortcuts.getShortcut(for: .toggleAppWindow)?.description
    }
    
    static func getModifier() -> String? {
        guard let shortcut = KeyboardShortcuts.getShortcut(for: .toggleAppWindow) else {
            return nil
        }
        
        let modifiers = shortcut.modifiers
        var modifierString = ""
        if modifiers.contains(.control) { modifierString += "⌃" }
        if modifiers.contains(.option) { modifierString += "⌥" }
        if modifiers.contains(.shift) { modifierString += "⇧" }
        if modifiers.contains(.command) { modifierString += "⌘" }
        return modifierString
    }
    
    static func getKey() -> String? {
        guard let shortcutKey = KeyboardShortcuts.getShortcut(for: .toggleAppWindow)?.key else {
            return nil
        }
        
        let keyString: String = {
            switch shortcutKey {
            case .space: return "Space"
            case .return: return "Return"
            case .tab: return "Tab"
            case .escape: return "Esc"
            case .delete: return "Delete"
            case .upArrow: return "↑"
            case .downArrow: return "↓"
            case .leftArrow: return "←"
            case .rightArrow: return "→"
            default: return keyCodeToString(shortcutKey.rawValue)
            }
        }()
        
        return keyString
    }
    
    /// Converts a Carbon key code to its string representation
    private static func keyCodeToString(_ keyCode: Int) -> String {
        // Map of common Carbon key codes to characters
        let keyCodeMap: [Int: String] = [
            0: "A", 1: "S", 2: "D", 3: "F", 4: "H", 5: "G", 6: "Z", 7: "X", 8: "C", 9: "V",
            10: "§", 11: "B", 12: "Q", 13: "W", 14: "E", 15: "R", 16: "Y", 17: "T",
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
}
