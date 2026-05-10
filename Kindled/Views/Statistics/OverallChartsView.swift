import SwiftUI
import Charts

struct OverallChartsView: View {
    let habits: [Habit]

    // MARK: - Data types

    private struct DailyCount: Identifiable {
        let id = UUID()
        let date: Date
        let count: Int
    }

    private struct WeekPoint: Identifiable {
        let id = UUID()
        let weekStart: Date
        let rate: Double
    }

    // MARK: - Computed data

    private func completedCount(on date: Date) -> Int {
        let key = Habit.ymdFormatter.string(from: date)
        return habits.filter { habit in
            habit.completedDateStrings.contains(key)
        }.count
    }

    private var last14Days: [DailyCount] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<14).reversed().compactMap { offset -> DailyCount? in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            return DailyCount(date: date, count: completedCount(on: date))
        }
    }

    private var weeklyRates: [WeekPoint] {
        guard !habits.isEmpty else { return [] }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<12).reversed().compactMap { offset -> WeekPoint? in
            guard let weekStart = calendar.date(byAdding: .weekOfYear, value: -offset, to: today) else { return nil }
            let days = (0..<7).compactMap { d -> Date? in
                guard let day = calendar.date(byAdding: .day, value: d, to: weekStart),
                      day <= today else { return nil }
                return day
            }
            guard !days.isEmpty else { return nil }
            let avgRate = days.map { Double(completedCount(on: $0)) / Double(habits.count) }.reduce(0, +) / Double(days.count)
            return WeekPoint(weekStart: weekStart, rate: avgRate)
        }
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 16) {
            dailyCard
            trendCard
        }
    }

    // MARK: - Daily completions card

    private var dailyCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Daily Completions")
                        .font(.headline)
                    Text("Last 14 days · \(habits.count) habits")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                let todayCount = last14Days.last?.count ?? 0
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(todayCount)")
                        .font(.title3.bold())
                        .foregroundStyle(.indigo)
                    Text("today")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Chart {
                ForEach(last14Days) { day in
                    BarMark(
                        x: .value("Day", day.date, unit: .day),
                        y: .value("Done", day.count),
                        width: .ratio(0.6)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.indigo, Color.purple.opacity(0.6)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(4)
                }

                if habits.count > 0 {
                    RuleMark(y: .value("Max", habits.count))
                        .foregroundStyle(Color.secondary.opacity(0.25))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4]))
                }
            }
            .chartYScale(domain: 0...(max(habits.count, 1)))
            .chartYAxis {
                AxisMarks(values: .automatic(desiredCount: 3)) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                        .foregroundStyle(Color.secondary.opacity(0.2))
                    AxisValueLabel {
                        if let v = value.as(Int.self) {
                            Text("\(v)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
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
            .frame(height: 110)
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Weekly trend card

    private var trendCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Completion Trend")
                        .font(.headline)
                    Text("Average across all habits · 12 weeks")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                let avg = weeklyRates.isEmpty ? 0.0 : weeklyRates.map { $0.rate }.reduce(0, +) / Double(weeklyRates.count)
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(Int(avg * 100))%")
                        .font(.title3.bold())
                        .foregroundStyle(.green)
                    Text("avg")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Chart(weeklyRates) { week in
                AreaMark(
                    x: .value("Week", week.weekStart, unit: .weekOfYear),
                    y: .value("Rate", week.rate)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.green.opacity(0.35), Color.green.opacity(0.04)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)

                LineMark(
                    x: .value("Week", week.weekStart, unit: .weekOfYear),
                    y: .value("Rate", week.rate)
                )
                .foregroundStyle(Color.green)
                .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round))
                .interpolationMethod(.catmullRom)

                PointMark(
                    x: .value("Week", week.weekStart, unit: .weekOfYear),
                    y: .value("Rate", week.rate)
                )
                .foregroundStyle(Color.green)
                .symbolSize(28)
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
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
}
