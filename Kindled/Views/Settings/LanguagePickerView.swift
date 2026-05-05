import SwiftUI

private struct LanguageOption {
    let id: String
    let name: String
    let localName: String
    let flag: String
}

private let languageOptions: [LanguageOption] = [
    LanguageOption(id: "system", name: "System",  localName: "System",  flag: "⚙️"),
    LanguageOption(id: "en",     name: "English",  localName: "English", flag: "🇬🇧"),
    LanguageOption(id: "de",     name: "Deutsch",  localName: "German",  flag: "🇩🇪"),
]

struct LanguagePickerView: View {
    @AppStorage("appLanguage") private var appLanguage: String = "system"
    @Environment(\.themeColor) var themeColor

    var body: some View {
        List {
            ForEach(languageOptions, id: \.id) { option in
                Button {
                    appLanguage = option.id
                } label: {
                    HStack(spacing: 14) {
                        Text(option.flag)
                            .font(.title2)
                            .frame(width: 36)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(verbatim: option.name)
                                .font(.body)
                                .foregroundStyle(.primary)
                            if option.id != "system" {
                                Text(verbatim: option.localName)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        Spacer()

                        if appLanguage == option.id {
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
        .navigationTitle("Language")
        .navigationBarTitleDisplayMode(.inline)
    }
}
