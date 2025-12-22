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
    /// - Returns: Result indicating success or failure with error message
    @discardableResult
    func setStartOnLogin(enabled: Bool) async -> Result<Void, LoginItemError> {
        do {
            if enabled {
                // Register the app to start on login
                if SMAppService.mainApp.status == .enabled {
                    print("✅ App already set to launch on login")
                    return .success(())
                } else {
                    try SMAppService.mainApp.register()
                    print("✅ App registered to launch on login")
                    return .success(())
                }
            } else {
                // Unregister the app from starting on login
                if SMAppService.mainApp.status == .notRegistered {
                    print("ℹ️ App already not registered for login")
                    return .success(())
                } else {
                    try await SMAppService.mainApp.unregister()
                    print("✅ App unregistered from launching on login")
                    return .success(())
                }
            }
        } catch {
            print("❌ Failed to update login item status: \(error.localizedDescription)")
            return .failure(.registrationFailed(error.localizedDescription))
        }
    }

    /// Errors that can occur when managing login items
    enum LoginItemError: LocalizedError {
        case registrationFailed(String)

        var errorDescription: String? {
            switch self {
            case .registrationFailed(let message):
                return "Failed to update startup settings: \(message)"
            }
        }

        var recoverySuggestion: String? {
            switch self {
            case .registrationFailed:
                return "Please check System Settings > General > Login Items and ensure Taskito has permission to start at login."
            }
        }
    }

    /// Get the current status of the login item
    func status() -> SMAppService.Status {
        return SMAppService.mainApp.status
    }
}
