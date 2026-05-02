//
//  KindledApp.swift
//  Kindled
//
//  Created by Luka on 01.05.26.
//

import SwiftUI
import SwiftData

@main
struct KindledApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Habit.self, HabitEntry.self, HabitReminder.self])
    }
}
