import SwiftUI
import UserNotifications

struct SettingsView: View {
    @Environment(\.themeColor) var themeColor
    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined
    @AppStorage("hapticEnabled") private var hapticStored = true
    @AppStorage("appAppearance") private var appearanceRaw: String = "System"
    @AppStorage("appTheme") private var themeRaw: String = "Purple"

    private let appearanceOptions = ["System", "Light", "Dark"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    appHeaderCard
                    personalizationCard
                    notificationsCard
                    preferencesCard
                    aboutCard
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .onAppear { checkNotificationStatus() }
        }
    }

    // MARK: - Header

    private var appHeaderCard: some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [themeColor, themeColor.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 64, height: 64)
                .overlay {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 30))
                        .foregroundStyle(.white)
                }
                .shadow(color: themeColor.opacity(0.4), radius: 8, y: 4)

            VStack(alignment: .leading, spacing: 4) {
                Text("Habit Tracker")
                    .font(.title3.bold())
                Text("Build better habits, daily")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Personalization

    private var personalizationCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            cardHeader(title: "Personalization", icon: "paintbrush.fill", color: themeColor)

            Divider()

            VStack(alignment: .leading, spacing: 12) {
                Text("Color Theme")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                    ForEach(AppTheme.allCases, id: \.rawValue) { theme in
                        Button {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                                themeRaw = theme.rawValue
                            }
                        } label: {
                            VStack(spacing: 6) {
                                ZStack {
                                    Circle()
                                        .fill(theme.color)
                                        .frame(width: 48, height: 48)
                                        .shadow(
                                            color: theme.color.opacity(themeRaw == theme.rawValue ? 0.5 : 0),
                                            radius: 6, y: 3
                                        )
                                    if themeRaw == theme.rawValue {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundStyle(.white)
                                    }
                                }
                                Text(theme.rawValue)
                                    .font(.caption2)
                                    .foregroundStyle(themeRaw == theme.rawValue ? theme.color : .secondary)
                                    .bold(themeRaw == theme.rawValue)
                            }
                        }
                        .buttonStyle(.plain)
                        .scaleEffect(themeRaw == theme.rawValue ? 1.1 : 1.0)
                        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: themeRaw)
                    }
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 10) {
                Text("App Appearance")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Picker("Appearance", selection: $appearanceRaw) {
                    ForEach(appearanceOptions, id: \.self) { Text($0).tag($0) }
                }
                .pickerStyle(.segmented)
            }
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Notifications

    private var notificationsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            cardHeader(title: "Notifications", icon: "bell.fill", color: .orange)

            Divider()

            HStack(alignment: .center) {
                settingRow(
                    icon: "bell.badge.fill",
                    iconColor: .orange,
                    title: "Permission Status",
                    subtitle: notificationStatusDescription
                )
                Spacer()
                statusBadge
            }

            if notificationStatus == .denied {
                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    HStack {
                        Image(systemName: "arrow.up.right.square.fill")
                        Text("Open System Settings")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .font(.subheadline.weight(.medium))
                    .padding(12)
                    .background(Color.orange.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(.orange)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Preferences

    private var preferencesCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            cardHeader(title: "Preferences", icon: "slider.horizontal.3", color: .blue)

            Divider()

            HStack(alignment: .center) {
                settingRow(
                    icon: "waveform",
                    iconColor: .pink,
                    title: "Haptic Feedback",
                    subtitle: "Vibrate on habit completion"
                )
                Spacer()
                Toggle("", isOn: $hapticStored)
                    .labelsHidden()
                    .tint(themeColor)
            }
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - About

    private var aboutCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            cardHeader(title: "About", icon: "info.circle.fill", color: .gray)

            Divider()

            HStack {
                settingRow(
                    icon: "tag.fill",
                    iconColor: themeColor,
                    title: "Version",
                    subtitle: nil
                )
                Spacer()
                Text("1.0.0")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Reusable Components

    @ViewBuilder
    private func cardHeader(title: String, icon: String, color: Color) -> some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color)
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
            }
            Text(title)
                .font(.headline)
        }
    }

    @ViewBuilder
    private func settingRow(icon: String, iconColor: Color, title: String, subtitle: String?) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor)
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var notificationStatusDescription: String {
        switch notificationStatus {
        case .authorized: return "Reminders will arrive on time"
        case .denied:     return "Enable in System Settings"
        default:          return "Not configured yet"
        }
    }

    private var statusBadge: some View {
        Group {
            switch notificationStatus {
            case .authorized:
                Label("On", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.subheadline.bold())
            case .denied:
                Label("Off", systemImage: "xmark.circle.fill")
                    .foregroundStyle(.red)
                    .font(.subheadline.bold())
            default:
                Label("—", systemImage: "questionmark.circle.fill")
                    .foregroundStyle(.secondary)
                    .font(.subheadline.bold())
            }
        }
    }

    private func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                notificationStatus = settings.authorizationStatus
            }
        }
    }
}
