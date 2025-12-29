//
//  SettingsStoreTests.swift
//  TaskitoTests
//
//  Created by Konstantinos Liberopoulos on 29/12/24.
//

@testable import Taskito
import XCTest

final class SettingsStoreTests: XCTestCase {
    var sut: SettingsStore!
    var mockLoginItemManager: MockLoginItemManager!

    override func setUpWithError() throws {
        try super.setUpWithError()

        // Clean UserDefaults before each test to ensure isolation
        TestHelpers.cleanUserDefaults(keys: [
            AppStorageKeys.Settings.soundEnabled,
            AppStorageKeys.Settings.globalShortcutEnabled,
            AppStorageKeys.Settings.startOnStartup
        ])

        // Create mock and store
        mockLoginItemManager = MockLoginItemManager()
        sut = SettingsStore(loginItemManager: mockLoginItemManager)
    }

    override func tearDownWithError() throws {
        sut = nil
        mockLoginItemManager = nil

        // Clean UserDefaults after test to prevent pollution
        TestHelpers.cleanUserDefaults(keys: [
            AppStorageKeys.Settings.soundEnabled,
            AppStorageKeys.Settings.globalShortcutEnabled,
            AppStorageKeys.Settings.startOnStartup
        ])

        try super.tearDownWithError()
    }

    // MARK: - Sound Settings Tests

    func testSoundEnabled_DefaultsToTrue() {
        // Given - Fresh SettingsStore (created in setUp)

        // Then
        XCTAssertTrue(sut.soundEnabled)
    }

    func testSoundEnabled_PersistsChanges() {
        // Given
        sut.soundEnabled = false

        // When - Create new store
        let newStore = SettingsStore(loginItemManager: mockLoginItemManager)

        // Then
        XCTAssertFalse(newStore.soundEnabled)
    }

    // MARK: - Global Shortcut Settings Tests

    func testGlobalShortcutEnabled_DefaultsToTrue() {
        // Given - Fresh SettingsStore (created in setUp)

        // Then
        XCTAssertTrue(sut.globalShortcutEnabled)
    }

    func testGlobalShortcutEnabled_PersistsChanges() {
        // Given
        sut.globalShortcutEnabled = false

        // When - Create new store
        let newStore = SettingsStore(loginItemManager: mockLoginItemManager)

        // Then
        XCTAssertFalse(newStore.globalShortcutEnabled)
    }

    // MARK: - Startup Settings Tests

    func testStartOnStartup_DefaultsToFalse() {
        // Given - Fresh SettingsStore (created in setUp)

        // Then
        XCTAssertFalse(sut.startOnStartup)
    }

    func testStartOnStartup_SyncsWithSystemState() async {
        // Given - System has login item enabled
        mockLoginItemManager.mockIsEnabled = true

        // When - Create new store and await sync
        let newStore = SettingsStore(loginItemManager: mockLoginItemManager)
        await newStore.syncWithSystemState()

        // Then - Should sync with system state
        XCTAssertTrue(newStore.startOnStartup, "startOnStartup should be true after syncing with system state")
        XCTAssertGreaterThanOrEqual(mockLoginItemManager.isEnabledCallCount, 1, "isEnabled should be called at least once")
    }

    func testStartOnStartup_EnabledCallsLoginItemManager() async {
        // Given
        mockLoginItemManager.mockSetStartOnLoginResult = .success(())

        // When
        await sut.setStartOnStartup(true)

        // Then
        XCTAssertEqual(mockLoginItemManager.setStartOnLoginCallCount, 1)
        XCTAssertEqual(mockLoginItemManager.lastEnabledValue, true)
        XCTAssertTrue(sut.startOnStartup)
    }

