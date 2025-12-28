//
//  PreferencesWindow.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 23/12/25.
//

import SwiftUI
import AppKit

struct PreferencesWindow: View {
    @ObservedObject var presetStore: PresetTimersStore
    @ObservedObject var settingsStore: SettingsStore
    var timerPolicy: TimerPolicy
    @State private var selectedTab: PreferencesTab = .settings

    var body: some View {
        VStack(spacing: 0) {
            // Tab bar
            HStack(spacing: 0) {
                PreferencesTabButton(
                    tab: .settings,
                    selectedTab: $selectedTab
                )
                
                PreferencesTabButton(
                    tab: .keyboardShortcuts,
                    selectedTab: $selectedTab
                )
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 8)
            
            Divider()
            
            // Content area
            ScrollView{
                Group {
                    switch selectedTab {
                    case .settings:
                        SettingsView(
                            presetStore: presetStore,
                            settingsStore: settingsStore,
                            timerPolicy: timerPolicy
                        )
                        .transition(.opacity)
                    case .keyboardShortcuts:
                        AppKeyboardShortcutsView()
                            .transition(.opacity)
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: selectedTab)
            }
        }
        .frame(width: 600, height: 500)
        .background(WindowAccessor(onWindowAvailable: { window in
            // Set window identifier for deduplication
            window.identifier = NSUserInterfaceItemIdentifier(WindowIdentifier.settingsMenu)
            // Set window level to float above other windows
            window.level = .floating
        }))
    }
}

private enum PreferencesTab: String, CaseIterable {
    case settings = "Settings"
    case keyboardShortcuts = "Keyboard Shortcuts"

    var icon: String {
        switch self {
        case .settings:
            return "gearshape"
        case .keyboardShortcuts:
            return "keyboard"
        }
    }
}

private struct PreferencesTabButton: View {
    let tab: PreferencesTab
    @Binding var selectedTab: PreferencesTab

    @State private var isHovered = false

    private var isSelected: Bool {
        selectedTab == tab
    }

    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.15)) {
                selectedTab = tab
            }
        }) {
            HStack(spacing: 6) {
                Image(systemName: tab.icon)
                    .font(.system(size: 13, weight: .medium))

                Text(tab.rawValue)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .medium, design: .rounded))
            }
            .foregroundStyle(isSelected ? .primary : .secondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(
                        isSelected
                            ? Color.primary.opacity(0.08)
                            : (isHovered ? Color.primary.opacity(0.04) : Color.clear)
                    )
            )
        }
        .buttonStyle(.plain)
        .focusable(false)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
}

// Helper to access and configure the NSWindow
private struct WindowAccessor: NSViewRepresentable {
    let onWindowAvailable: (NSWindow) -> Void

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                self.onWindowAvailable(window)
            }
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        if let window = nsView.window {
            self.onWindowAvailable(window)
        }
    }
}

#Preview {
    PreferencesWindow(
        presetStore: PresetTimersStore(),
        settingsStore: SettingsStore(loginItemManager: LoginItemManager()),
        timerPolicy: StandardTimerPolicy()
    )
}
