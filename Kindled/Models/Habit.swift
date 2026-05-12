import SwiftData
import Foundation

enum HabitFrequency: String, Codable, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
}

@Model
final class Habit {
    var id: UUID
    var title: String
    var icon: String
    var colorHex: String
    var frequency: HabitFrequency
    var categoryRaw: String = HabitCategory.health.rawValue
    var createdDate: Date

    var category: HabitCategory {
        get { HabitCategory(rawValue: categoryRaw) ?? .health }
        set { categoryRaw = newValue.rawValue }
    }
    var sortOrder: Int

    @Relationship(deleteRule: .cascade) var entries: [HabitEntry]
    @Relationship(deleteRule: .cascade) var reminders: [HabitReminder]

    init(
        title: String,
        icon: String = "star.fill",
        colorHex: String = "#6C63FF",
        frequency: HabitFrequency = .daily,
        category: HabitCategory = .health,
        sortOrder: Int = 0
    ) {
        self.id = UUID()
        self.title = title
        self.icon = icon
        self.colorHex = colorHex
        self.frequency = frequency
        self.categoryRaw = category.rawValue
        self.createdDate = Date()
        self.sortOrder = sortOrder
        self.entries = []
        self.reminders = []
    }

    var currentStreak: Int {
        let calendar = Calendar.current
        let step = frequency == .weekly ? -7 : -1
        let completedDates = entries
            .filter { $0.isCompleted }
            .map { calendar.startOfDay(for: $0.completedDate) }
            .sorted(by: >)

        guard !completedDates.isEmpty else { return 0 }

        var checkDate = calendar.startOfDay(for: Date())
        if !completedDates.contains(checkDate) {
            guard let prev = calendar.date(byAdding: .day, value: step, to: checkDate),
                  completedDates.contains(prev) else { return 0 }
            checkDate = prev
        }

        var streak = 0
        for date in completedDates {
            if date == checkDate {
                streak += 1
                guard let nextDate = calendar.date(byAdding: .day, value: step, to: checkDate) else { break }
                checkDate = nextDate
            } else if date < checkDate {
                break
            }
        }
        return streak
    }

    var longestStreak: Int {
        let calendar = Calendar.current
        let expectedDiff = frequency == .weekly ? 7 : 1
        let sortedDates = Array(Set(entries
            .filter { $0.isCompleted }
            .map { calendar.startOfDay(for: $0.completedDate) }))
            .sorted()

        guard !sortedDates.isEmpty else { return 0 }

        var longest = 1
        var current = 1
        for i in 1..<sortedDates.count {
            let diff = calendar.dateComponents([.day], from: sortedDates[i - 1], to: sortedDates[i]).day ?? 0
            if diff == expectedDiff {
                current += 1
                longest = max(longest, current)
            } else if diff > expectedDiff {
                current = 1
            }
        }
        return longest
    }

    var completionRate: Double {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let start = calendar.startOfDay(for: createdDate)
        let totalDays = (calendar.dateComponents([.day], from: start, to: today).day ?? 0) + 1
        let denominator: Int
        if frequency == .weekly {
            denominator = max((totalDays + 6) / 7, 1)
        } else {
            denominator = max(totalDays, 1)
        }
        return Double(entries.filter { $0.isCompleted }.count) / Double(denominator)
    }

    var isCompletedToday: Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return entries.contains {
            $0.isCompleted && calendar.startOfDay(for: $0.completedDate) == today
        }
    }

    var totalCompletions: Int {
        entries.filter { $0.isCompleted }.count
    }

    static let ymdFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    var completedDateStrings: Set<String> {
        Set(entries.filter { $0.isCompleted }.map { Habit.ymdFormatter.string(from: $0.completedDate) })
    }
}
