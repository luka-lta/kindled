import Foundation

struct WidgetHabitData: Codable {
    let id: String
    let title: String
    let icon: String
    let colorHex: String
    let isCompleted: Bool
    let streak: Int
}

enum WidgetDataBridge {
    static let appGroupID = "group.dev.luka-lta.kindled"
    static let habitsKey = "widgetHabits"

    static func write(habits: [Habit]) {
        let data = habits.filter { !$0.isPaused }.map {
            WidgetHabitData(
                id: $0.id.uuidString,
                title: $0.title,
                icon: $0.icon,
                colorHex: $0.colorHex,
                isCompleted: $0.isCompletedToday,
                streak: $0.currentStreak
            )
        }
        guard let encoded = try? JSONEncoder().encode(data),
              let defaults = UserDefaults(suiteName: appGroupID) else { return }
        defaults.set(encoded, forKey: habitsKey)
    }
}
