//
//  GlobalShortcutDefaultKeybind.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 7/1/26.
//

import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    /// Global shortcut to toggle the app window visibility
    /// Default: Control+Backtick (can be customized by user)
    static let toggleAppWindow = Self("toggleAppWindow", default: .init(.minus, modifiers: [.control]))
}

