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

    /** The timer is currently counting down. This will be false either when the timer is paused or cancelled. */
    @Published var isRunning = false

    /** The total seconds that have been scheduled for countdown. */
    @Published var secondsTotal: Int = 0

    /** Seconds that have passed while the timer was running. This value is to 0 when the timer finishes or is somehow depleted. Pausing will not affect this. */
    @Published var secondsElapsed: Int = 0

    /** The timer has either finished counting down to 0 or it has ben cancelled. */
    var isTimerDepleted: Bool {
        return secondsElapsed >= secondsTotal
    }

    /** Seconds remaining until the timer is depleted. The timer stops when it counts to 0. */
    var secondsRemaining: Int {
        guard !isTimerDepleted else { return 0 }

        return secondsTotal - secondsElapsed
    }

    // -- Play / Pause actions
    /** Resumes a paused timer or initializes a fresh one. */
    func resumeTimer() {
        guard !isRunning else { return }

        isRunning = true
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [self] _ in
                if self.isTimerDepleted {
                    self.timer?.cancel()
                    self.notifyTimerCompleted()
                    self.isRunning = false
                }
                else {
                    self.secondsElapsed += 1
                }
            }
    }

    /** Pauses a running timer. It can later be resumed. */
    func pauseTimer() {
        isRunning = false
        timer?.cancel()
    }

    /** Toggles between pausing and resuming the timer. */
    func toggleTimer() {
        if isRunning {
            pauseTimer()
        }
        else {
            resumeTimer()
        }
    }

    // -- Reset timer and start over actions\
    /** Cancels the current timer and clears the remaining time. */
    func resetTimer() {
        pauseTimer()
        secondsTotal = 0
        secondsElapsed = 0
    }

    /** Creates a fresh timer instance and immediately starts counting down. */
    func createNewTimer(minutes: Int, seconds: Int) {
        resetTimer()
        secondsTotal = minutes * SECONDS_IN_MINUTE + seconds
        resumeTimer()
    }

    // -- Notify timer completed
    private var onTimerCompletedPublisher = EventPublisher<Void>()
    private func notifyTimerCompleted() {
        onTimerCompletedPublisher.publish(())
    }
    /** Fires an event when the timer successfully finishes counting down to 0.  */
    func onTimerCompleted(handler: @escaping () -> Void) {
        onTimerCompletedPublisher.register(handler)
    }
}
