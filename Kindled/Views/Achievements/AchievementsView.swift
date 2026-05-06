import SwiftUI
import SwiftData

struct AchievementsView: View {
    @Environment(AchievementManager.self) var manager
    @Environment(\.themeColor) var themeColor
    @Query var habits: [Habit]

    @State private var selectedAchievement: Achievement?

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 2)
    private var unlockedCount: Int { Achievement.all.filter { manager.isUnlocked($0.id) }.count }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                progressHeader
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(Achievement.all) { achievement in
                        AchievementCard(
                            achievement: achievement,
                            manager: manager,
                            progress: manager.progress(for: achievement.id, habits: habits),
                            progressText: manager.progressText(for: achievement.id, habits: habits)
                        )
                        .onTapGesture { selectedAchievement = achievement }
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 12)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Achievements")
        .navigationBarTitleDisplayMode(.large)
        .sheet(item: $selectedAchievement) { achievement in
            AchievementDetailSheet(
                achievement: achievement,
                manager: manager,
                progress: manager.progress(for: achievement.id, habits: habits),
                progressText: manager.progressText(for: achievement.id, habits: habits)
            )
        }
    }

    private var progressHeader: some View {
        VStack(spacing: 8) {
            HStack {
                Text("\(unlockedCount) of \(Achievement.all.count) unlocked")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(Achievement.all.isEmpty ? "0%" : "\(Int(Double(unlockedCount) / Double(Achievement.all.count) * 100))%")
                    .font(.subheadline.bold())
                    .foregroundStyle(themeColor)
            }
            ProgressView(value: Double(unlockedCount), total: max(1, Double(Achievement.all.count)))
                .tint(themeColor)
        }
        .padding(.horizontal, 20)
        .padding(.top, 4)
    }
}

private struct AchievementCard: View {
    let achievement: Achievement
    let manager: AchievementManager
    let progress: Double
    let progressText: String

    private var unlocked: Bool { manager.isUnlocked(achievement.id) }

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(unlocked ? achievement.color.gradient : Color(.tertiarySystemFill).gradient)
                    .frame(width: 56, height: 56)
                Image(systemName: achievement.icon)
                    .font(.system(size: 24))
                    .foregroundStyle(unlocked ? .white : .secondary)
            }
            VStack(spacing: 3) {
                Text(LocalizedStringKey(achievement.title))
                    .font(.caption.bold())
                    .multilineTextAlignment(.center)
                    .foregroundStyle(unlocked ? .primary : .secondary)
                Text(LocalizedStringKey(achievement.description))
                    .font(.caption2)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            if unlocked {
                if let date = manager.unlockDate(for: achievement.id) {
                    Text(date.formatted(.dateTime.day().month().year()))
                        .font(.caption2)
                        .foregroundStyle(achievement.color)
                }
            } else {
                VStack(spacing: 3) {
                    ProgressView(value: progress)
                        .tint(achievement.color)
                    Text(progressText)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(unlocked ? achievement.color.opacity(0.4) : Color.clear, lineWidth: 1.5)
        )
        .grayscale(unlocked ? 0 : 1)
        .opacity(unlocked ? 1 : 0.6)
    }
}

private struct AchievementDetailSheet: View {
    let achievement: Achievement
    let manager: AchievementManager
    let progress: Double
    let progressText: String

    @Environment(\.dismiss) private var dismiss

    private var unlocked: Bool { manager.isUnlocked(achievement.id) }

    var body: some View {
        VStack(spacing: 28) {
            ZStack {
                Circle()
                    .fill(unlocked ? achievement.color.gradient : Color(.tertiarySystemFill).gradient)
                    .frame(width: 100, height: 100)
                    .shadow(color: unlocked ? achievement.color.opacity(0.4) : .clear, radius: 16, y: 6)
                Image(systemName: achievement.icon)
                    .font(.system(size: 44))
                    .foregroundStyle(unlocked ? .white : .secondary)
            }
            .grayscale(unlocked ? 0 : 1)
            .padding(.top, 8)

            VStack(spacing: 8) {
                Text(LocalizedStringKey(achievement.title))
                    .font(.title2.bold())
                Text(LocalizedStringKey(achievement.description))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            if unlocked {
                if let date = manager.unlockDate(for: achievement.id) {
                    Label("Unlocked \(date.formatted(.dateTime.day().month().year()))", systemImage: "checkmark.circle.fill")
                        .font(.subheadline.bold())
                        .foregroundStyle(.green)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.green.opacity(0.12), in: Capsule())
                }
            } else {
                VStack(spacing: 10) {
                    HStack {
                        Text("Progress")
                            .font(.subheadline.bold())
                        Spacer()
                        Text(progressText)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    ProgressView(value: progress)
                        .tint(achievement.color)
                        .scaleEffect(x: 1, y: 1.5)
                }
                .padding(.horizontal, 32)
            }

            Spacer()
        }
        .padding(.horizontal, 24)
        .presentationDetents([.fraction(0.45)])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(28)
    }
}
