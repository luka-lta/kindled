//
//  ContentView.swift
//  habbit-tracker
//
//  Created by Luka on 01.05.26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @AppStorage("appAppearance") private var appearanceRaw: String = "System"
    @AppStorage("appTheme") private var themeRaw: String = "Purple"
    @AppStorage("appLanguage") private var appLanguage: String = "system"
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var achievementManager = AchievementManager()
    @State private var rootID = UUID()

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
        TabView {
            HomeView()
                .tabItem {
                    Label("Habits", systemImage: "checkmark.circle.fill")
                }
            StatisticsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
            NavigationStack {
                AchievementsView()
            }
            .tabItem {
                Label("Achievements", systemImage: "trophy.fill")
            }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .id(rootID)
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
