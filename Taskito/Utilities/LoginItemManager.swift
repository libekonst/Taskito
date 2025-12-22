//
//  LoginItemManager.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 23/12/25.
//

import Foundation
import ServiceManagement

/// Manages the app's login item status using ServiceManagement framework
final class LoginItemManager {
    static let shared = LoginItemManager()

    private init() {}

    /// Check if the app is currently set to launch on login
    func isEnabled() async -> Bool {
        return SMAppService.mainApp.status == .enabled
    }

    /// Enable or disable launching the app on login
    func setStartOnLogin(enabled: Bool) {
        Task {
            do {
                if enabled {
                    // Register the app to start on login
                    if SMAppService.mainApp.status == .enabled {
                        print("✅ App already set to launch on login")
                    } else {
                        try SMAppService.mainApp.register()
                        print("✅ App registered to launch on login")
                    }
                } else {
                    // Unregister the app from starting on login
                    if SMAppService.mainApp.status == .notRegistered {
                        print("ℹ️ App already not registered for login")
                    } else {
                        try SMAppService.mainApp.unregister()
                        print("✅ App unregistered from launching on login")
                    }
                }
            } catch {
                print("❌ Failed to update login item status: \(error.localizedDescription)")
            }
        }
    }

    /// Get the current status of the login item
    func status() -> SMAppService.Status {
        return SMAppService.mainApp.status
    }
}
