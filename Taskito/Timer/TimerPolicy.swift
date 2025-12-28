//
//  TimeFormatter.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 22/3/24.
//

import Foundation

/** A set of rules and guidelines that dictate a behavior for application countdowns. */
protocol TimerPolicy {
    var minutesLimits: Limits { get }
    var secondsLimits: Limits { get }
    func toReadableTime(seconds: Int) -> String
    var minutesFormatter: Formatter { get }
    var secondsFormatter: Formatter { get }
}

struct Limits {
    let min: Int
    let max: Int
    let digitCount: Int
}
