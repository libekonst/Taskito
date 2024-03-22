//
//  TimeFormatter.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 22/3/24.
//

import Foundation

enum TimeFormatter {
    enum Restrictions {
        static let minutes = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .none
            formatter.maximum = 99
            return formatter
        }()

        static let seconds = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .none
            formatter.maximum = 99
            return formatter
        }()
    }
    

    static func formatSeconds(_ seconds: Int) -> String {
        return Duration.seconds(seconds).formatted(.time(pattern: .minuteSecond(padMinuteToLength: 2)))
    }
}
