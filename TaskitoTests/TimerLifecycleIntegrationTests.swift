//
//  TimerLifecycleIntegrationTests.swift
//  TaskitoTests
//
//  Created by Konstantinos Liberopoulos on 29/12/24.
//

@testable import Taskito
import XCTest

final class TimerLifecycleIntegrationTests: XCTestCase {
    var sut: CountdownStore!
    var mockClock: MockClock!
    var settingsStore: SettingsStore!
    var mockLoginItemManager: MockLoginItemManager!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockClock = MockClock()
        sut = CountdownStore(clock: mockClock)
        mockLoginItemManager = MockLoginItemManager()
        settingsStore = SettingsStore(loginItemManager: mockLoginItemManager)
    }

    override func tearDownWithError() throws {
        sut = nil
        mockClock = nil
        settingsStore = nil
        mockLoginItemManager = nil
        try super.tearDownWithError()
    }

    // MARK: - Complete Timer Flow Tests

    func testCompleteTimerFlow_StartPauseResumeComplete() async {
        // Given - Start a 2-second timer
        let result = sut.startNewTimer(minutes: 0, seconds: 2)
        if case .failure(let error) = result {
            XCTFail("Expected success, got failure: \(error)")
        }

        // Then - Timer should be running
        XCTAssertEqual(sut.timerState, .running, "Timer should be running")
        XCTAssertEqual(sut.secondsTotal, 2)

        // When - Wait for at least one timer tick then pause (MockClock ticks every 10ms)
        try? await Task.sleep(nanoseconds: 15_000_000) // 15ms (ensures at least one tick)
        let pauseResult = sut.togglePlayPauseTimer()
        if case .failure(let error) = pauseResult {
            XCTFail("Expected success pausing, got failure: \(error)")
        }

        // Then - Timer should be paused with some time elapsed
        XCTAssertEqual(sut.timerState, .paused, "Timer should be paused")
        XCTAssertGreaterThan(sut.secondsElapsed, 0, "Some time should have elapsed")
        let elapsedWhenPaused = sut.secondsElapsed

        // When - Wait while paused (time should not advance)
        try? await Task.sleep(nanoseconds: 15_000_000) // 15ms
        XCTAssertEqual(
            sut.secondsElapsed,
            elapsedWhenPaused,
            "Time should not advance while paused"
        )

        // When - Resume timer
        let resumeResult = sut.togglePlayPauseTimer()
        if case .failure(let error) = resumeResult {
            XCTFail("Expected success resuming, got failure: \(error)")
        }

        // Then - Timer should be running again
        XCTAssertEqual(sut.timerState, .running, "Timer should be running again")

        // When - Wait for timer to complete (MockClock makes this ~20ms instead of 2s)
        await waitForTimerCompletion(sut, timeout: 0.5)

        // Then - Timer should be completed
        XCTAssertEqual(sut.timerState, .completed, "Timer should be completed")
        XCTAssertEqual(sut.secondsRemaining, 0, "No time should remain")
    }

    func testCompleteTimerFlow_StartCancelRestart() async {
        // Given - Start a 5-second timer
        let startResult = sut.startNewTimer(minutes: 0, seconds: 5)
        if case .failure(let error) = startResult {
            XCTFail("Expected success, got failure: \(error)")
        }

        // Then - Timer should be running
        XCTAssertEqual(sut.timerState, .running)
        let originalTotal = sut.secondsTotal

        // When - Wait briefly then cancel (MockClock ticks every 10ms)
        try? await Task.sleep(nanoseconds: 15_000_000) // 15ms
        let cancelResult = sut.cancelTimer()
        if case .failure(let error) = cancelResult {
            XCTFail("Expected success canceling, got failure: \(error)")
        }

        // Then - Timer should be cancelled and reset
        XCTAssertEqual(sut.timerState, .cancelled, "Timer should be cancelled")
        XCTAssertEqual(sut.secondsTotal, 0, "Total seconds should be cleared")
        XCTAssertEqual(sut.secondsElapsed, 0, "Elapsed seconds should be cleared")

        // When - Try to restart the cancelled timer (should fail - no active timer)
        let restartResult = sut.restartTimer()
        guard case .failure(let error) = restartResult else {
            XCTFail("Expected failure, got success")
            return
        }

        // Then - Should get noActiveTimer error
        XCTAssertEqual(error, .noActiveTimer, "Should get noActiveTimer error")

        // When - Start a new timer
        let newStartResult = sut.startNewTimer(minutes: 0, seconds: 3)
        if case .failure(let error) = newStartResult {
            XCTFail("Expected success, got failure: \(error)")
        }

        // Then - Timer should be running with new duration
        XCTAssertEqual(sut.timerState, .running, "Timer should be running")
        XCTAssertEqual(sut.secondsTotal, 3, "Should have new duration")
        XCTAssertNotEqual(sut.secondsTotal, originalTotal, "Duration should differ from first timer")
    }

    func testCompleteTimerFlow_StartAddTimeComplete() async {
        // Given - Start a 1-second timer
        let startResult = sut.startNewTimer(minutes: 0, seconds: 1)
        if case .failure(let error) = startResult {
            XCTFail("Expected success, got failure: \(error)")
        }

        // Then - Timer should be running
        XCTAssertEqual(sut.timerState, .running)
        XCTAssertEqual(sut.secondsTotal, 1)

        // When - Add 2 more seconds before timer completes (MockClock ticks every 10ms)
        try? await Task.sleep(nanoseconds: 5_000_000) // 5ms (before first tick completes)
        let addTimeResult = sut.addTime(seconds: 2)
        if case .failure(let error) = addTimeResult {
            XCTFail("Expected success adding time, got failure: \(error)")
        }

        // Then - Timer should have updated total
        XCTAssertEqual(sut.secondsTotal, 3, "Total should now be 3 seconds")
        XCTAssertEqual(sut.timerState, .running, "Timer should still be running")

        // When - Wait for extended timer to complete (MockClock makes this ~30ms)
        await waitForTimerCompletion(sut, timeout: 0.5)

        // Then - Timer should be completed
        XCTAssertEqual(sut.timerState, .completed, "Timer should be completed")
        XCTAssertEqual(sut.secondsRemaining, 0, "No time should remain")
    }

    // MARK: - Settings Integration Tests

    func testSettingsChange_ReflectsInTimerBehavior() async {
        // Given - Sound is enabled by default
        XCTAssertTrue(settingsStore.soundEnabled, "Sound should be enabled by default")

        // When - Disable sound
        settingsStore.soundEnabled = false

        // Then - Sound setting should be persisted
        XCTAssertFalse(settingsStore.soundEnabled, "Sound should be disabled")

        // Given - Start and complete a timer
        _ = sut.startNewTimer(minutes: 0, seconds: 1)
        var completionHandlerCalled = false

        sut.onTimerCompleted {
            completionHandlerCalled = true
        }

        // When - Wait for timer to complete (MockClock makes this ~10ms)
        await waitForTimerCompletion(sut, timeout: 0.5)

        // Then - Completion handler should still be called (sound setting doesn't affect this)
        XCTAssertTrue(completionHandlerCalled, "Completion handler should be called")
        XCTAssertEqual(sut.timerState, .completed, "Timer should be completed")

        // Note: Actual audio playback testing would require mocking AVAudioPlayer
        // This test verifies that settings changes are reflected in the store
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
