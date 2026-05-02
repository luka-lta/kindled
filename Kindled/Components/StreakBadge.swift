import SwiftUI

struct StreakBadge: View {
    var streak: Int

    var body: some View {
        HStack(spacing: 2) {
            Text("🔥")
                .font(.caption)
            Text("\(streak)")
                .font(.caption.bold())
                .foregroundStyle(.orange)
        }
    }
}
