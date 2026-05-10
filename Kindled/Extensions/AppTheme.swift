import SwiftUI

enum AppTheme: String, CaseIterable {
    case purple = "Purple"
    case blue   = "Blue"
    case green  = "Green"
    case orange = "Orange"
    case pink   = "Pink"
    case red    = "Red"
    case teal   = "Teal"
    case indigo = "Indigo"

    var color: Color {
        switch self {
        case .purple: return Color(red: 0.42, green: 0.39, blue: 1.00)
        case .blue:   return Color(red: 0.00, green: 0.48, blue: 1.00)
        case .green:  return Color(red: 0.20, green: 0.78, blue: 0.35)
        case .orange: return Color(red: 1.00, green: 0.58, blue: 0.00)
        case .pink:   return Color(red: 1.00, green: 0.22, blue: 0.56)
        case .red:    return Color(red: 1.00, green: 0.27, blue: 0.23)
        case .teal:   return Color(red: 0.19, green: 0.73, blue: 0.67)
        case .indigo: return Color(red: 0.35, green: 0.34, blue: 0.84)
        }
    }
}

struct ThemeColorKey: EnvironmentKey {
    static let defaultValue: Color = AppTheme.purple.color
}

extension EnvironmentValues {
    var themeColor: Color {
        get { self[ThemeColorKey.self] }
        set { self[ThemeColorKey.self] = newValue }
    }
}
