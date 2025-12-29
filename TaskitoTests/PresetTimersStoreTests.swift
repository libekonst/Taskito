//
//  PresetTimersStoreTests.swift
//  TaskitoTests
//
//  Created by Konstantinos Liberopoulos on 28/12/24.
//

@testable import Taskito
import XCTest

final class PresetTimersStoreTests: XCTestCase {
    var sut: PresetTimersStore!

    override func setUpWithError() throws {
        try super.setUpWithError()

        // Clean UserDefaults before each test to ensure isolation
        TestHelpers.cleanUserDefaults(key: AppStorageKeys.presetTimers)

        sut = PresetTimersStore()
    }

    override func tearDownWithError() throws {
        sut = nil

        // Clean UserDefaults after test to prevent pollution
        TestHelpers.cleanUserDefaults(key: AppStorageKeys.presetTimers)

        try super.tearDownWithError()
    }

    // MARK: - Initialization Tests

    func testInit_FirstLaunch_LoadsDefaults() {
        // Given - Fresh UserDefaults (cleaned in setUp)

        // When - Initialize store
        let store = PresetTimersStore()

        // Then - Should have default presets
        XCTAssertEqual(store.presets.count, 3)
        XCTAssertTrue(store.presets.contains(where: { $0.name == "Pomodoro" }))
        XCTAssertTrue(store.presets.contains(where: { $0.name == "Short Break" }))
        XCTAssertTrue(store.presets.contains(where: { $0.name == "Long Break" }))
    }

    func testInit_WithExistingData_LoadsFromStorage() {
        // Given - Save custom presets
        let customPreset = PresetTimer(name: "Custom", minutes: 15, seconds: 30)
        let encoded = try! JSONEncoder().encode([customPreset])
        UserDefaults.standard.set(encoded, forKey: AppStorageKeys.presetTimers)

        // When - Initialize store
        let store = PresetTimersStore()

        // Then - Should load from storage
        XCTAssertEqual(store.presets.count, 1)
        XCTAssertEqual(store.presets.first?.name, "Custom")
        XCTAssertEqual(store.presets.first?.minutes, 15)
        XCTAssertEqual(store.presets.first?.seconds, 30)
    }

    func testInit_CorruptedData_FallsBackToDefaults() {
        // Given - Corrupted data in UserDefaults
        let corruptedData = "corrupted".data(using: .utf8)!
        UserDefaults.standard.set(corruptedData, forKey: AppStorageKeys.presetTimers)

        // When - Initialize store
        let store = PresetTimersStore()

        // Then - Should fall back to defaults
        XCTAssertEqual(store.presets.count, 3)
        XCTAssertTrue(store.presets.contains(where: { $0.name == "Pomodoro" }))
    }

    // MARK: - Add Preset Tests

    func testAddPreset_AddsToPresets() {
        // Given
        let initialCount = sut.presets.count
        let newPreset = PresetTimer(name: "Test Timer", minutes: 10, seconds: 0)

        // When
        sut.addPreset(newPreset)

        // Then
        XCTAssertEqual(sut.presets.count, initialCount + 1)
        XCTAssertTrue(sut.presets.contains(where: { $0.id == newPreset.id }))
    }

    func testAddPreset_SavesToStorage() {
        // Given
        let newPreset = PresetTimer(name: "Test Timer", minutes: 10, seconds: 0)

        // When
        sut.addPreset(newPreset)

        // Then - Create new store and verify persistence
        let newStore = PresetTimersStore()
        XCTAssertTrue(newStore.presets.contains(where: { $0.id == newPreset.id }))
    }

    // MARK: - Update Preset Tests

