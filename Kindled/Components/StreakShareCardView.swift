import SwiftUI

struct StreakShareCardView: View {
    let habit: Habit
    let themeColor: Color

    private var habitColor: Color {
        Color(hex: habit.colorHex) ?? themeColor
    }

    private var streakText: String {
        String(format: NSLocalizedString("%lld day streak", comment: ""), habit.currentStreak)
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [habitColor, habitColor.opacity(0.55)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            GeometryReader { geo in
                Circle()
                    .fill(.white.opacity(0.07))
                    .frame(width: geo.size.width * 0.9)
                    .offset(x: geo.size.width * 0.35, y: -geo.size.height * 0.15)
                Circle()
                    .fill(.white.opacity(0.05))
                    .frame(width: geo.size.width * 0.7)
                    .offset(x: -geo.size.width * 0.3, y: geo.size.height * 0.6)
            }

            VStack(spacing: 0) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(.white.opacity(0.15))
                        .frame(width: 200, height: 200)
                    Circle()
                        .strokeBorder(.white.opacity(0.25), lineWidth: 3)
                        .frame(width: 200, height: 200)
                    Image(systemName: habit.icon)
                        .font(.system(size: 88))
                        .foregroundStyle(.white)
                }

                Spacer().frame(height: 64)

                Text("\(habit.currentStreak)")
                    .font(.system(size: 160, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.4)
                    .padding(.horizontal, 40)

                Text(verbatim: streakText)
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.85))

                Spacer().frame(height: 40)

                Text(habit.title)
                    .font(.system(size: 42, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 60)
                    .lineLimit(2)
                    .minimumScaleFactor(0.6)

                Spacer()

                HStack(spacing: 10) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 20))
                    Text("Kindled")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                }
                .foregroundStyle(.white.opacity(0.5))

                Spacer().frame(height: 100)
            }
        }
        .frame(width: 1080, height: 1920)
    }
}
