import SwiftUI
import Charts

struct HabitChartsView: View {
    let habit: Habit

    private var habitColor: Color {
        Color(hex: habit.colorHex) ?? .purple
    }

    private func isCompleted(_ date: Date) -> Bool {
        habit.completedDateStrings.contains(Habit.ymdFormatter.string(from: date))
    }

    // MARK: - Data

    private struct DayBar: Identifiable {
        let id = UUID()
        let date: Date
        let label: String
        let isCompleted: Bool
        let isFuture: Bool
        let isToday: Bool
    }

    private struct WeekPoint: Identifiable {
        let id = UUID()
        let weekStart: Date
        let rate: Double
    }

    private var last14Days: [DayBar] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<14).reversed().compactMap { offset -> DayBar? in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            let label = date.formatted(.dateTime.weekday(.abbreviated))
            return DayBar(
                date: date,
                label: label,
                isCompleted: isCompleted(date),
                isFuture: false,
                isToday: calendar.isDateInToday(date)
            )
        }
    }

    private var weeklyRates: [WeekPoint] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<12).reversed().compactMap { offset -> WeekPoint? in
            guard let weekStart = calendar.date(byAdding: .weekOfYear, value: -offset, to: today) else { return nil }
            let daysInWindow = (0..<7).compactMap { d -> Date? in
                guard let day = calendar.date(byAdding: .day, value: d, to: weekStart),
                      day <= today else { return nil }
                return day
            }
            guard !daysInWindow.isEmpty else { return nil }
            let completed = daysInWindow.filter { isCompleted($0) }.count
            return WeekPoint(weekStart: weekStart, rate: Double(completed) / Double(daysInWindow.count))
        }
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 16) {
            last14DaysCard
            ProLockedView(title: "12-Week Trend") {
                weeklyTrendCard
            }
        }
    }

    // MARK: - Last 14 Days

    private var last14DaysCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Last 14 Days")
                    .font(.headline)
                Spacer()
                let doneCount = last14Days.filter { $0.isCompleted }.count
                Text("\(doneCount) / 14 completed")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Chart(last14Days) { day in
                BarMark(
                    x: .value("Day", day.date, unit: .day),
                    y: .value("Done", day.isCompleted ? 1 : 0),
                    width: .ratio(0.6)
                )
                .foregroundStyle(
                    day.isCompleted
                        ? habitColor.gradient
                        : Color.secondary.opacity(0.15).gradient
                )
                .cornerRadius(4)
            }
            .chartYAxis(.hidden)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 2)) { value in
                    if let date = value.as(Date.self) {
                        AxisValueLabel {
                            Text(date.formatted(.dateTime.weekday(.narrow)))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .chartYScale(domain: 0...1)
            .frame(height: 90)
            .animation(.easeInOut(duration: 0.4), value: last14Days.map { $0.isCompleted })
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Weekly Trend

    private var weeklyTrendCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("12-Week Trend")
                    .font(.headline)
                Spacer()
                let avg = weeklyRates.isEmpty ? 0 : weeklyRates.map { $0.rate }.reduce(0, +) / Double(weeklyRates.count)
                Text("Avg \(Int(avg * 100))%")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Chart(weeklyRates) { week in
                AreaMark(
                    x: .value("Week", week.weekStart, unit: .weekOfYear),
                    y: .value("Rate", week.rate)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [habitColor.opacity(0.35), habitColor.opacity(0.05)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)

                LineMark(
                    x: .value("Week", week.weekStart, unit: .weekOfYear),
                    y: .value("Rate", week.rate)
                )
                .foregroundStyle(habitColor)
                .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                .interpolationMethod(.catmullRom)

                PointMark(
                    x: .value("Week", week.weekStart, unit: .weekOfYear),
                    y: .value("Rate", week.rate)
                )
                .foregroundStyle(habitColor)
                .symbolSize(30)
            }
            .chartYScale(domain: 0...1)
            .chartYAxis {
                AxisMarks(values: [0, 0.5, 1.0]) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                        .foregroundStyle(Color.secondary.opacity(0.25))
                    AxisValueLabel {
                        if let v = value.as(Double.self) {
                            Text("\(Int(v * 100))%")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .weekOfYear, count: 3)) { value in
                    if let date = value.as(Date.self) {
                        AxisValueLabel {
                            Text(date.formatted(.dateTime.month(.abbreviated).day()))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .frame(height: 140)
            .animation(.easeInOut(duration: 0.5), value: weeklyRates.map { $0.rate })
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
}
