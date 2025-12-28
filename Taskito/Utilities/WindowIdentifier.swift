//
//  WindowIdentifier.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 15/12/25.
//

import SwiftUI

/// Window identifiers for the app
enum WindowIdentifier {
    static let settingsMenu = "settings-menu"
    static let quickTimer = "quick-timer"
}

// MARK: - Window Identifier Accessor

extension View {
    /// Sets the NSWindow identifier for this view's window
    func windowIdentifier(_ identifier: String) -> some View {
        self.background(WindowIdentifierSetter(identifier: identifier))
    }
}

private struct WindowIdentifierSetter: NSViewRepresentable {
    let identifier: String

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            view.window?.identifier = NSUserInterfaceItemIdentifier(identifier)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        nsView.window?.identifier = NSUserInterfaceItemIdentifier(identifier)
    }
}
