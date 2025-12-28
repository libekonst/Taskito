//
//  StandardTimerPolicy.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 11/5/24.
//

import Foundation

class StandardTimerPolicy: TimerPolicy {
    var minutesLimits: Limits {
        return Limits(min: 0, max: 99, digitCount: 2)
    }

    var secondsLimits: Limits {
        return Limits(min: 0, max: 59, digitCount: 2)
    }

    func toReadableTime(seconds: Int) -> String {
        return Duration.seconds(seconds).formatted(.time(pattern: .minuteSecond(padMinuteToLength: 2)))
    }

    private(set) lazy var minutesFormatter: Formatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.minimumIntegerDigits = minutesLimits.digitCount
        formatter.maximum = minutesLimits.max as NSNumber
        formatter.minimum = minutesLimits.min as NSNumber
        return formatter
    }()

    private(set) lazy var secondsFormatter: Formatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.minimumIntegerDigits = secondsLimits.digitCount
        formatter.maximum = secondsLimits.max as NSNumber
        formatter.minimum = secondsLimits.min as NSNumber
        return formatter
    }()
}
