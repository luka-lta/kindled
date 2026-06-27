import SwiftUI

struct HabitCard: View {
    let habit: Habit
    let onToggle: () -> Void

    var body: some View {
        let isCompleted = habit.isCompletedToday
        let isPaused = habit.isPaused
        return HStack(spacing: 14) {
            iconView(isCompleted: isCompleted, isPaused: isPaused)
            infoView(isPaused: isPaused)
            Spacer()
            if isPaused {
                pausedBadge
            } else {
                completionButton(isCompleted: isCompleted)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background {
            RoundedRectangle(cornerRadius: 18)
                .fill(.regularMaterial)
            RoundedRectangle(cornerRadius: 18)
                .fill(isPaused ? Color.secondary.opacity(0.06) : habit.displayColor.opacity(isCompleted ? 0.07 : 0))
                .animation(.easeInOut(duration: 0.25), value: isCompleted)
        }
        .overlay(alignment: .leading) {
            (isPaused ? Color.secondary : habit.displayColor)
                .frame(width: 4)
                .clipShape(.rect(
                    topLeadingRadius: 18,
                    bottomLeadingRadius: 18,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 0
                ))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(habit.displayColor.opacity(isCompleted && !isPaused ? 0.3 : 0), lineWidth: 1.5)
        }
        .opacity(isPaused ? 0.6 : 1.0)
        .animation(.easeInOut(duration: 0.25), value: isCompleted)
        .animation(.easeInOut(duration: 0.2), value: isPaused)
    }

    private func iconView(isCompleted: Bool, isPaused: Bool) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill((isPaused ? Color.secondary : habit.displayColor).opacity(isCompleted ? 0.22 : 0.12))
                .frame(width: 52, height: 52)
            Image(systemName: isPaused ? "pause.fill" : habit.icon)
                .font(.system(size: 24))
                .foregroundStyle(isPaused ? .secondary : habit.displayColor)
        }
        .animation(.easeInOut(duration: 0.2), value: isCompleted)
        .animation(.easeInOut(duration: 0.2), value: isPaused)
    }

    private func infoView(isPaused: Bool) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(habit.title)
                .font(.body.bold())
                .foregroundStyle(.primary)
            HStack(spacing: 6) {
                if isPaused {
                    Label("Paused", systemImage: "pause.circle.fill")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                } else {
                    if habit.currentStreak > 0 {
                        Label("\(habit.currentStreak)", systemImage: "flame.fill")
                            .font(.caption.bold())
                            .foregroundStyle(.orange)
                        Text("·")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    Text(LocalizedStringKey(habit.frequency.rawValue))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("·")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    Label(LocalizedStringKey(habit.category.rawValue), systemImage: habit.category.icon)
                        .font(.caption)
                        .foregroundStyle(habit.category.color.opacity(0.8))
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }
            .lineLimit(1)
        }
    }

    private var pausedBadge: some View {
        ZStack {
            Circle()
                .fill(Color.secondary.opacity(0.12))
                .frame(width: 50, height: 50)
            Image(systemName: "pause.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.secondary)
        }
    }

    private func completionButton(isCompleted: Bool) -> some View {
        ZStack {
            ProgressRing(progress: isCompleted ? 1.0 : 0.0, color: habit.displayColor, lineWidth: 3)
                .frame(width: 50, height: 50)

            Button(action: onToggle) {
                ZStack {
                    Circle()
                        .fill(isCompleted ? habit.displayColor : habit.displayColor.opacity(0.12))
                        .frame(width: 36, height: 36)
                    Image(systemName: isCompleted ? "checkmark" : "plus")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(isCompleted ? .white : habit.displayColor)
                }
            }
            .buttonStyle(ScaleButtonStyle())
        }
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.88 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.55), value: configuration.isPressed)
    }
}
