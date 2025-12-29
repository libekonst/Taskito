//
//  TimerSmokeTests.swift
//  TaskitoTests
//
//  Created by Konstantinos Liberopoulos on 29/12/24.
//

@testable import Taskito
import XCTest

/// Smoke tests using real system timers (not mocked)
/// These tests are intentionally slow to validate that Timer.publish actually works
/// We only have a few critical smoke tests here - most tests use MockClock for speed
final class TimerSmokeTests: XCTestCase {
    var sut: CountdownStore!

    override func setUpWithError() throws {
        try super.setUpWithError()
        // Use real SystemClock (default)
        sut = CountdownStore()
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    // MARK: - Real Timer Smoke Tests

    func testRealTimer_2SecondCountdown_CompletesCorrectly() async {
        // Given - 2 second timer with REAL system clock
        let result = sut.startNewTimer(minutes: 0, seconds: 2)

        // Then - Timer should start
        if case .failure(let error) = result {
            XCTFail("Expected success, got failure: \(error)")
        }
        XCTAssertEqual(sut.timerState, .running)
        XCTAssertEqual(sut.secondsTotal, 2)

        // When - Wait for REAL timer to complete (this actually takes 2 seconds)
        await waitForTimerCompletion(sut, timeout: 3.0)

        // Then - Timer should be completed
        XCTAssertEqual(sut.timerState, .completed, "Timer should be completed")
        XCTAssertEqual(sut.secondsRemaining, 0, "Seconds remaining should be 0")
    }

    func testRealTimer_CompletionHandler_CalledCorrectly() async {
        // Given - Timer with completion handler using REAL clock
        var handlerWasCalled = false

        sut.onTimerCompleted {
            handlerWasCalled = true
        }

        // When - Start 1 second timer and wait for REAL completion
        _ = sut.startNewTimer(minutes: 0, seconds: 1)
        await waitForTimerCompletion(sut, timeout: 2.0)

        // Then - Handler should be called after real 1 second delay
        XCTAssertTrue(handlerWasCalled, "Completion handler should have been called")
        XCTAssertEqual(sut.timerState, .completed)
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
