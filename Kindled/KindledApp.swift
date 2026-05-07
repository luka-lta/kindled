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
    @State private var adManager = AdManager()
    @State private var consentManager = ConsentManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(adManager)
                .environment(consentManager)
                .task {
                    await MainActor.run {
                        consentManager.requestConsentAndStart {
                            adManager.start()
                        }
                    }
                }
        }
        .modelContainer(for: [Habit.self, HabitEntry.self, HabitReminder.self])
    }
}
