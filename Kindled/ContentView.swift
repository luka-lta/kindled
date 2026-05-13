//
//  ContentView.swift
//  habbit-tracker
//
//  Created by Luka on 01.05.26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage(StorageKeys.appAppearance) private var appearanceRaw: String = "System"
    @AppStorage(StorageKeys.appTheme) private var themeRaw: String = "Purple"
    @AppStorage(StorageKeys.appLanguage) private var appLanguage: String = "system"
    @AppStorage(StorageKeys.hasSeenOnboarding) private var hasSeenOnboarding = false
    @State private var achievementManager = AchievementManager()
    @State private var rootID = UUID()
    @State private var selectedTab: Int = 0
    @Query var habits: [Habit]

    private var remainingToday: Int {
        habits.filter { !$0.isCompletedToday }.count
    }

    private var appLocale: Locale {
        appLanguage == "system" ? Locale.current : Locale(identifier: appLanguage)
    }

    private var preferredColorScheme: ColorScheme? {
        switch appearanceRaw {
        case "Light": return .light
        case "Dark":  return .dark
        default:      return nil
        }
    }

    private var activeThemeColor: Color {
        AppTheme(rawValue: themeRaw)?.color ?? AppTheme.purple.color
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .id(rootID)
                .tabItem { Label("Habits", systemImage: "checkmark.circle.fill") }
                .badge(remainingToday)
                .tag(0)
            StatisticsView()
                .id(rootID)
                .tabItem { Label("Stats", systemImage: "chart.bar.fill") }
                .tag(1)
            NavigationStack {
                AchievementsView()
            }
            .id(rootID)
            .tabItem { Label("Achievements", systemImage: "trophy.fill") }
            .tag(2)
            SettingsView()
                .id(rootID)
                .tabItem { Label("Settings", systemImage: "gear") }
                .tag(3)
        }
        .tint(activeThemeColor)
        .environment(\.themeColor, activeThemeColor)
        .environment(\.locale, appLocale)
        .environment(achievementManager)
        .preferredColorScheme(preferredColorScheme)
        .fullScreenCover(isPresented: .constant(!hasSeenOnboarding)) {
            OnboardingView()
        }
        .onChange(of: appLanguage) { _, newValue in
            applyLanguage(newValue)
            rootID = UUID()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                NotificationManager.shared.scheduleStreakProtectionReminder(habits: habits)
            }
        }
        .task {
            applyLanguage(appLanguage)
        }
    }

    private func applyLanguage(_ language: String) {
        if language == "system" {
            UserDefaults.standard.removeObject(forKey: "AppleLanguages")
        } else {
            UserDefaults.standard.set([language], forKey: "AppleLanguages")
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Habit.self, HabitEntry.self, HabitReminder.self], inMemory: true)
}
