//
//  CountdownStoreTests.swift
//  TaskitoTests
//
//  Created by Konstantinos Liberopoulos on 28/12/24.
//

@testable import Taskito
import XCTest

final class CountdownStoreTests: XCTestCase {
    var sut: CountdownStore!

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = CountdownStore()
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    // MARK: - Start Timer Tests

    func testStartNewTimer_ValidDuration_StartsTimer() {
        // Given
        let minutes = 25
        let seconds = 0

        // When
        let result = sut.startNewTimer(minutes: minutes, seconds: seconds)

        // Then
        if case .failure(let error) = result {
            XCTFail("Expected success, got failure: \(error)")
        }
        XCTAssertEqual(sut.timerState, .running)
        XCTAssertEqual(sut.secondsTotal, 1500)
    }

    func testStartNewTimer_ZeroDuration_AllowsZeroTimer() {
        // Given
        let minutes = 0
        let seconds = 0

        // When
        let result = sut.startNewTimer(minutes: minutes, seconds: seconds)

        // Then - Zero duration is allowed (expected behavior)
        if case .failure(let error) = result {
            XCTFail("Expected success, got failure: \(error)")
        }
        XCTAssertEqual(sut.timerState, .running)
        XCTAssertEqual(sut.secondsTotal, 0)
    }

    func testStartNewTimer_NegativeDuration_ReturnsInvalidDuration() {
        // Given
        let minutes = -5
        let seconds = 0

        // When
        let result = sut.startNewTimer(minutes: minutes, seconds: seconds)

        // Then
        guard case .failure(let error) = result else {
            XCTFail("Expected failure, got success")
            return
        }
        XCTAssertEqual(error, .invalidDuration)
    }

    func testStartNewTimer_WhileRunning_ReturnsTimerAlreadyRunning() {
        // Given - Start first timer
        _ = sut.startNewTimer(minutes: 10, seconds: 0)
        XCTAssertEqual(sut.timerState, .running)

        // When - Try to start second timer
        let result = sut.startNewTimer(minutes: 5, seconds: 0)

        // Then
        guard case .failure(let error) = result else {
            XCTFail("Expected failure, got success")
            return
        }
        XCTAssertEqual(error, .timerAlreadyRunning)
        // First timer should still be running
        XCTAssertEqual(sut.timerState, .running)
        XCTAssertEqual(sut.secondsTotal, 600) // Original timer duration
    }

    func testStartNewTimer_WhilePaused_ReturnsTimerAlreadyRunning() {
        // Given - Start and pause timer
        _ = sut.startNewTimer(minutes: 10, seconds: 0)
        _ = sut.togglePlayPauseTimer()
        XCTAssertEqual(sut.timerState, .paused)

        // When - Try to start new timer
        let result = sut.startNewTimer(minutes: 5, seconds: 0)

        // Then
        guard case .failure(let error) = result else {
            XCTFail("Expected failure, got success")
            return
        }
        XCTAssertEqual(error, .timerAlreadyRunning)
        XCTAssertEqual(sut.timerState, .paused)
    }

    // MARK: - Toggle Play/Pause Tests

    func testTogglePlayPauseTimer_WhileRunning_PausesTimer() {
        // Given - Running timer
        _ = sut.startNewTimer(minutes: 5, seconds: 0)
        XCTAssertEqual(sut.timerState, .running)

        // When
        let result = sut.togglePlayPauseTimer()

        // Then
        if case .failure(let error) = result {
            XCTFail("Expected success, got failure: \(error)")
        }
        XCTAssertEqual(sut.timerState, .paused)
    }

    func testTogglePlayPauseTimer_WhilePaused_ResumesTimer() {
        // Given - Paused timer
        _ = sut.startNewTimer(minutes: 5, seconds: 0)
        _ = sut.togglePlayPauseTimer()
        XCTAssertEqual(sut.timerState, .paused)

        // When
        let result = sut.togglePlayPauseTimer()

        // Then
        if case .failure(let error) = result {
            XCTFail("Expected success, got failure: \(error)")
        }
        XCTAssertEqual(sut.timerState, .running)
    }

    func testTogglePlayPauseTimer_WhileIdle_ReturnsNoActiveTimer() {
        // Given - Idle state
        XCTAssertEqual(sut.timerState, .idle)

        // When
        let result = sut.togglePlayPauseTimer()

        // Then
        guard case .failure(let error) = result else {
            XCTFail("Expected failure, got success")
            return
        }
        XCTAssertEqual(error, .noActiveTimer)
        XCTAssertEqual(sut.timerState, .idle)
    }

    // MARK: - Cancel Timer Tests

    func testCancelTimer_WhileRunning_CancelsAndSetsStateToCancelled() {
        // Given - Running timer
        _ = sut.startNewTimer(minutes: 10, seconds: 0)
        XCTAssertEqual(sut.timerState, .running)

        // When
        let result = sut.cancelTimer()

        // Then
        if case .failure(let error) = result {
            XCTFail("Expected success, got failure: \(error)")
        }
        XCTAssertEqual(sut.timerState, .cancelled)
        XCTAssertEqual(sut.secondsTotal, 0)
        XCTAssertEqual(sut.secondsElapsed, 0)
    }

    func testCancelTimer_WhilePaused_CancelsSuccessfully() {
        // Given - Paused timer
        _ = sut.startNewTimer(minutes: 10, seconds: 0)
        _ = sut.togglePlayPauseTimer()
        XCTAssertEqual(sut.timerState, .paused)

        // When
        let result = sut.cancelTimer()

        // Then
        if case .failure(let error) = result {
            XCTFail("Expected success, got failure: \(error)")
        }
        XCTAssertEqual(sut.timerState, .cancelled)
    }

