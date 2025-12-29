//
//  PresetTimerIntegrationTests.swift
//  TaskitoTests
//
//  Created by Konstantinos Liberopoulos on 29/12/24.
//

@testable import Taskito
import XCTest

final class PresetTimerIntegrationTests: XCTestCase {
    var countdownStore: CountdownStore!
    var mockClock: MockClock!
    var presetStore: PresetTimersStore!
    var timerPolicy: TimerPolicy!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockClock = MockClock()
        countdownStore = CountdownStore(clock: mockClock)
        presetStore = PresetTimersStore()
        timerPolicy = StandardTimerPolicy()
    }

    override func tearDownWithError() throws {
        countdownStore = nil
        mockClock = nil
        presetStore = nil
        timerPolicy = nil
        try super.tearDownWithError()
    }

    // MARK: - Preset Selection Integration Tests

    func testPresetSelection_StartsTimerWithCorrectDuration() {
        // Given - Pomodoro preset (25 minutes)
        let pomodoroPreset = presetStore.presets.first { $0.name == "Pomodoro" }
        XCTAssertNotNil(pomodoroPreset, "Pomodoro preset should exist in defaults")

        guard let preset = pomodoroPreset else { return }

        // When - Start timer using preset
        let result = countdownStore.startNewTimer(
            minutes: preset.minutes,
            seconds: preset.seconds
        )

        // Then - Timer should start with preset duration
        if case .failure(let error) = result {
            XCTFail("Expected success, got failure: \(error)")
        }
        XCTAssertEqual(countdownStore.timerState, .running)
        XCTAssertEqual(countdownStore.secondsTotal, preset.totalSeconds)
        XCTAssertEqual(countdownStore.secondsTotal, 1500, "25 minutes = 1500 seconds")
    }

    func testPresetCreation_ValidatesAgainstTimerPolicy() {
        // Given - Timer policy limits
        let limits = timerPolicy.minutesLimits

        // When - Create preset within limits
        let validPreset = PresetTimer(
            name: "Valid Timer",
            minutes: limits.max,
            seconds: 59
        )

        // Then - Should be valid
        XCTAssertLessThanOrEqual(validPreset.minutes, limits.max)
        XCTAssertGreaterThanOrEqual(validPreset.minutes, limits.min)

        // When - Add to store
        presetStore.addPreset(validPreset)

        // Then - Should be in presets list
        XCTAssertTrue(presetStore.presets.contains(validPreset))

        // When - Try to start timer with this preset
        let result = countdownStore.startNewTimer(
            minutes: validPreset.minutes,
            seconds: validPreset.seconds
        )

        // Then - Should succeed
        if case .failure(let error) = result {
            XCTFail("Expected success, got failure: \(error)")
        }
        XCTAssertEqual(countdownStore.timerState, .running)

        // Note: Validation against policy limits would typically happen in the UI layer
        // The preset model itself doesn't enforce these limits
    }

    func testPresetUpdate_MaintainsConsistency() {
        // Given - Original preset
        let originalPreset = PresetTimer(
            id: UUID(),
            name: "Original",
            minutes: 10,
            seconds: 0
        )
        presetStore.addPreset(originalPreset)

        // Verify it was added
        XCTAssertTrue(presetStore.presets.contains(originalPreset))

        // When - Update preset
        let updatedPreset = PresetTimer(
            id: originalPreset.id, // Same ID
            name: "Updated",       // Different name
            minutes: 15,           // Different minutes
            seconds: 30            // Different seconds
        )
        presetStore.updatePreset(updatedPreset)

        // Then - Preset should be updated in store
        let foundPreset = presetStore.presets.first { $0.id == originalPreset.id }
        XCTAssertNotNil(foundPreset, "Preset should still exist")
        XCTAssertEqual(foundPreset?.name, "Updated", "Name should be updated")
        XCTAssertEqual(foundPreset?.minutes, 15, "Minutes should be updated")
        XCTAssertEqual(foundPreset?.seconds, 30, "Seconds should be updated")

        // Then - Should not have duplicate presets
        let presetsWithSameId = presetStore.presets.filter { $0.id == originalPreset.id }
        XCTAssertEqual(presetsWithSameId.count, 1, "Should only have one preset with this ID")

        // When - Start timer with updated preset
        if let preset = foundPreset {
            let result = countdownStore.startNewTimer(
                minutes: preset.minutes,
                seconds: preset.seconds
            )

            // Then - Timer should use updated values
            if case .failure(let error) = result {
                XCTFail("Expected success, got failure: \(error)")
            }
            XCTAssertEqual(countdownStore.secondsTotal, preset.totalSeconds)
            XCTAssertEqual(countdownStore.secondsTotal, 930, "15:30 = 930 seconds")
        }
    }

    // MARK: - Preset Persistence Integration Test

    func testPresetPersistence_IntegrationWithCountdown() {
        // Given - Create and save custom preset
        let customPreset = PresetTimer(
            name: "Custom Work Session",
            minutes: 45,
            seconds: 0
        )
        presetStore.addPreset(customPreset)

        // Then - Preset should be saved
        XCTAssertTrue(presetStore.presets.contains(customPreset))

        // When - Simulate app restart by creating new store instance
        let newPresetStore = PresetTimersStore()

        // Then - Custom preset should be loaded from persistence
        let loadedPreset = newPresetStore.presets.first { $0.name == "Custom Work Session" }
        XCTAssertNotNil(loadedPreset, "Custom preset should persist across app restarts")

        // When - Use loaded preset to start timer
        if let preset = loadedPreset {
            let result = countdownStore.startNewTimer(
                minutes: preset.minutes,
                seconds: preset.seconds
            )

            // Then - Timer should start with persisted preset values
            if case .failure(let error) = result {
                XCTFail("Expected success, got failure: \(error)")
            }
            XCTAssertEqual(countdownStore.secondsTotal, 2700, "45 minutes = 2700 seconds")
        }
    }

    // MARK: - Edge Case Integration Tests

    func testPresetWithMaxDuration_StartsSuccessfully() {
        // Given - Preset with maximum allowed duration
        let maxPreset = PresetTimer(
            name: "Max Timer",
            minutes: 99,
            seconds: 59
        )

        // When - Start timer with max preset
        let result = countdownStore.startNewTimer(
            minutes: maxPreset.minutes,
            seconds: maxPreset.seconds
        )

        // Then - Should succeed
        if case .failure(let error) = result {
            XCTFail("Expected success, got failure: \(error)")
        }
        XCTAssertEqual(countdownStore.timerState, .running)
        XCTAssertEqual(countdownStore.secondsTotal, 5999, "99:59 = 5999 seconds")
    }

    func testMultiplePresets_SequentialTimerStarts() async {
        // Given - Use short custom timers instead of default presets to avoid long waits
        let timer1 = PresetTimer(name: "Timer 1", minutes: 0, seconds: 2)
        let timer2 = PresetTimer(name: "Timer 2", minutes: 0, seconds: 1)

        // When - Start first timer
        _ = countdownStore.startNewTimer(minutes: timer1.minutes, seconds: timer1.seconds)
        XCTAssertEqual(countdownStore.timerState, .running)
        XCTAssertEqual(countdownStore.secondsTotal, 2)

        // When - Wait for first timer to complete (MockClock makes this ~20ms)
        await waitForTimerCompletion(countdownStore, timeout: 0.5)
        XCTAssertEqual(countdownStore.timerState, .completed)

        // When - Start second timer after first completes
        _ = countdownStore.startNewTimer(minutes: timer2.minutes, seconds: timer2.seconds)

        // Then - Second timer should start with different duration
        XCTAssertEqual(countdownStore.timerState, .running)
        XCTAssertEqual(countdownStore.secondsTotal, 1, "Second timer has different duration")

        // When - Wait for second timer to complete (MockClock makes this ~10ms)
        await waitForTimerCompletion(countdownStore, timeout: 0.5)

        // Then - Both timers completed successfully
        XCTAssertEqual(countdownStore.timerState, .completed)
    }

    // MARK: - Helper Methods

    /// Waits for timer completion using async/await
    private func waitForTimerCompletion(_ store: CountdownStore, timeout: TimeInterval) async {
        await withCheckedContinuation { continuation in
            var completed = false

            // Register completion handler
            store.onTimerCompleted {
                if !completed {
                    completed = true
                    continuation.resume()
                }
            }

            // Timeout fallback
            DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
                if !completed {
                    completed = true
                    continuation.resume()
                }
            }
        }
    }
}
