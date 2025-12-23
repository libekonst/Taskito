//
//  CountdownStore.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 8/7/24.
//

import Combine
import Foundation

private let SECONDS_IN_MINUTE = 60

class CountdownStore: ObservableObject {
    private var timer: Cancellable?

    @Published var timerState: TimerState = .idle

    /** The total seconds that have been scheduled for countdown. */
    @Published var secondsTotal: Int = 0

    /** The initial seconds set when the timer was first started (excludes added time). */
    private var initialSecondsTotal: Int = 0

    /** Seconds that have passed while the timer was running. This value is to 0 when the timer finishes or is somehow depleted. Pausing will not affect this. */
    @Published var secondsElapsed: Int = 0

    /** Seconds remaining until the timer is depleted. The timer stops when it counts to 0. */
    var secondsRemaining: Int {
        guard !isTimerDepleted else { return 0 }

        return secondsTotal - secondsElapsed
    }

    /** The timer has finished counting down to 0. */
    private var isTimerDepleted: Bool {
        return secondsElapsed >= secondsTotal
    }

    /** Creates a fresh timer instance and immediately starts counting down. */
    func startNewTimer(minutes: Int, seconds: Int) {
        depleteTimer()
        secondsTotal = minutes * SECONDS_IN_MINUTE + seconds
        initialSecondsTotal = secondsTotal
        startTimer()
    }

    /** Cancels the current timer. A new timer instance can be created again. */
    func cancelTimer() {
        depleteTimer()
        timerState = .cancelled
    }

    /** Toggles between pausing and resuming the timer. */
    func togglePlayPauseTimer() {
        if timerState == .running {
            pauseTimer()
        }
        else {
            startTimer()
        }
    }

    /** Adds additional time to the current timer. */
    func addTime(seconds: Int) {
        guard timerState == .running || timerState == .paused else { return }
        secondsTotal += seconds
    }

    /** Restarts the current timer from the beginning with the same initial duration. */
    func restartTimer() {
        guard timerState == .running || timerState == .paused else { return }
        pauseTimer() // Also resets state so startTimer() guard passes
        depleteTimer()
        secondsTotal = initialSecondsTotal
        startTimer()
    }

    /** Resumes a paused timer or initializes a fresh one. */
    private func startTimer() {
        guard timerState != .running else { return }

        timerState = .running
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [self] _ in
                if self.timerState == .running, self.isTimerDepleted {
                    self.completeTimer()
                    self.notifyTimerCompleted()
                }
                else {
                    self.secondsElapsed += 1
                }
            }
    }

    /** Pauses a running timer. It can later be resumed. */
    private func pauseTimer() {
        timer?.cancel()
        timerState = .paused
    }

    /** Completes the current timer and clears any remaining time. */
    private func completeTimer() {
        depleteTimer()
        timerState = .completed
    }

    /** Clears the remaining time. */
    private func depleteTimer() {
        secondsTotal = 0
        secondsElapsed = 0
        timer?.cancel()
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

enum TimerState {
    /** The timer is currently counting down. This will be false if the timer is paused, cancelled, or completed. */
    case running,
         /** The timer has successfully finished counting down.  */
         completed,
         /** The timer is cancelled by the user. */
         cancelled,
         /** The timer is paused by the user. */
         paused,
         /** The initial default state. This state won't normally be reached after a timer lifecycle has been initiated. */
         idle
}
