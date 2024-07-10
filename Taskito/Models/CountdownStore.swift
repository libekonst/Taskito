//
//  CountdownStore.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 8/7/24.
//

import Combine
import Foundation

private let SECONDS_IN_MINUTE = 60

private typealias EventHandler = () -> Void

class CountdownStore: ObservableObject {
    private var timer: Cancellable?

    @Published var isRunning = false
    @Published var secondsTotal: Int = 0
    @Published var secondsElapsed: Int = 0

    /** Seconds remaining before the timer is depleted. The timer stops when it counts to 0. */
    var secondsRemaining: Int {
        guard !isTimerDepleted else { return 0 }

        return secondsTotal - secondsElapsed
    }

    /** The timer has counted down to 0 and has stopped. */
    var isTimerDepleted: Bool {
        return secondsElapsed >= secondsTotal
    }

    // Play / Pause actions
    func startTimer() {
        guard !isRunning else { return }

        isRunning = true
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [self] _ in
                if self.isTimerDepleted {
                    self.timer?.cancel()
                    self.notifyTimerCompleted()
                }
                else {
                    self.secondsElapsed += 1
                }
            }
    }

    func pauseTimer() {
        isRunning = false
        timer?.cancel()
    }

    func toggleTimer() {
        if isRunning {
            pauseTimer()
        }
        else {
            startTimer()
        }
    }

    // Reset timer and start over actions
    func resetTimer() {
        pauseTimer()
        secondsTotal = 0
        secondsElapsed = 0
    }

    func createNewTimer(minutes: Int, seconds: Int) {
        resetTimer()
        secondsTotal = minutes * SECONDS_IN_MINUTE + seconds
        startTimer()
    }

    // Notify timer completed
    private var onTimerCompletedPublisher = EventPublisher<Void>()
    func onTimerCompleted(handler: @escaping () -> Void) {
        onTimerCompletedPublisher.register(handler)
    }

    private func notifyTimerCompleted() {
        onTimerCompletedPublisher.publish(())
    }
}
