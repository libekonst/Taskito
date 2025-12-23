//
//  SystemActionsStore.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 15/12/25.
//

import Foundation

final class SystemActionsStore {
    private let systemController: SystemController

    init(systemController: SystemController) {
        self.systemController = systemController
    }

    func openSettings() {
        systemController.dismiss()
        systemController.openWindow(id: WindowIdentifier.settingsMenu)
    }

    func closeWindow() {
        systemController.dismiss() // Dismiss MenuBarExtra window, blur label
        systemController.hideApp() // Restore focus to previous app
    }

    func quitApp() {
        systemController.terminateApp()
    }
}
