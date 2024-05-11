//
//  TimeFormatter.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 22/3/24.
//

import Foundation

/** A set of rules and guidelines that dictate a behavior for application countdowns. */
protocol TimerPolicy {
    var limits: Limits { get }
    func toReadableTime(seconds: Int) -> String
    var formatter: Formatter { get }
}

struct Limits {
    let min: Int
    let max: Int
    let digitCount: Int
}

class StandardTimerPolicy: TimerPolicy {
    var limits: Limits {
        return Limits(min: 0, max: 99, digitCount: 2)
    }

    func toReadableTime(seconds: Int) -> String {
        return Duration.seconds(seconds).formatted(.time(pattern: .minuteSecond(padMinuteToLength: 2)))
    }

    private func createFormatter() -> Formatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.minimumIntegerDigits = limits.digitCount
        formatter.maximum = limits.max as NSNumber
        formatter.minimum = limits.min as NSNumber

        return formatter
    }

    private var formatterSingleton: Formatter?
    var formatter: Formatter {
        if let formatter = formatterSingleton {
            return formatter
        }

        let formatter = createFormatter()
        formatterSingleton = formatter
        return formatter
    }
}

//    var formatter: Formatter = {
//        let formatter = NumberFormatter()
//        formatter.numberStyle = .none
//        formatter.minimumIntegerDigits = limits.digitCount
//        formatter.maximum = (Limits.max) as NSNumber
//        formatter.minimum = (Limits.min) as NSNumber
//        return formatter
//    }()
