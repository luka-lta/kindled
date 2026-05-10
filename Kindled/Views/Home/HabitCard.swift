import SwiftUI

struct HabitCard: View {
    let habit: Habit
    let onToggle: () -> Void

    private var habitColor: Color {
        Color(hex: habit.colorHex) ?? .purple
    }

    var body: some View {
        HStack(spacing: 14) {
            iconView
            infoView
            Spacer()
            completionButton
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background {
            RoundedRectangle(cornerRadius: 18)
                .fill(.regularMaterial)
            RoundedRectangle(cornerRadius: 18)
                .fill(habitColor.opacity(habit.isCompletedToday ? 0.07 : 0))
                .animation(.easeInOut(duration: 0.25), value: habit.isCompletedToday)
        }
        .overlay(alignment: .leading) {
            habitColor
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
                .strokeBorder(habitColor.opacity(habit.isCompletedToday ? 0.3 : 0), lineWidth: 1.5)
        }
        .animation(.easeInOut(duration: 0.25), value: habit.isCompletedToday)
    }

    private var iconView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(habitColor.opacity(habit.isCompletedToday ? 0.22 : 0.12))
                .frame(width: 52, height: 52)
            Image(systemName: habit.icon)
                .font(.system(size: 24))
                .foregroundStyle(habitColor)
        }
        .animation(.easeInOut(duration: 0.2), value: habit.isCompletedToday)
    }

    private var infoView: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(habit.title)
                .font(.body.bold())
                .foregroundStyle(.primary)
            HStack(spacing: 6) {
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
            .lineLimit(1)
        }
    }

    private var completionButton: some View {
        ZStack {
            ProgressRing(progress: habit.isCompletedToday ? 1.0 : 0.0, color: habitColor, lineWidth: 3)
                .frame(width: 50, height: 50)

            Button(action: onToggle) {
                ZStack {
                    Circle()
                        .fill(habit.isCompletedToday ? habitColor : habitColor.opacity(0.12))
                        .frame(width: 36, height: 36)
                    Image(systemName: habit.isCompletedToday ? "checkmark" : "plus")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(habit.isCompletedToday ? .white : habitColor)
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
