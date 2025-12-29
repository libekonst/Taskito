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

