//
//  Countdown.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 22/3/24.
//

import Foundation

let secondsInMinute = 60

class Countdown: ObservableObject {
    @Published var minutes = 25
    @Published var seconds = 00
    @Published var elapsedSeconds = 0
    
    /** The total time to count in seconds. */
    var timeTotal: Int {
        return minutes * secondsInMinute + seconds
    }
    
    /** The amount of seconds remaining until the timer is depleted. */
    var timeRemaining: Int {
        guard elapsedSeconds < timeTotal else { return 0 }

        return timeTotal - elapsedSeconds
    }
}
