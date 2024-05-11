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
