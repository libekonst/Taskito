//
//  Countdown.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 22/3/24.
//

import Foundation

class Countdown: ObservableObject {
    @Published var minutes = 25
    @Published var seconds = 00

    private let secondsInMinute = 60

    var secondsTotal: Int {
        return minutes * secondsInMinute + seconds
    }
}
