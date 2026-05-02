import SwiftData
import Foundation

@Model
final class HabitReminder {
    var id: UUID
    var hour: Int
    var minute: Int
    var isEnabled: Bool
    var notificationID: String

    init(hour: Int, minute: Int) {
        self.id = UUID()
        self.hour = hour
        self.minute = minute
        self.isEnabled = true
        self.notificationID = UUID().uuidString
    }
}
