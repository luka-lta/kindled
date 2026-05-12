import SwiftUI

struct HabitDetailView: View {
    let habit: Habit
    @State private var showEdit = false
    @State private var showPaywall = false
    @Environment(SubscriptionManager.self) private var subscriptionManager

    private var habitColor: Color {
        Color(hex: habit.colorHex) ?? .purple
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                GeometryReader { geo in
                    let offset = geo.frame(in: .named("detailScroll")).minY
                    parallaxHeaderBanner(scrollOffset: offset)
                }
                .frame(height: 272)

                VStack(spacing: 16) {
                    statsRow
                    HabitChartsView(habit: habit)
                    HeatmapView(habit: habit)
                    CalendarGridView(habit: habit)
                    NotesOverviewView(habit: habit)
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 40)
            }
        }
        .coordinateSpace(name: "detailScroll")
        .background(Color(.systemGroupedBackground))
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showEdit = true
                } label: {
                    Image(systemName: "pencil.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.2), radius: 4)
                }
            }
        }
        .sheet(isPresented: $showEdit) {
            AddEditHabitView(editHabit: habit)
        }
    }

    // MARK: - Header

    private func parallaxHeaderBanner(scrollOffset: CGFloat) -> some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [habitColor, habitColor.opacity(0.55)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Rectangle()
                .fill(.white.opacity(0.04))
                .offset(y: scrollOffset < 0 ? scrollOffset * 0.4 : 0)

            VStack(spacing: 14) {
                iconCircle
                    .shadow(color: .black.opacity(0.15), radius: 10, y: 4)

                VStack(spacing: 6) {
                    Text(habit.title)
                        .font(.title2.bold())
                        .foregroundStyle(.white)

                    HStack(spacing: 8) {
                        frequencyPill
                        if habit.currentStreak > 0 {
                            streakPill
                        }
                    }
                }
            }
            .padding(.bottom, 36)
            .offset(y: scrollOffset > 0 ? -scrollOffset * 0.3 : 0)
        }
        .frame(height: max(272, 272 + scrollOffset))
        .clipShape(.rect(
            topLeadingRadius: 0,
            bottomLeadingRadius: 32,
            bottomTrailingRadius: 32,
            topTrailingRadius: 0
        ))
        .offset(y: scrollOffset > 0 ? -scrollOffset : 0)
    }

    private var iconCircle: some View {
        ZStack {
            Circle()
                .fill(.white.opacity(0.2))
                .frame(width: 90, height: 90)
            Circle()
                .strokeBorder(.white.opacity(0.3), lineWidth: 1.5)
                .frame(width: 90, height: 90)
            Image(systemName: habit.icon)
                .font(.system(size: 42))
                .foregroundStyle(.white)
        }
    }

    private var frequencyPill: some View {
        Text(habit.frequency.rawValue)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.white.opacity(0.9))
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(.white.opacity(0.18), in: Capsule())
    }

    private var streakPill: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .font(.caption.bold())
            Text("\(habit.currentStreak) day streak")
                .font(.caption.bold())
        }
        .foregroundStyle(.white.opacity(0.9))
        .padding(.horizontal, 12)
        .padding(.vertical, 5)
        .background(.white.opacity(0.18), in: Capsule())
    }

    // MARK: - Stats

    private var statsRow: some View {
        HStack(spacing: 10) {
            StatCard(
                value: "\(habit.currentStreak)",
                label: "Streak",
                icon: "flame.fill",
                color: .orange
            )
            StatCard(
                value: "\(habit.longestStreak)",
                label: "Best",
                icon: "trophy.fill",
                color: .yellow
            )
            StatCard(
                value: "\(habit.totalCompletions)",
                label: "Total",
                icon: "checkmark.circle.fill",
                color: habitColor
            )
            if subscriptionManager.isProUnlocked {
                StatCard(
                    value: "\(Int(habit.completionRate * 100))%",
                    label: "Rate",
                    icon: "chart.bar.fill",
                    color: .green
                )
            } else {
                lockedRateCard
            }
        }
    }

    private var lockedRateCard: some View {
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
            Text("Rate")
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
}
