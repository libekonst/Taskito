//
//  TaskitoApp.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 12/3/24.
//

import SwiftUI

@main
struct TaskitoApp: App {
    @ObservedObject private var countdownStore = CountdownStore()
    private var timerPolicy = StandardTimerPolicy()
    private var audioIndication = AudioIndication()

    var body: some Scene {
        MenuBarExtra {
            MenuBarWindowContent(countdownStore: countdownStore, timerPolicy: timerPolicy)
                .onAppear {
                    countdownStore.onTimerCompleted {
                        audioIndication.play()
                    }
                }
        } label: {
            MenuBarLabel(countdownStore: countdownStore, timerPolicy: timerPolicy)
        }
        .menuBarExtraStyle(.window)
    }
}
