import SwiftUI

struct ThemePickerView: View {
    @AppStorage(StorageKeys.appTheme) private var themeRaw: String = "Purple"

    private var selectedTheme: AppTheme {
        AppTheme(rawValue: themeRaw) ?? .purple
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                previewCard
                colorGrid
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Color Theme")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Preview

    private var previewCard: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottom) {
                LinearGradient(
                    colors: [selectedTheme.color, selectedTheme.color.opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 160)

                VStack(spacing: 10) {
                    HStack(spacing: 12) {
                        previewHabitRow(icon: "figure.run",      label: "Morning Run",   done: true)
                        previewHabitRow(icon: "book.fill",       label: "Read 20 min",   done: true)
                    }
                    HStack(spacing: 12) {
                        previewHabitRow(icon: "drop.fill",       label: "Drink Water",   done: false)
                        previewHabitRow(icon: "moon.stars.fill", label: "Sleep 8h",      done: false)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }

            HStack(spacing: 16) {
                previewStatPill(value: "12", label: "Streak", icon: "flame.fill")
                Divider().frame(height: 28)
                previewStatPill(value: "87%", label: "Rate", icon: "chart.bar.fill")
                Divider().frame(height: 28)
                previewStatPill(value: "248", label: "Total", icon: "checkmark.circle.fill")
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 20)
            .background(.regularMaterial)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: selectedTheme.color.opacity(0.25), radius: 16, y: 6)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: themeRaw)
    }

    private func previewHabitRow(icon: String, label: String, done: Bool) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption.bold())
                .foregroundStyle(.white.opacity(0.9))
            Text(verbatim: label)
                .font(.caption.weight(.medium))
                .foregroundStyle(.white.opacity(0.9))
            Spacer()
            Image(systemName: done ? "checkmark.circle.fill" : "circle")
                .font(.caption.bold())
                .foregroundStyle(.white.opacity(done ? 1.0 : 0.4))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(.white.opacity(0.15), in: RoundedRectangle(cornerRadius: 10))
        .frame(maxWidth: .infinity)
    }

    private func previewStatPill(value: String, label: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption.bold())
                .foregroundStyle(selectedTheme.color)
            VStack(alignment: .leading, spacing: 0) {
                Text(verbatim: value)
                    .font(.caption.bold())
                Text(verbatim: label)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Color Grid

    private var colorGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 20) {
            ForEach(AppTheme.allCases, id: \.rawValue) { theme in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        themeRaw = theme.rawValue
                    }
                } label: {
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(theme.color)
                                .frame(width: 56, height: 56)
                                .shadow(
                                    color: theme.color.opacity(themeRaw == theme.rawValue ? 0.5 : 0),
                                    radius: 8, y: 4
                                )
                            if themeRaw == theme.rawValue {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                        }
                        Text(LocalizedStringKey(theme.rawValue))
                            .font(.caption)
                            .foregroundStyle(themeRaw == theme.rawValue ? theme.color : .secondary)
                            .bold(themeRaw == theme.rawValue)
                    }
                }
                .buttonStyle(.plain)
                .scaleEffect(themeRaw == theme.rawValue ? 1.08 : 1.0)
                .animation(.spring(response: 0.2, dampingFraction: 0.6), value: themeRaw)
            }
        }
        .padding(.bottom, 8)
    }
}
