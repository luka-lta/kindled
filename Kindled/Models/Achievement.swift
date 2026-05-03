import SwiftUI

struct Achievement: Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let color: Color

    static let all: [Achievement] = [
        Achievement(id: "first_flame",       title: "First Flame",        description: "Complete your first habit",               icon: "flame.fill",                     color: .orange),
        Achievement(id: "week_warrior",      title: "Week Warrior",       description: "Reach a 7-day streak",                   icon: "calendar.badge.checkmark",       color: .blue),
        Achievement(id: "month_master",      title: "Month Master",       description: "Reach a 30-day streak",                  icon: "medal.fill",                     color: .purple),
        Achievement(id: "century",           title: "Century Club",       description: "Reach a 100-day streak",                 icon: "trophy.fill",                    color: .yellow),
        Achievement(id: "dedicated",         title: "Dedicated",          description: "25 total completions",                   icon: "star.fill",                      color: .pink),
        Achievement(id: "committed",         title: "Committed",          description: "100 total completions",                  icon: "star.circle.fill",               color: .indigo),
        Achievement(id: "veteran",           title: "Veteran",            description: "500 total completions",                  icon: "crown.fill",                     color: .red),
        Achievement(id: "collector",         title: "Habit Collector",    description: "Track 3 habits at once",                 icon: "square.grid.2x2.fill",           color: .teal),
        Achievement(id: "explorer",          title: "Explorer",           description: "Track 5 habits at once",                 icon: "map.fill",                       color: .green),
        Achievement(id: "perfect_day",       title: "Perfect Day",        description: "Complete all habits in one day",         icon: "checkmark.seal.fill",            color: .cyan),
        Achievement(id: "category_explorer", title: "Category Explorer",  description: "Have habits in 3 different categories",  icon: "tag.fill",                       color: .mint),
        Achievement(id: "on_fire",           title: "On Fire",            description: "3 habits with a streak of 7+",           icon: "flame.circle.fill",              color: .red),
    ]
}
