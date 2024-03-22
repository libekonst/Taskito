//
//  TaskitoApp.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 12/3/24.
//

import SwiftUI

@main
struct TaskitoApp: App {
    var body: some Scene {
        MenuBarExtra("Taskito", systemImage: "stopwatch") {
            ContentView()
        }.menuBarExtraStyle(.window)
    }
}
