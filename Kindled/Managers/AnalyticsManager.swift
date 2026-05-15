import FirebaseAnalytics
import Foundation

enum AnalyticsManager {

    static func habitCompleted(name: String, category: String, streak: Int, hasScheduledTime: Bool) {
        Analytics.logEvent("habit_completed", parameters: [
            "habit_category": category,
            "streak_days": streak,
            "has_scheduled_time": hasScheduledTime ? 1 : 0
        ])
    }

    static func habitUncompleted(category: String) {
        Analytics.logEvent("habit_uncompleted", parameters: [
            "habit_category": category
        ])
    }

    static func streakMilestone(streak: Int, habitName: String) {
        Analytics.logEvent("streak_milestone", parameters: [
            "streak_days": streak,
            "habit_name": habitName
        ])
    }

    static func habitCreated(category: String, frequency: String, hasReminder: Bool, hasScheduledTime: Bool) {
        Analytics.logEvent("habit_created", parameters: [
            "habit_category": category,
            "habit_frequency": frequency,
            "has_reminder": hasReminder ? 1 : 0,
            "has_scheduled_time": hasScheduledTime ? 1 : 0
        ])
    }

    static func habitEdited(category: String, frequency: String) {
        Analytics.logEvent("habit_edited", parameters: [
            "habit_category": category,
            "habit_frequency": frequency
        ])
    }

    static func habitDeleted(category: String) {
        Analytics.logEvent("habit_deleted", parameters: [
            "habit_category": category
        ])
    }

    static func achievementUnlocked(id: String, name: String) {
        Analytics.logEvent("achievement_unlocked", parameters: [
            "achievement_id": id,
            "achievement_name": name
        ])
    }

    static func onboardingCompleted(theme: String, homeView: String) {
        Analytics.logEvent("onboarding_completed", parameters: [
            "selected_theme": theme,
            "home_view": homeView
        ])
    }
}
