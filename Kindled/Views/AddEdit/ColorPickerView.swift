import SwiftUI

struct HabitColorPicker: View {
    @Binding var selectedColor: String
    let colors: [String]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(colors, id: \.self) { hex in
                    Button {
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                            selectedColor = hex
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color(hex: hex) ?? .purple)
                                .frame(width: 38, height: 38)
                            if selectedColor == hex {
                                Circle()
                                    .strokeBorder(.white, lineWidth: 2)
                                    .frame(width: 38, height: 38)
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .scaleEffect(selectedColor == hex ? 1.15 : 1.0)
                    .animation(.spring(response: 0.2, dampingFraction: 0.6), value: selectedColor)
                }
            }
            .padding(.vertical, 4)
        }
    }
}
