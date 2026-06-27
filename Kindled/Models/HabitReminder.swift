import SwiftData
import Foundation

@Model
final class HabitReminder {
    var id: UUID
    var hour: Int
    var minute: Int
    var isEnabled: Bool
    var notificationID: String
    var weekday: Int = 2 // 1=Sun, 2=Mon … 7=Sat; only used for weekly habits

    init(hour: Int, minute: Int, weekday: Int = 2) {
        self.id = UUID()
        self.hour = hour
        self.minute = minute
        self.isEnabled = true
        self.notificationID = UUID().uuidString
        self.weekday = weekday
    }
}
