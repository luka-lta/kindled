import SwiftUI
import UserNotifications

struct SettingsView: View {
    @Environment(\.themeColor) var themeColor
    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined
    @AppStorage(StorageKeys.hapticEnabled) private var hapticStored = true
    @AppStorage(StorageKeys.appAppearance) private var appearanceRaw: String = "System"
    @AppStorage(StorageKeys.appTheme) private var themeRaw: String = "Purple"
    @AppStorage(StorageKeys.appLanguage) private var appLanguage: String = "system"
    @AppStorage(StorageKeys.userName) private var userName: String = ""
    @State private var showNameEditor = false

    private var currentLanguageLabel: String {
        switch appLanguage {
        case "en": return "🇬🇧 English"
        case "de": return "🇩🇪 Deutsch"
        default:   return "⚙️ System"
        }
    }

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
            cardHeader(title: "Personalization", icon: "paintbrush.fill", color: .green)

            Divider()

            Button { showNameEditor = true } label: {
                settingsNavRow(
                    icon: "person.fill",
                    iconColor: .blue,
                    title: "Your Name",
                    subtitle: userName.isEmpty ? Text("Not set") : Text(verbatim: userName)
                )
            }
            .foregroundStyle(.primary)
            .sheet(isPresented: $showNameEditor) {
                NameEditorSheet(userName: $userName)
            }

            Divider()

            NavigationLink(destination: ThemePickerView()) {
                settingsNavRow(
                    icon: "paintpalette.fill",
                    iconColor: .purple,
                    title: "Color Theme",
                    subtitle: Text(LocalizedStringKey(themeRaw))
                )
            }
            .foregroundStyle(.primary)

            Divider()

            NavigationLink(destination: AppearancePickerView()) {
                settingsNavRow(
                    icon: "moon.fill",
                    iconColor: .indigo,
                    title: "App Appearance",
                    subtitle: Text(LocalizedStringKey(appearanceRaw))
                )
            }
            .foregroundStyle(.primary)

            Divider()

            NavigationLink(destination: LanguagePickerView()) {
                settingsNavRow(
                    icon: "globe",
                    iconColor: .teal,
                    title: "Language",
                    subtitle: Text(verbatim: currentLanguageLabel)
                )
            }
            .foregroundStyle(.primary)
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
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—")
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
            Text(LocalizedStringKey(title))
                .font(.headline)
        }
    }

    @ViewBuilder
    private func settingRow(icon: String, iconColor: Color, title: String, subtitle: LocalizedStringKey?) -> some View {
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
                Text(LocalizedStringKey(title))
                    .font(.subheadline)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    @ViewBuilder
    private func settingsNavRow(icon: String, iconColor: Color, title: String, subtitle: Text) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor)
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(LocalizedStringKey(title))
                    .font(.subheadline)
                subtitle
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundStyle(.tertiary)
        }
        .contentShape(Rectangle())
    }

    private var notificationStatusDescription: LocalizedStringKey {
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

private struct NameEditorSheet: View {
    @Binding var userName: String
    @Environment(\.dismiss) private var dismiss
    @Environment(\.themeColor) private var themeColor
    @State private var draft: String = ""

    var body: some View {
        VStack(spacing: 28) {
            VStack(spacing: 8) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(themeColor)
                Text("Your Name")
                    .font(.title2.bold())
                Text("Used in your greeting on the home screen")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 8)

            TextField("Enter your name", text: $draft)
                .font(.body)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
                .submitLabel(.done)
                .onSubmit { save() }

            VStack(spacing: 12) {
                Button(action: save) {
                    Text("Save")
                        .font(.body.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(themeColor, in: RoundedRectangle(cornerRadius: 14))
                        .foregroundStyle(.white)
                }

                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding(.horizontal, 24)
        .presentationDetents([.fraction(0.5)])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(28)
        .onAppear { draft = userName }
    }

    private func save() {
        userName = draft.trimmingCharacters(in: .whitespaces)
        dismiss()
    }
}
