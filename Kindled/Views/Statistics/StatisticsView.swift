import SwiftUI
import SwiftData

struct StatisticsView: View {
    @Query(sort: \Habit.sortOrder) var habits: [Habit]
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @State private var showPaywall = false

    private var totalCompletionsThisMonth: Int {
        let calendar = Calendar.current
        let now = Date()
        guard let start = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) else { return 0 }
        return habits.flatMap { $0.entries }.filter {
            $0.isCompleted && $0.completedDate >= start
        }.count
    }

    private var overallRate: Double {
        guard !habits.isEmpty else { return 0 }
        return habits.map { $0.completionRate }.reduce(0, +) / Double(habits.count)
    }

    private var sortedByStreak: [Habit] {
        habits.sorted { $0.currentStreak > $1.currentStreak }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    summaryCards
                    if !habits.isEmpty {
                        ProLockedView(title: "Overall Charts") {
                            OverallChartsView(habits: habits)
                        }
                        leaderboard
                    } else {
                        emptyState
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var summaryCards: some View {
        HStack(spacing: 12) {
            StatCard(
                value: "\(habits.count)",
                label: "Habits",
                icon: "list.bullet.circle.fill",
                color: .purple
            )
            StatCard(
                value: "\(totalCompletionsThisMonth)",
                label: "This Month",
                icon: "calendar.badge.checkmark",
                color: .blue
            )
            if subscriptionManager.isProUnlocked {
                StatCard(
                    value: "\(Int(overallRate * 100))%",
                    label: "Avg Rate",
                    icon: "chart.pie.fill",
                    color: .green
                )
            } else {
                lockedAvgRateCard
            }
        }
        .padding(.top, 8)
    }

    private var lockedAvgRateCard: some View {
        VStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.green.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: "lock.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.green)
            }
            Text("Pro")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
            Text("Avg Rate")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .onTapGesture { showPaywall = true }
        .sheet(isPresented: $showPaywall) {
            KindledPaywallView()
        }
    }

    private var leaderboard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Streak Leaderboard")
                .font(.headline)
                .padding(.leading, 4)

            VStack(spacing: 10) {
                ForEach(Array(sortedByStreak.enumerated()), id: \.element.id) { index, habit in
                    LeaderboardRow(rank: index + 1, habit: habit)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 52))
                .foregroundStyle(.secondary.opacity(0.5))
            Text("No data yet")
                .font(.title3.bold())
            Text("Start tracking habits to see your stats")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 60)
    }
}

struct LeaderboardRow: View {
    let rank: Int
    let habit: Habit

    private var habitColor: Color {
        Color(hex: habit.colorHex) ?? .purple
    }

    private var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return Color(.systemGray2)
        case 3: return .orange
        default: return .secondary
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            Text("#\(rank)")
                .font(.system(size: rank == 1 ? 18 : 15, weight: .bold, design: .rounded))
                .foregroundStyle(rankColor)
                .frame(width: 32)

            ZStack {
                Circle()
                    .fill(habitColor.opacity(0.15))
                    .frame(width: rank == 1 ? 46 : 40, height: rank == 1 ? 46 : 40)
                Image(systemName: habit.icon)
                    .font(.system(size: rank == 1 ? 21 : 18))
                    .foregroundStyle(habitColor)
            }

            Text(habit.title)
                .font(.body.bold())

            Spacer()

            StreakBadge(streak: habit.currentStreak)
        }
        .padding(rank == 1 ? 16 : 14)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(rank == 1 ? Color.yellow.opacity(0.5) : Color.clear, lineWidth: 1.5)
        )
        .shadow(color: rank == 1 ? Color.yellow.opacity(0.25) : .clear, radius: 8, y: 4)
    }
}
