import SwiftUI

private struct AppearanceOption {
    let id: String
    let icon: String
    let color: Color
}

private let appearanceOptions: [AppearanceOption] = [
    AppearanceOption(id: "System", icon: "circle.lefthalf.filled", color: .gray),
    AppearanceOption(id: "Light",  icon: "sun.max.fill",           color: .orange),
    AppearanceOption(id: "Dark",   icon: "moon.fill",              color: .indigo),
]

struct AppearancePickerView: View {
    @AppStorage(StorageKeys.appAppearance) private var appearanceRaw: String = "System"
    @Environment(\.themeColor) var themeColor

    var body: some View {
        List {
            ForEach(appearanceOptions, id: \.id) { option in
                Button {
                    appearanceRaw = option.id
                } label: {
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(option.color.opacity(0.15))
                                .frame(width: 36, height: 36)
                            Image(systemName: option.icon)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(option.color)
                        }

                        Text(LocalizedStringKey(option.id))
                            .font(.body)
                            .foregroundStyle(.primary)

                        Spacer()

                        if appearanceRaw == option.id {
                            Image(systemName: "checkmark")
                                .font(.body.bold())
                                .foregroundStyle(themeColor)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .navigationTitle("App Appearance")
        .navigationBarTitleDisplayMode(.inline)
    }
}
