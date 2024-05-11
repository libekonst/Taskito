//
//  StandardTimerPolicy.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 11/5/24.
//

import Foundation

class StandardTimerPolicy: TimerPolicy {
    var limits: Limits {
        return Limits(min: 0, max: 99, digitCount: 2)
    }

    func toReadableTime(seconds: Int) -> String {
        return Duration.seconds(seconds).formatted(.time(pattern: .minuteSecond(padMinuteToLength: 2)))
    }

    private lazy var singletonFormatter = FormatterSingleton(limits: limits)
    var formatter: Formatter {
        return singletonFormatter.formatter
    }
}

private class FormatterSingleton {
    private var currentInstance: Formatter?
    private let limits: Limits

    init(limits: Limits) {
        self.limits = limits
    }

    private func createFormatter() -> Formatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.minimumIntegerDigits = limits.digitCount
        formatter.maximum = limits.max as NSNumber
        formatter.minimum = limits.min as NSNumber

        return formatter
    }

    var formatter: Formatter {
        if let formatter = currentInstance {
            return formatter
        }

        let formatter = createFormatter()
        currentInstance = formatter
        return formatter
    }
}
