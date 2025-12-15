//
//  SystemController.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 15/12/25.
//

import Foundation
import AppKit

/// Abstraction for system-level actions to enable testability.
protocol SystemController {
    func dismiss()
    func openWindow(id: String)
    func hideApp()
    func terminateApp()
}

/// Production implementation backed by AppKit.
final class AppKitSystemController: SystemController {
    private let dismissAction: () -> Void
    private let openWindowById: (String) -> Void

    init(
        dismissAction: @escaping () -> Void,
        openWindowById: @escaping (String) -> Void
    ) {
        self.dismissAction = dismissAction
        self.openWindowById = openWindowById
    }

    func dismiss() {
        dismissAction()
    }

    func openWindow(id: String) {
        openWindowById(id)
    }

    func hideApp() {
        NSApp?.hide(nil)
    }

    func terminateApp() {
        NSApplication.shared.terminate(nil)
    }
}

/// Test double you can use in unit tests.
final class MockSystemController: SystemController {
    private(set) var didDismiss = false
    private(set) var openedWindowIds: [String] = []
    private(set) var didHideApp = false
    private(set) var didTerminate = false

    func dismiss() {
        didDismiss = true
    }

    func openWindow(id: String) {
        openedWindowIds.append(id)
    }

    func hideApp() {
        didHideApp = true
    }

    func terminateApp() {
        didTerminate = true
    }
}
