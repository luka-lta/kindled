import SwiftData
import Foundation

@Model
final class HabitEntry {
    var id: UUID
    var completedDate: Date
    var isCompleted: Bool
    var note: String?

    init(completedDate: Date = Date(), isCompleted: Bool = true, note: String? = nil) {
        self.id = UUID()
        self.completedDate = completedDate
        self.isCompleted = isCompleted
        self.note = note
    }
}