    func testStartOnStartup_DisabledCallsLoginItemManager() async {
        // Given - Start with enabled
        mockLoginItemManager.mockSetStartOnLoginResult = .success(())
        await sut.setStartOnStartup(true)

        // Reset call count
        mockLoginItemManager.setStartOnLoginCallCount = 0

        // When
        await sut.setStartOnStartup(false)

        // Then
        XCTAssertEqual(mockLoginItemManager.setStartOnLoginCallCount, 1)
        XCTAssertEqual(mockLoginItemManager.lastEnabledValue, false)
        XCTAssertFalse(sut.startOnStartup)
    }

    func testStartOnStartup_HandlesLoginItemFailure() async {
        // Given - Mock will fail
        let expectedError = LoginItemManager.LoginItemError.registrationFailed("Test error")
        mockLoginItemManager.mockSetStartOnLoginResult = .failure(expectedError)

        // When
        await sut.setStartOnStartup(true)

        // Then - Setting should stay false and error should be set
        XCTAssertFalse(sut.startOnStartup)
        XCTAssertNotNil(sut.startupError)
    }

    func testStartOnStartup_RevertsOnError() async {
        // Given - Start enabled successfully
        mockLoginItemManager.mockSetStartOnLoginResult = .success(())
        await sut.setStartOnStartup(true)
        XCTAssertTrue(sut.startOnStartup, "Initial enable should succeed")
        XCTAssertNil(sut.startupError, "Should have no error initially")

        // When - Disable fails
        mockLoginItemManager.mockSetStartOnLoginResult = .failure(.registrationFailed("Test error"))
        await sut.setStartOnStartup(false)

        // Then - Should keep previous value (true) after error
        XCTAssertTrue(sut.startOnStartup, "Should keep previous value after error")
        XCTAssertNotNil(sut.startupError, "Should have startup error")
    }

    // MARK: - System Sync Tests

    func testSyncWithSystemState_UpdatesFromSystem() async {
        // Given - System state differs from stored state
        mockLoginItemManager.mockIsEnabled = true
        XCTAssertFalse(sut.startOnStartup) // Default is false

        // When - Call sync directly
        await sut.syncWithSystemState()

        // Then
        XCTAssertTrue(sut.startOnStartup)
    }

    func testAppDidBecomeActive_SyncsState() async {
        // Given - System state is enabled
        mockLoginItemManager.mockIsEnabled = true
        let initialCallCount = mockLoginItemManager.isEnabledCallCount

        // When - Manually call sync (testing the logic, not the notification)
        await sut.syncWithSystemState()

        // Then - Should have called isEnabled
        XCTAssertGreaterThan(mockLoginItemManager.isEnabledCallCount, initialCallCount)
    }

    func testSyncDoesNotCallSetStartOnLogin() async {
        // Given - System state is true
        mockLoginItemManager.mockIsEnabled = true
        mockLoginItemManager.mockSetStartOnLoginResult = .success(())

        // When - Sync from system
        let newStore = SettingsStore(loginItemManager: mockLoginItemManager)
        await newStore.syncWithSystemState()

        // Then - setStartOnLogin should NOT be called during sync
        // (only isEnabled should be called)
        XCTAssertEqual(mockLoginItemManager.setStartOnLoginCallCount, 0)
        XCTAssertGreaterThan(mockLoginItemManager.isEnabledCallCount, 0)
    }
}

// MARK: - Mock LoginItemManager

class MockLoginItemManager: LoginItemManaging {
    var mockIsEnabled: Bool = false
    var mockSetStartOnLoginResult: Result<Void, LoginItemManager.LoginItemError> = .success(())

    var isEnabledCallCount = 0
    var setStartOnLoginCallCount = 0
    var lastEnabledValue: Bool?

    func isEnabled() async -> Bool {
        isEnabledCallCount += 1
        return mockIsEnabled
    }

    func setStartOnLogin(enabled: Bool) async -> Result<Void, LoginItemManager.LoginItemError> {
        setStartOnLoginCallCount += 1
        lastEnabledValue = enabled
        return mockSetStartOnLoginResult
    }
}
