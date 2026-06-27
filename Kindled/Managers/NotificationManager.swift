import UserNotifications
import Foundation

final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    private let streakProtectionID = "com.kindled.streakProtection"

    func requestPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    func scheduleReminder(for habit: Habit, reminder: HabitReminder) {
        guard reminder.isEnabled else { return }
        let content = UNMutableNotificationContent()
        content.title = habit.title
        content.body = NSLocalizedString("Keep your streak alive! 🔥", comment: "Habit reminder body")
        content.sound = .default

        var components = DateComponents()
        components.hour = reminder.hour
        components.minute = reminder.minute
        if habit.frequency == .weekly {
            components.weekday = reminder.weekday
        }

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(
            identifier: reminder.notificationID,
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("[NotificationManager] Failed to schedule: \(error)")
            }
        }
    }

    func scheduleStreakProtectionReminder(habits: [Habit]) {
        let enabled = UserDefaults.standard.object(forKey: StorageKeys.streakProtectionEnabled) as? Bool ?? true
        guard enabled else {
            removeStreakProtectionReminder()
            return
        }

        let pendingHabits = habits.filter { !$0.isCompletedToday && $0.frequency == .daily }

        guard !pendingHabits.isEmpty else {
            removeStreakProtectionReminder()
            return
        }

        let topStreak = pendingHabits.map { $0.currentStreak }.max() ?? 0
        let body: String
        if topStreak >= 2 {
            body = String(
                format: NSLocalizedString("streak_protection_body_active", comment: ""),
                topStreak
            )
        } else {
            body = NSLocalizedString("streak_protection_body_start", comment: "")
        }

        let hour = UserDefaults.standard.object(forKey: StorageKeys.streakProtectionHour) as? Int ?? 20
        let minute = UserDefaults.standard.object(forKey: StorageKeys.streakProtectionMinute) as? Int ?? 30

        let fireDate = Calendar.current.date(
            bySettingHour: hour, minute: minute, second: 0, of: Date()
        ) ?? Date()

        if fireDate <= Date() {
            removeStreakProtectionReminder()
            return
        }

        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("Don't break your streak!", comment: "Streak protection title")
        content.body = body
        content.sound = .default

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: streakProtectionID,
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("[NotificationManager] Streak protection schedule error: \(error)")
            }
        }
    }

    func removeStreakProtectionReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [streakProtectionID]
        )
    }

    func removeReminder(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }

    func removeAllReminders(for habit: Habit) {
        let ids = habit.reminders.map { $0.notificationID }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }
}
