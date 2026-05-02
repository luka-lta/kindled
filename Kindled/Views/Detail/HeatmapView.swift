import SwiftUI

struct HeatmapView: View {
    let habit: Habit
    @State private var hasScrolled = false

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    private var habitColor: Color {
        Color(hex: habit.colorHex) ?? .purple
    }

    private var completedDateStrings: Set<String> {
        Set(habit.entries.filter { $0.isCompleted }.map { Self.dateFormatter.string(from: $0.completedDate) })
    }

    // 52 columns × 7 rows, leftmost = oldest week, rightmost = current week
    private var weekColumns: [[Date?]] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let start = calendar.date(byAdding: .day, value: -363, to: today) else { return [] }

        let startWeekday = calendar.component(.weekday, from: start) - 1  // 0 = Sunday
        var allDays: [Date?] = Array(repeating: nil, count: startWeekday)

        var current = start
        while current <= today {
            allDays.append(current)
            current = calendar.date(byAdding: .day, value: 1, to: current) ?? current
        }
        while allDays.count % 7 != 0 { allDays.append(nil) }

        return stride(from: 0, to: allDays.count, by: 7).map {
            Array(allDays[$0..<min($0 + 7, allDays.count)])
        }
    }

    private func isCompleted(_ date: Date) -> Bool {
        completedDateStrings.contains(Self.dateFormatter.string(from: date))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Year Overview")
                    .font(.headline)
                Spacer()
                Text("\(habit.totalCompletions) completions")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 3) {
                        ForEach(Array(weekColumns.enumerated()), id: \.offset) { index, week in
                            VStack(spacing: 3) {
                                ForEach(Array(week.enumerated()), id: \.offset) { _, day in
                                    if let day = day {
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(isCompleted(day) ? habitColor : habitColor.opacity(0.1))
                                            .frame(width: 13, height: 13)
                                    } else {
                                        Color.clear.frame(width: 13, height: 13)
                                    }
                                }
                            }
                            .id(index)
                        }
                    }
                    .padding(.horizontal, 2)
                }
                .onAppear {
                    guard !hasScrolled else { return }
                    hasScrolled = true
                    proxy.scrollTo(weekColumns.count - 1, anchor: .trailing)
                }
            }

            HStack(spacing: 6) {
                Text("Less")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                ForEach([0.1, 0.4, 0.7, 1.0] as [Double], id: \.self) { opacity in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(habitColor.opacity(opacity))
                        .frame(width: 13, height: 13)
                }
                Text("More")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
}
