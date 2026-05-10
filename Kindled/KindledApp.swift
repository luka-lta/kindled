//
//  KindledApp.swift
//  Kindled
//
//  Created by Luka on 01.05.26.
//

import SwiftUI
import SwiftData
import FirebaseCore
import FirebaseAnalytics

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct KindledApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var adManager = AdManager()
    @State private var consentManager = ConsentManager()

    init() {}

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
