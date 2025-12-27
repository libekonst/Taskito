//
//  SystemMenuView.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 15/12/25.
//

import SwiftUI

struct SystemMenuActions {
    let openSettings: () -> Void
    let quitApp: () -> Void
    let closeWindow: () -> Void
}

struct SystemMenuView: View {
    let store: SystemActionsStore

    var body: some View {
        Section {
            Divider().padding(.horizontal)
            VStack(spacing: 0) {
                SystemButton(
                    imageName: "gearshape",
                    label: "Preferences...",
                    shortcut: "⌘,",
                    onClick: store.openSettings
                )

                SystemButton(
                    imageName: "power",
                    label: "Quit",
                    shortcut: "⌘Q",
                    onClick: store.quitApp
                )
            }
            .padding(.bottom, 8)
            .padding(.horizontal, 7)
        }
    }
}

struct SystemGlobalKeyboardShortcuts: View {
    let store: SystemActionsStore

    var body: some View {
        ZStack {
            // Hidden button to close window
            Button("") {
                store.closeWindow()
            }
            .appKeyboardShortcut(AppKeyboardShortcuts.closeWindow)
            .hidden()

            // Hidden button for opening settings view
            Button("") {
                store.openSettings()
            }
            .appKeyboardShortcut(AppKeyboardShortcuts.openSettings)
            .hidden()

            // CMD+Q is natively implemented by MacOS
        }
    }
}

private struct SystemButton: View {
    @State private var isHovered = false

    var imageName: String?
    var label: String
    var shortcut: String?
    var onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            HStack(spacing: 6) {
                if imageName != nil {
                    Image(systemName: imageName ?? "")
                        .font(.system(size: 12, weight: .medium))
                }

                Text(label)
                    .font(.system(size: 12, weight: .medium, design: .rounded))

                Spacer()

                if let shortcut = shortcut {
                    Text(shortcut)
                        .font(.system(size: 12, weight: .light, design: .monospaced))
                        .tracking(3)
                        .foregroundStyle(.primary.opacity(0.5))
                }
            }
            .padding(.vertical, 7)
            .padding(.leading, 12)
            .padding(.trailing, 4)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color.primary.opacity(isHovered ? 0.06 : 0))
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
}

#Preview {
    SystemMenuView(store: SystemActionsStore(
        systemController: MockSystemController()
    ))
}
