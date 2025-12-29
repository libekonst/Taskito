//
//  AppStorageKeysTests.swift
//  TaskitoTests
//
//  Created by Konstantinos Liberopoulos on 29/12/24.
//

@testable import Taskito
import XCTest

final class AppStorageKeysTests: XCTestCase {
    // MARK: - Uniqueness Tests

    func testAppStorageKeys_AllKeysAreUnique() {
        // Given - Collect all keys
        let allKeys = [
            AppStorageKeys.latestMinutes,
            AppStorageKeys.latestSeconds,
            AppStorageKeys.presetTimers,
            AppStorageKeys.Settings.soundEnabled,
            AppStorageKeys.Settings.globalShortcutEnabled,
            AppStorageKeys.Settings.startOnStartup,
        ]

        // When - Check for duplicates
        let uniqueKeys = Set(allKeys)

        // Then - All keys should be unique
        XCTAssertEqual(
            allKeys.count,
            uniqueKeys.count,
            "All AppStorage keys must be unique to prevent conflicts"
        )
    }

    // MARK: - Empty String Tests

    func testAppStorageKeys_NoEmptyStrings() {
        // Given - All keys
        let allKeys = [
            AppStorageKeys.latestMinutes,
            AppStorageKeys.latestSeconds,
            AppStorageKeys.presetTimers,
            AppStorageKeys.Settings.soundEnabled,
            AppStorageKeys.Settings.globalShortcutEnabled,
            AppStorageKeys.Settings.startOnStartup,
        ]

        // Then - No key should be empty
        for key in allKeys {
            XCTAssertFalse(key.isEmpty, "Key '\(key)' should not be empty")
            XCTAssertFalse(
                key.trimmingCharacters(in: .whitespaces).isEmpty,
                "Key '\(key)' should not be just whitespace"
            )
        }
    }

    // MARK: - Naming Convention Tests

    func testSettingsKeys_FollowNamingConvention() {
        // Given - All settings keys
        let settingsKeys = [
            AppStorageKeys.Settings.soundEnabled,
            AppStorageKeys.Settings.globalShortcutEnabled,
            AppStorageKeys.Settings.startOnStartup,
        ]

        // Then - All settings keys should have "settings." prefix
        for key in settingsKeys {
            XCTAssertTrue(
                key.hasPrefix("settings."),
                "Settings key '\(key)' should start with 'settings.' prefix"
            )
        }
    }

    // MARK: - Key Value Tests

    func testAppStorageKeys_HaveExpectedValues() {
        // Then - Verify specific key values to prevent accidental changes
        XCTAssertEqual(AppStorageKeys.latestMinutes, "latestMinutesSelection")
        XCTAssertEqual(AppStorageKeys.latestSeconds, "latestSecondsSelection")
        XCTAssertEqual(AppStorageKeys.presetTimers, "presetTimers")
        XCTAssertEqual(AppStorageKeys.Settings.soundEnabled, "settings.soundEnabled")
        XCTAssertEqual(AppStorageKeys.Settings.globalShortcutEnabled, "settings.globalShortcutEnabled")
        XCTAssertEqual(AppStorageKeys.Settings.startOnStartup, "settings.startOnStartup")
    }
}
