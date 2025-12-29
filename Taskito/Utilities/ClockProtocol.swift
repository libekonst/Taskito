//
//  ClockProtocol.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 29/12/25.
//

import Combine
import Foundation

/// Protocol for abstracting time-based operations, enabling fast testing with mock clocks
protocol ClockProtocol {
    /// Creates a timer publisher that fires at the specified interval
    /// - Parameter interval: Time interval between timer fires (in seconds)
    /// - Returns: A publisher that emits the current date at each interval
    func createTimer(interval: TimeInterval) -> AnyPublisher<Date, Never>
}

// MARK: - System Clock (Production)

/// Production clock implementation using real system timers
final class SystemClock: ClockProtocol {
    func createTimer(interval: TimeInterval) -> AnyPublisher<Date, Never> {
        Timer.publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .eraseToAnyPublisher()
    }
}

// MARK: - Mock Clock (Testing)

/// Mock clock for testing - ticks much faster than real time
/// Allows tests to run in milliseconds instead of seconds
final class MockClock: ClockProtocol {
    /// How often the mock timer fires (default: 10ms for fast tests)
    var tickInterval: TimeInterval = 0.01

    /// How much simulated time passes per tick (default: 1 second)
    var simulatedSecondsPerTick: TimeInterval = 1.0

    private var currentSimulatedTime = Date()

    func createTimer(interval: TimeInterval) -> AnyPublisher<Date, Never> {
        // Validate interval matches what we simulate
        // In practice, CountdownStore uses 1-second intervals
        assert(interval == simulatedSecondsPerTick,
               "MockClock configured for \(simulatedSecondsPerTick)s ticks but got \(interval)s")

        return Timer.publish(every: tickInterval, on: .main, in: .common)
            .autoconnect()
            .map { [weak self] _ in
                guard let self = self else { return Date() }
                // Advance simulated time by the configured amount
                self.currentSimulatedTime.addTimeInterval(self.simulatedSecondsPerTick)
                return self.currentSimulatedTime
            }
            .eraseToAnyPublisher()
    }

    /// Reset the mock clock to current time
    func reset() {
        currentSimulatedTime = Date()
    }
}