    func testUpdatePreset_UpdatesExistingPreset() {
        // Given - Add a preset
        let originalPreset = PresetTimer(name: "Original", minutes: 5, seconds: 0)
        sut.addPreset(originalPreset)

        // When - Update it
        let updatedPreset = PresetTimer(
            id: originalPreset.id,
            name: "Updated",
            minutes: 10,
            seconds: 30
        )
        sut.updatePreset(updatedPreset)

        // Then
        let preset = sut.presets.first(where: { $0.id == originalPreset.id })
        XCTAssertNotNil(preset)
        XCTAssertEqual(preset?.name, "Updated")
        XCTAssertEqual(preset?.minutes, 10)
        XCTAssertEqual(preset?.seconds, 30)
    }

    func testUpdatePreset_NonExistentPreset_DoesNothing() {
        // Given
        let initialCount = sut.presets.count
        let nonExistentPreset = PresetTimer(name: "Non-existent", minutes: 5, seconds: 0)

        // When
        sut.updatePreset(nonExistentPreset)

        // Then - Count should not change
        XCTAssertEqual(sut.presets.count, initialCount)
        XCTAssertFalse(sut.presets.contains(where: { $0.id == nonExistentPreset.id }))
    }

    // MARK: - Remove Preset Tests

    func testRemovePreset_RemovesFromList() {
        // Given - Add a preset
        let preset = PresetTimer(name: "To Remove", minutes: 5, seconds: 0)
        sut.addPreset(preset)
        let countBeforeRemoval = sut.presets.count

        // When
        sut.removePreset(preset)

        // Then
        XCTAssertEqual(sut.presets.count, countBeforeRemoval - 1)
        XCTAssertFalse(sut.presets.contains(where: { $0.id == preset.id }))
    }

    func testRemovePreset_SavesChanges() {
        // Given - Add a preset
        let preset = PresetTimer(name: "To Remove", minutes: 5, seconds: 0)
        sut.addPreset(preset)

        // When
        sut.removePreset(preset)

        // Then - Create new store and verify persistence
        let newStore = PresetTimersStore()
        XCTAssertFalse(newStore.presets.contains(where: { $0.id == preset.id }))
    }

    // MARK: - Reset to Defaults Tests

    func testResetToDefaults_RestoresDefaultPresets() {
        // Given - Add custom presets
        sut.addPreset(PresetTimer(name: "Custom 1", minutes: 15, seconds: 0))
        sut.addPreset(PresetTimer(name: "Custom 2", minutes: 20, seconds: 0))
        XCTAssertGreaterThan(sut.presets.count, 3)

        // When
        sut.resetToDefaults()

        // Then - Should have only default presets
        XCTAssertEqual(sut.presets.count, 3)
        XCTAssertTrue(sut.presets.contains(where: { $0.name == "Pomodoro" }))
        XCTAssertTrue(sut.presets.contains(where: { $0.name == "Short Break" }))
        XCTAssertTrue(sut.presets.contains(where: { $0.name == "Long Break" }))
    }

    // MARK: - Persistence Tests

    func testPresetPersistence_SurvivesReinitialization() {
        // Given - Add custom presets
        let preset1 = PresetTimer(name: "Persistent 1", minutes: 30, seconds: 0)
        let preset2 = PresetTimer(name: "Persistent 2", minutes: 45, seconds: 0)
        sut.addPreset(preset1)
        sut.addPreset(preset2)

        // When - Create new store
        let newStore = PresetTimersStore()

        // Then - Should have all presets including custom ones
        XCTAssertTrue(newStore.presets.contains(where: { $0.id == preset1.id }))
        XCTAssertTrue(newStore.presets.contains(where: { $0.id == preset2.id }))
    }

    func testPresetPersistence_HandlesEmptyData() {
        // Given - Remove all presets manually
        while !sut.presets.isEmpty {
            sut.removePreset(sut.presets[0])
        }
        XCTAssertEqual(sut.presets.count, 0)

        // When - Create new store
        let newStore = PresetTimersStore()

        // Then - Should still be empty (not reload defaults)
        XCTAssertEqual(newStore.presets.count, 0)
    }
}
