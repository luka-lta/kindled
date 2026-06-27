import WidgetKit
import SwiftUI

// Mirrors WidgetDataBridge.WidgetHabitData — must stay in sync
struct WidgetHabitData: Codable {
    let id: String
    let title: String
    let icon: String
    let colorHex: String
    let isCompleted: Bool
    let streak: Int
}

private func readHabits() -> [WidgetHabitData] {
    guard let defaults = UserDefaults(suiteName: "group.dev.luka-lta.kindled"),
          let data = defaults.data(forKey: "widgetHabits"),
          let decoded = try? JSONDecoder().decode([WidgetHabitData].self, from: data)
    else { return [] }
    return decoded
}

// MARK: - Timeline

struct KindledEntry: TimelineEntry {
    let date: Date
    let habits: [WidgetHabitData]
}

struct KindledProvider: TimelineProvider {
    func placeholder(in context: Context) -> KindledEntry {
        KindledEntry(date: Date(), habits: [
            WidgetHabitData(id: "1", title: "Morning Run", icon: "figure.run", colorHex: "#6C63FF", isCompleted: false, streak: 7),
            WidgetHabitData(id: "2", title: "Read", icon: "book.fill", colorHex: "#FF6B6B", isCompleted: true, streak: 3),
            WidgetHabitData(id: "3", title: "Meditate", icon: "brain.fill", colorHex: "#4ECDC4", isCompleted: false, streak: 0),
        ])
    }

    func getSnapshot(in context: Context, completion: @escaping (KindledEntry) -> Void) {
        completion(KindledEntry(date: Date(), habits: readHabits()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<KindledEntry>) -> Void) {
        let entry = KindledEntry(date: Date(), habits: readHabits())
        let midnight = Calendar.current.startOfDay(for: Date().addingTimeInterval(86400))
        completion(Timeline(entries: [entry], policy: .after(midnight)))
    }
}

// MARK: - Views

struct KindledWidgetEntryView: View {
    var entry: KindledEntry
    @Environment(\.widgetFamily) var family

    private var completed: Int { entry.habits.filter { $0.isCompleted }.count }
    private var total: Int { entry.habits.count }
    private var progress: Double { total == 0 ? 0 : Double(completed) / Double(total) }

    var body: some View {
        switch family {
        case .systemSmall:  smallView
        default:            mediumView
        }
    }

    private var smallView: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(Color.purple.opacity(0.2), lineWidth: 8)
                    .frame(width: 60, height: 60)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.purple, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
                Text("\(completed)/\(total)")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
            }
            Text("Today")
                .font(.caption2.bold())
                .foregroundStyle(.secondary)
        }
        .containerBackground(for: .widget) { Color(.systemBackground) }
    }

    private var mediumView: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.orange)
                    .font(.caption.bold())
                Text("\(completed) of \(total) done")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                Spacer()
                Text(Date(), style: .date)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Divider()

            ForEach(Array(entry.habits.prefix(4)), id: \.id) { habit in
                HStack(spacing: 8) {
                    Image(systemName: habit.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 14))
                        .foregroundStyle(habit.isCompleted ? .green : .secondary)
                    Text(habit.title)
                        .font(.subheadline)
                        .strikethrough(habit.isCompleted, color: .secondary)
                        .foregroundStyle(habit.isCompleted ? .secondary : .primary)
                        .lineLimit(1)
                    Spacer()
                    if habit.streak > 1 {
                        Label("\(habit.streak)", systemImage: "flame.fill")
                            .font(.caption2.bold())
                            .foregroundStyle(.orange)
                    }
                }
            }

            if entry.habits.count > 4 {
                Text("+\(entry.habits.count - 4) more")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(12)
        .containerBackground(for: .widget) { Color(.systemBackground) }
    }
}

// MARK: - Widget

struct KindledWidget: Widget {
    let kind = "KindledWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: KindledProvider()) { entry in
            KindledWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Kindled Habits")
        .description("Today's habits at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
