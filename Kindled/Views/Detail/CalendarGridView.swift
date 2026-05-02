import SwiftUI

struct CalendarGridView: View {
    let habit: Habit
    @State private var displayedMonth = Date()
    @State private var selectedEntry: HabitEntry? = nil

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    private var habitColor: Color {
        Color(hex: habit.colorHex) ?? .purple
    }

    private var entriesByDateString: [String: HabitEntry] {
        var dict: [String: HabitEntry] = [:]
        for entry in habit.entries where entry.isCompleted {
            dict[Self.dateFormatter.string(from: entry.completedDate)] = entry
        }
        return dict
    }

    private var daysInMonth: [Date?] {
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: displayedMonth),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth))
        else { return [] }

        let weekday = calendar.component(.weekday, from: firstDay) - 1
        var days: [Date?] = Array(repeating: nil, count: weekday)
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(date)
            }
        }
        return days
    }

    private let weekdayLabels = ["S", "M", "T", "W", "T", "F", "S"]

    var body: some View {
        VStack(spacing: 16) {
            monthNavigator
            weekdayHeader
            daysGrid
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
        .sheet(item: $selectedEntry) { entry in
            NoteEntryView(entry: entry)
        }
    }

    private var monthNavigator: some View {
        HStack {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    displayedMonth = Calendar.current.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                    .padding(8)
                    .background(Color(.tertiarySystemFill), in: Circle())
            }
            .buttonStyle(.plain)

            Spacer()
            Text(displayedMonth.formatted(.dateTime.month(.wide).year()))
                .font(.headline)
            Spacer()

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    displayedMonth = Calendar.current.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .padding(8)
                    .background(Color(.tertiarySystemFill), in: Circle())
            }
            .buttonStyle(.plain)
            .disabled(Calendar.current.isDate(displayedMonth, equalTo: Date(), toGranularity: .month))
            .opacity(Calendar.current.isDate(displayedMonth, equalTo: Date(), toGranularity: .month) ? 0.3 : 1)
        }
    }

    private var weekdayHeader: some View {
        HStack {
            ForEach(Array(weekdayLabels.enumerated()), id: \.offset) { _, label in
                Text(label)
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var daysGrid: some View {
        let entries = entriesByDateString
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 6) {
            ForEach(Array(daysInMonth.enumerated()), id: \.offset) { _, date in
                if let date = date {
                    let key = Self.dateFormatter.string(from: date)
                    let entry = entries[key]
                    DayCell(date: date, isCompleted: entry != nil, hasNote: entry?.note != nil, color: habitColor)
                        .onTapGesture {
                            if let entry {
                                selectedEntry = entry
                            }
                        }
                } else {
                    Color.clear.frame(height: 36)
                }
            }
        }
    }
}

struct DayCell: View {
    let date: Date
    let isCompleted: Bool
    let hasNote: Bool
    let color: Color

    private var isFuture: Bool { date > Date() }
    private var isToday: Bool { Calendar.current.isDateInToday(date) }

    var body: some View {
        ZStack(alignment: .bottom) {
            ZStack {
                Circle()
                    .fill(isCompleted ? color : (isToday ? color.opacity(0.15) : .clear))
                    .frame(width: 34, height: 34)
                if isToday && !isCompleted {
                    Circle()
                        .strokeBorder(color, lineWidth: 1.5)
                        .frame(width: 34, height: 34)
                }
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.system(size: 13, weight: isCompleted ? .bold : .regular))
                    .foregroundStyle(
                        isCompleted ? .white :
                        (isFuture ? Color.secondary.opacity(0.35) : .primary)
                    )
            }

            if hasNote {
                Circle()
                    .fill(isCompleted ? .white.opacity(0.85) : color)
                    .frame(width: 4, height: 4)
                    .offset(y: 2)
            }
        }
        .frame(height: 40)
    }
}
