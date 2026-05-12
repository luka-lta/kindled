import SwiftUI

@Observable
final class AchievementManager {
    private(set) var unlockedIDs: Set<String>
    private(set) var unlockDates: [String: Date]

    private static let idsKey = "achievement_unlocked_ids"
    private static let datesKey = "achievement_unlock_dates"

    init() {
        let stored = UserDefaults.standard.stringArray(forKey: Self.idsKey) ?? []
        self.unlockedIDs = Set(stored)
        let storedDates = UserDefaults.standard.dictionary(forKey: Self.datesKey) as? [String: Double] ?? [:]
        self.unlockDates = storedDates.mapValues { Date(timeIntervalSince1970: $0) }
    }

    func isUnlocked(_ id: String) -> Bool {
        unlockedIDs.contains(id)
    }

    func unlockDate(for id: String) -> Date? {
        unlockDates[id]
    }

    /// Check habits and return any newly unlocked achievements.
    @discardableResult
    func check(habits: [Habit]) -> [Achievement] {
        var newlyUnlocked: [Achievement] = []

        let candidates = Achievement.all.filter { !unlockedIDs.contains($0.id) }
        for achievement in candidates {
            if shouldUnlock(achievement.id, habits: habits) {
                unlock(achievement)
                newlyUnlocked.append(achievement)
            }
        }
        return newlyUnlocked
    }

    private func unlock(_ achievement: Achievement) {
        unlockedIDs.insert(achievement.id)
        unlockDates[achievement.id] = Date()
        persist()
    }

    private func persist() {
        UserDefaults.standard.set(Array(unlockedIDs), forKey: Self.idsKey)
        let encoded = unlockDates.mapValues { $0.timeIntervalSince1970 }
        UserDefaults.standard.set(encoded, forKey: Self.datesKey)
    }

    func progress(for id: String, habits: [Habit]) -> Double {
        if isUnlocked(id) { return 1.0 }
        let totalCompletions = habits.reduce(0) { $0 + $1.totalCompletions }
        let maxStreak = habits.map { $0.currentStreak }.max() ?? 0
        let calendar = Calendar.current
        switch id {
        case "first_flame":        return min(Double(totalCompletions), 1) / 1
        case "week_warrior":       return min(Double(maxStreak), 7) / 7
        case "month_master":       return min(Double(maxStreak), 30) / 30
        case "century":            return min(Double(maxStreak), 100) / 100
        case "dedicated":          return min(Double(totalCompletions), 25) / 25
        case "committed":          return min(Double(totalCompletions), 100) / 100
        case "veteran":            return min(Double(totalCompletions), 500) / 500
        case "collector":          return min(Double(habits.count), 3) / 3
        case "explorer":           return min(Double(habits.count), 5) / 5
        case "category_explorer":  return min(Double(Set(habits.map { $0.category }).count), 3) / 3
        case "on_fire":            return min(Double(habits.filter { $0.currentStreak >= 7 }.count), 3) / 3
        case "perfect_day":
            let dailyHabits = habits.filter { $0.frequency == .daily }
            guard !dailyHabits.isEmpty else { return 0 }
            let today = calendar.startOfDay(for: Date())
            let done = dailyHabits.filter { h in h.entries.contains { $0.isCompleted && calendar.startOfDay(for: $0.completedDate) == today } }.count
            return Double(done) / Double(dailyHabits.count)
        default: return 0
        }
    }

    func progressText(for id: String, habits: [Habit]) -> String {
        if isUnlocked(id) { return "" }
        let total = habits.reduce(0) { $0 + $1.totalCompletions }
        let maxStreak = habits.map { $0.currentStreak }.max() ?? 0
        let calendar = Calendar.current
        switch id {
        case "first_flame":        return "\(min(total, 1)) / 1"
        case "week_warrior":       return "\(min(maxStreak, 7)) / 7 days"
        case "month_master":       return "\(min(maxStreak, 30)) / 30 days"
        case "century":            return "\(min(maxStreak, 100)) / 100 days"
        case "dedicated":          return "\(min(total, 25)) / 25"
        case "committed":          return "\(min(total, 100)) / 100"
        case "veteran":            return "\(min(total, 500)) / 500"
        case "collector":          return "\(min(habits.count, 3)) / 3 habits"
        case "explorer":           return "\(min(habits.count, 5)) / 5 habits"
        case "category_explorer":  return "\(min(Set(habits.map { $0.category }).count, 3)) / 3 categories"
        case "on_fire":            return "\(min(habits.filter { $0.currentStreak >= 7 }.count, 3)) / 3 habits"
        case "perfect_day":
            let dailyHabits = habits.filter { $0.frequency == .daily }
            guard !dailyHabits.isEmpty else { return "0 / 0" }
            let today = calendar.startOfDay(for: Date())
            let done = dailyHabits.filter { h in h.entries.contains { $0.isCompleted && calendar.startOfDay(for: $0.completedDate) == today } }.count
            return "\(done) / \(dailyHabits.count) today"
        default: return ""
        }
    }

    private func shouldUnlock(_ id: String, habits: [Habit]) -> Bool {
        let totalCompletions = habits.reduce(0) { $0 + $1.totalCompletions }
        let maxStreak = habits.map { $0.currentStreak }.max() ?? 0
        let calendar = Calendar.current

        switch id {
        case "first_flame":
            return totalCompletions >= 1

        case "week_warrior":
            return maxStreak >= 7

        case "month_master":
            return maxStreak >= 30

        case "century":
            return maxStreak >= 100

        case "dedicated":
            return totalCompletions >= 25

        case "committed":
            return totalCompletions >= 100

        case "veteran":
            return totalCompletions >= 500

        case "collector":
            return habits.count >= 3

        case "explorer":
            return habits.count >= 5

        case "perfect_day":
            let dailyHabits = habits.filter { $0.frequency == .daily }
            guard !dailyHabits.isEmpty else { return false }
            let today = calendar.startOfDay(for: Date())
            return dailyHabits.allSatisfy { habit in
                habit.entries.contains {
                    $0.isCompleted && calendar.startOfDay(for: $0.completedDate) == today
                }
            }

        case "category_explorer":
            let categories = Set(habits.map { $0.category })
            return categories.count >= 3

        case "on_fire":
            return habits.filter { $0.currentStreak >= 7 }.count >= 3

        default:
            return false
        }
    }
}
