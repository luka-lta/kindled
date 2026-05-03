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
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var achievementManager = AchievementManager()

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
        .tint(activeThemeColor)
        .environment(\.themeColor, activeThemeColor)
        .environment(achievementManager)
        .preferredColorScheme(preferredColorScheme)
        .fullScreenCover(isPresented: .constant(!hasSeenOnboarding)) {
            OnboardingView()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Habit.self, HabitEntry.self, HabitReminder.self], inMemory: true)
}
