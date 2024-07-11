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
    private let timerPolicy = StandardTimerPolicy()

    var body: some Scene {
        MenuBarExtra {
            ContentView(countdownStore: countdownStore)
        } label: {
            MenuBarLabel(countdownStore: countdownStore, timerPolicy: timerPolicy)
        }
        .menuBarExtraStyle(.window)
    }
}
