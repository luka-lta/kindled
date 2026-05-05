import SwiftUI

struct AchievementsView: View {
    @Environment(AchievementManager.self) var manager
    @Environment(\.themeColor) var themeColor

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 2)

    private var unlockedCount: Int { Achievement.all.filter { manager.isUnlocked($0.id) }.count }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                progressHeader
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(Achievement.all) { achievement in
                        AchievementCard(achievement: achievement, manager: manager)
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 12)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Achievements")
        .navigationBarTitleDisplayMode(.large)
    }

    private var progressHeader: some View {
        VStack(spacing: 8) {
            HStack {
                Text("\(unlockedCount) of \(Achievement.all.count) unlocked")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(Int(Double(unlockedCount) / Double(Achievement.all.count) * 100))%")
                    .font(.subheadline.bold())
                    .foregroundStyle(themeColor)
            }
            ProgressView(value: Double(unlockedCount), total: Double(Achievement.all.count))
                .tint(themeColor)
        }
        .padding(.horizontal, 20)
        .padding(.top, 4)
    }
}

private struct AchievementCard: View {
    let achievement: Achievement
    let manager: AchievementManager

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
            if unlocked, let date = manager.unlockDate(for: achievement.id) {
                Text(date.formatted(.dateTime.day().month().year()))
                    .font(.caption2)
                    .foregroundStyle(achievement.color)
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
        .opacity(unlocked ? 1 : 0.5)
    }
}
