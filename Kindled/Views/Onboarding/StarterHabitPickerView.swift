import SwiftUI

struct StarterHabitTemplate: Identifiable {
    let id: Int
    let titleKey: String
    let icon: String
    let category: HabitCategory
    let colorHex: String
}

let starterHabitTemplates: [StarterHabitTemplate] = [
    StarterHabitTemplate(id: 0, titleKey: "Morning Run", icon: "figure.run",        category: .health,    colorHex: "#FF6B6B"),
    StarterHabitTemplate(id: 1, titleKey: "Read Daily",  icon: "book.fill",          category: .mind,      colorHex: "#45B7D1"),
    StarterHabitTemplate(id: 2, titleKey: "Drink Water", icon: "drop.fill",          category: .lifestyle, colorHex: "#4ECDC4"),
    StarterHabitTemplate(id: 3, titleKey: "Meditate",    icon: "brain.head.profile", category: .mind,      colorHex: "#DDA0DD"),
]

struct StarterHabitPickerView: View {
    let selectedTheme: AppTheme
    @Binding var selectedIDs: Set<Int>
    @State private var appeared = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [selectedTheme.color, selectedTheme.color.opacity(0.65)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.4), value: selectedTheme.rawValue)

            GeometryReader { geo in
                Circle()
                    .fill(.white.opacity(0.06))
                    .frame(width: geo.size.width * 0.8)
                    .offset(x: geo.size.width * 0.4, y: -geo.size.height * 0.1)
                Circle()
                    .fill(.white.opacity(0.06))
                    .frame(width: geo.size.width * 0.6)
                    .offset(x: -geo.size.width * 0.25, y: geo.size.height * 0.55)
            }

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    VStack(spacing: 8) {
                        Text(LocalizedStringKey("Quick start"))
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, alignment: .center)
                        Text(LocalizedStringKey("Pick habits to begin with"))
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.75))
                            .multilineTextAlignment(.center)
                    }
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 16)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1), value: appeared)

                    VStack(spacing: 12) {
                        ForEach(starterHabitTemplates) { template in
                            StarterHabitCard(
                                template: template,
                                isSelected: selectedIDs.contains(template.id)
                            ) {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.65)) {
                                    if selectedIDs.contains(template.id) {
                                        selectedIDs.remove(template.id)
                                    } else {
                                        selectedIDs.insert(template.id)
                                    }
                                }
                            }
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 20)
                            .animation(
                                .spring(response: 0.5, dampingFraction: 0.7)
                                    .delay(0.2 + Double(template.id) * 0.07),
                                value: appeared
                            )
                        }
                    }

                    Spacer().frame(height: 140)
                }
                .padding(.horizontal, 24)
                .padding(.top, 64)
            }
        }
        .onAppear {
            appeared = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { appeared = true }
        }
        .onDisappear { appeared = false }
    }
}

private struct StarterHabitCard: View {
    let template: StarterHabitTemplate
    let isSelected: Bool
    let action: () -> Void

    private var habitColor: Color {
        Color(hex: template.colorHex) ?? .purple
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(habitColor.opacity(isSelected ? 1.0 : 0.3))
                        .frame(width: 52, height: 52)
                    Image(systemName: template.icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(isSelected ? .white : habitColor)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(LocalizedStringKey(template.titleKey))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                    Text(LocalizedStringKey(template.category.rawValue))
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.65))
                }

                Spacer()

                ZStack {
                    Circle()
                        .fill(isSelected ? .white : .white.opacity(0.2))
                        .frame(width: 28, height: 28)
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(habitColor)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(isSelected ? .white.opacity(0.22) : .white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .strokeBorder(isSelected ? .white.opacity(0.7) : .clear, lineWidth: 1.5)
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
