import SwiftUI
import Combine

struct DailyTimelineView: View {
    let habits: [Habit]
    let onToggle: (Habit) -> Void

    @Environment(\.themeColor) var themeColor
    @State private var now = Date()

    private let clock = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    private static let timeFmt: DateFormatter = {
        let f = DateFormatter()
        f.timeStyle = .short
        f.dateStyle = .none
        return f
    }()

    private func minutes(_ date: Date) -> Int {
        let c = Calendar.current.dateComponents([.hour, .minute], from: date)
        return (c.hour ?? 0) * 60 + (c.minute ?? 0)
    }

    private var nowMinutes: Int { minutes(now) }

    private var scheduled: [Habit] {
        habits
            .filter { $0.scheduledTime != nil }
            .sorted { minutes($0.scheduledTime!) < minutes($1.scheduledTime!) }
    }

    private var unscheduled: [Habit] {
        habits.filter { $0.scheduledTime == nil }
    }

    private enum Item: Identifiable {
        case habit(Habit)
        case nowMarker
        var id: String {
            switch self {
            case .habit(let h): return h.id.uuidString
            case .nowMarker: return "now"
            }
        }
    }

    private var items: [Item] {
        var result: [Item] = []
        var inserted = false
        for habit in scheduled {
            if !inserted && minutes(habit.scheduledTime!) > nowMinutes {
                result.append(.nowMarker)
                inserted = true
            }
            result.append(.habit(habit))
        }
        if !inserted { result.append(.nowMarker) }
        return result
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if habits.isEmpty {
                    emptyState
                } else {
                    ForEach(items) { item in
                        switch item {
                        case .habit(let h): row(h, timeLabel: Self.timeFmt.string(from: h.scheduledTime!))
                        case .nowMarker: nowLine
                        }
                    }
                    if !unscheduled.isEmpty {
                        unscheduledHeader
                        ForEach(unscheduled) { h in
                            row(h, timeLabel: "—")
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(Color(.systemGroupedBackground))
        .onReceive(clock) { now = $0 }
    }

    private var nowLine: some View {
        HStack(spacing: 10) {
            Text(LocalizedStringKey("Now"))
                .font(.caption.bold())
                .foregroundStyle(themeColor)
                .frame(width: 54, alignment: .trailing)
            Rectangle()
                .fill(themeColor)
                .frame(height: 2)
        }
        .padding(.vertical, 10)
    }

    private var unscheduledHeader: some View {
        Text(LocalizedStringKey("Unscheduled"))
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.secondary)
            .padding(.top, 20)
            .padding(.bottom, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func row(_ habit: Habit, timeLabel: String) -> some View {
        HStack(spacing: 10) {
            Text(verbatim: timeLabel)
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
                .frame(width: 54, alignment: .trailing)

            Circle()
                .fill(habit.isCompletedToday
                    ? (Color(hex: habit.colorHex) ?? themeColor)
                    : Color(.tertiaryLabel))
                .frame(width: 10, height: 10)

            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill((Color(hex: habit.colorHex) ?? themeColor)
                        .opacity(habit.isCompletedToday ? 1.0 : 0.15))
                    .frame(width: 32, height: 32)
                Image(systemName: habit.icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(habit.isCompletedToday ? .white : (Color(hex: habit.colorHex) ?? themeColor))
            }

            Text(habit.title)
                .font(.subheadline)
                .strikethrough(habit.isCompletedToday, color: .secondary)
                .foregroundStyle(habit.isCompletedToday ? .secondary : .primary)
                .lineLimit(1)

            Spacer()

            Button {
                onToggle(habit)
            } label: {
                Image(systemName: habit.isCompletedToday ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(habit.isCompletedToday ? (Color(hex: habit.colorHex) ?? themeColor) : .secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 6)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock")
                .font(.system(size: 48))
                .foregroundStyle(.secondary.opacity(0.5))
            Text(LocalizedStringKey("No habits scheduled"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
}