    func testCancelTimer_WhileIdle_ReturnsNoActiveTimer() {
        // Given - Idle state
        XCTAssertEqual(sut.timerState, .idle)

        // When
        let result = sut.cancelTimer()

        // Then
        guard case .failure(let error) = result else {
            XCTFail("Expected failure, got success")
            return
        }
        XCTAssertEqual(error, .noActiveTimer)
    }

    // MARK: - Add Time Tests

    func testAddTime_PositiveSeconds_IncreasesSecondsTotal() {
        // Given - Running timer
        _ = sut.startNewTimer(minutes: 10, seconds: 0)
        let originalTotal = sut.secondsTotal

        // When
        let result = sut.addTime(seconds: 60)

        // Then
        if case .failure(let error) = result {
            XCTFail("Expected success, got failure: \(error)")
        }
        XCTAssertEqual(sut.secondsTotal, originalTotal + 60)
    }

    func testAddTime_ZeroSeconds_ReturnsInvalidAmount() {
        // Given - Running timer
        _ = sut.startNewTimer(minutes: 10, seconds: 0)

        // When
        let result = sut.addTime(seconds: 0)

        // Then
        guard case .failure(let error) = result else {
            XCTFail("Expected failure, got success")
            return
        }
        XCTAssertEqual(error, .invalidAmount)
    }

    func testAddTime_NegativeSeconds_ReturnsInvalidAmount() {
        // Given - Running timer
        _ = sut.startNewTimer(minutes: 10, seconds: 0)

        // When
        let result = sut.addTime(seconds: -30)

        // Then
        guard case .failure(let error) = result else {
            XCTFail("Expected failure, got success")
            return
        }
        XCTAssertEqual(error, .invalidAmount)
    }

    func testAddTime_WhileIdle_ReturnsNoActiveTimer() {
        // Given - Idle state
        XCTAssertEqual(sut.timerState, .idle)

        // When
        let result = sut.addTime(seconds: 60)

        // Then
        guard case .failure(let error) = result else {
            XCTFail("Expected failure, got success")
            return
        }
        XCTAssertEqual(error, .noActiveTimer)
    }

    // MARK: - Restart Timer Tests

    func testRestartTimer_ResetsToInitialDuration() {
        // Given - Running timer with added time
        _ = sut.startNewTimer(minutes: 10, seconds: 0)
        let initialTotal = sut.secondsTotal
        _ = sut.addTime(seconds: 120) // Add 2 minutes
        XCTAssertNotEqual(sut.secondsTotal, initialTotal)

        // When
        let result = sut.restartTimer()

        // Then
        if case .failure(let error) = result {
            XCTFail("Expected success, got failure: \(error)")
        }
        XCTAssertEqual(sut.secondsTotal, initialTotal)
        XCTAssertEqual(sut.timerState, .running)
        XCTAssertEqual(sut.secondsElapsed, 0)
    }

    func testRestartTimer_WhileIdle_ReturnsNoActiveTimer() {
        // Given - Idle state
        XCTAssertEqual(sut.timerState, .idle)

        // When
        let result = sut.restartTimer()

        // Then
        guard case .failure(let error) = result else {
            XCTFail("Expected failure, got success")
            return
        }
        XCTAssertEqual(error, .noActiveTimer)
    }

    // MARK: - Seconds Remaining Tests

    func testSecondsRemaining_CalculatesCorrectly() {
        // Given - Start timer
        _ = sut.startNewTimer(minutes: 10, seconds: 0)
        XCTAssertEqual(sut.secondsRemaining, 600)

        // When - Simulate time passing (we can't actually wait, so we'll test the calculation)
        // The actual countdown happens via Timer.publish, which we can't easily test without mocking
        // But we can verify the calculation is correct based on current state
        XCTAssertEqual(sut.secondsRemaining, sut.secondsTotal - sut.secondsElapsed)
    }

    // MARK: - Edge Cases

    func testStartNewTimer_MaxDuration_HandlesCorrectly() {
        // Given
        let minutes = 99
        let seconds = 59

        // When
        let result = sut.startNewTimer(minutes: minutes, seconds: seconds)

        // Then
        if case .failure(let error) = result {
            XCTFail("Expected success, got failure: \(error)")
        }
        XCTAssertEqual(sut.timerState, .running)
        XCTAssertEqual(sut.secondsTotal, 5999)
    }

    func testMultipleRestarts_MaintainsCorrectState() {
        // Given - Start timer
        _ = sut.startNewTimer(minutes: 5, seconds: 0)
        let initialTotal = sut.secondsTotal

        // When - Restart multiple times
        _ = sut.restartTimer()
        _ = sut.restartTimer()
        _ = sut.restartTimer()

        // Then - Should maintain initial duration
        XCTAssertEqual(sut.secondsTotal, initialTotal)
        XCTAssertEqual(sut.timerState, .running)
        XCTAssertEqual(sut.secondsElapsed, 0)
    }

    func testAddTime_DuringPausedTimer_UpdatesCorrectly() {
        // Given - Paused timer
        _ = sut.startNewTimer(minutes: 10, seconds: 0)
        _ = sut.togglePlayPauseTimer()
        let originalTotal = sut.secondsTotal

        // When
        let result = sut.addTime(seconds: 180)

        // Then
        if case .failure(let error) = result {
            XCTFail("Expected success, got failure: \(error)")
        }
        XCTAssertEqual(sut.secondsTotal, originalTotal + 180)
        XCTAssertEqual(sut.timerState, .paused) // Should remain paused
    }
}
