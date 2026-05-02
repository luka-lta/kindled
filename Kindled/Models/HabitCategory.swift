import SwiftUI

enum HabitCategory: String, Codable, CaseIterable {
    case health    = "Health"
    case mind      = "Mind"
    case lifestyle = "Lifestyle"
    case finance   = "Finance"
    case social    = "Social"

    var icon: String {
        switch self {
        case .health:    return "heart.fill"
        case .mind:      return "brain.head.profile"
        case .lifestyle: return "house.fill"
        case .finance:   return "dollarsign.circle.fill"
        case .social:    return "person.2.fill"
        }
    }

    var color: Color {
        switch self {
        case .health:    return .red
        case .mind:      return .purple
        case .lifestyle: return .blue
        case .finance:   return .green
        case .social:    return .orange
        }
    }
}
