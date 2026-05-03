import SwiftUI

@Observable
final class AchievementManager {
    private(set) var unlockedIDs: Set<String>
    private(set) var unlockDates: [String: Date]

    private let idsKey = "achievement_unlocked_ids"
    private let datesKey = "achievement_unlock_dates"

    init() {
        let stored = UserDefaults.standard.stringArray(forKey: "achievement_unlocked_ids") ?? []
        self.unlockedIDs = Set(stored)
        let storedDates = UserDefaults.standard.dictionary(forKey: "achievement_unlock_dates") as? [String: Double] ?? [:]
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
        UserDefaults.standard.set(Array(unlockedIDs), forKey: idsKey)
        let encoded = unlockDates.mapValues { $0.timeIntervalSince1970 }
        UserDefaults.standard.set(encoded, forKey: datesKey)
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
            guard !habits.isEmpty else { return false }
            let today = calendar.startOfDay(for: Date())
            return habits.allSatisfy { habit in
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
