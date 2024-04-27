//
//  TimeFormatter.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 22/3/24.
//

import Foundation

enum TimerPolicy {
    static let Formatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.minimumIntegerDigits = Limits.digitCount
        formatter.maximum = (Limits.max) as NSNumber
        formatter.minimum = (Limits.min) as NSNumber
        return formatter
    }()

    static func toReadableTime(seconds: Int) -> String {
        return Duration.seconds(seconds).formatted(.time(pattern: .minuteSecond(padMinuteToLength: 2)))
    }

    enum Limits {
        static let max = 99
        static let min = 0
        static let digitCount = 2
    }
}
