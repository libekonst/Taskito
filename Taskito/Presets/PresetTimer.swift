//
//  PresetTimer.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 13/11/25.
//


import Foundation

/// Represents a preset timer configuration
struct PresetTimer: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let minutes: Int
    let seconds: Int

    init(id: UUID = UUID(), name: String, minutes: Int, seconds: Int = 0) {
        self.id = id
        self.name = name
        self.minutes = minutes
        self.seconds = seconds
    }

    /// Total duration in seconds
    var totalSeconds: Int {
        minutes * 60 + seconds
    }
}

/// Default preset timers
extension PresetTimer {
    static let pomodoro = PresetTimer(name: "Pomodoro", minutes: 25)
    static let shortBreak = PresetTimer(name: "Short Break", minutes: 5)
    static let longBreak = PresetTimer(name: "Long Break", minutes: 15)

    static let defaults = [pomodoro, shortBreak, longBreak]
}
