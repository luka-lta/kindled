import SwiftUI

struct IconPickerView: View {
    @Binding var selectedIcon: String
    let accentColor: Color

    private let icons: [(String, [String])] = [
        ("Health", ["figure.run", "figure.walk", "figure.hiking", "dumbbell.fill", "heart.fill", "drop.fill", "bed.double.fill", "fork.knife", "cup.and.saucer.fill", "cross.fill"]),
        ("Mind", ["book.fill", "pencil", "brain.head.profile", "lightbulb.fill", "moon.fill", "music.note", "headphones", "paintbrush.fill", "gamecontroller.fill", "graduationcap.fill"]),
        ("Nature", ["leaf.fill", "sun.max.fill", "cloud.fill", "snowflake", "flame.fill", "bolt.fill", "tree.fill", "wind", "star.fill", "moon.stars.fill"]),
        ("Life", ["house.fill", "car.fill", "airplane", "bicycle", "camera.fill", "phone.fill", "laptopcomputer", "pawprint.fill", "gift.fill", "bag.fill"])
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(icons, id: \.0) { category, symbols in
                VStack(alignment: .leading, spacing: 10) {
                    Text(category)
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 10) {
                        ForEach(symbols, id: \.self) { icon in
                            Button {
                                withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                                    selectedIcon = icon
                                }
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(selectedIcon == icon ? accentColor : Color(.tertiarySystemFill))
                                        .frame(height: 48)
                                    Image(systemName: icon)
                                        .font(.system(size: 20))
                                        .foregroundStyle(selectedIcon == icon ? .white : .secondary)
                                }
                            }
                            .buttonStyle(.plain)
                            .scaleEffect(selectedIcon == icon ? 1.08 : 1.0)
                            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: selectedIcon)
                        }
                    }
                }
            }
        }
    }
}
