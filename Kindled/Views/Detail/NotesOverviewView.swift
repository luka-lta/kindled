import SwiftUI

struct NotesOverviewView: View {
    let habit: Habit

    private var habitColor: Color {
        Color(hex: habit.colorHex) ?? .purple
    }

    private var notedEntries: [HabitEntry] {
        habit.entries
            .filter { $0.isCompleted && ($0.note ?? "").isEmpty == false }
            .sorted { $0.completedDate > $1.completedDate }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(habitColor)
                        .frame(width: 28, height: 28)
                    Image(systemName: "note.text")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                }
                Text("Notes")
                    .font(.headline)
                Spacer()
                Text("\(notedEntries.count)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if notedEntries.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "note.text")
                            .font(.system(size: 32))
                            .foregroundStyle(habitColor.opacity(0.3))
                        Text("No notes yet")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 24)
                    Spacer()
                }
            } else {
                VStack(spacing: 8) {
                    ForEach(notedEntries) { entry in
                        NoteRow(entry: entry, color: habitColor)
                    }
                }
            }
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
}

private struct NoteRow: View {
    let entry: HabitEntry
    let color: Color

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 4) {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                    .padding(.top, 5)
                Rectangle()
                    .fill(color.opacity(0.2))
                    .frame(width: 1.5)
            }
            .frame(width: 8)

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.completedDate.formatted(.dateTime.weekday(.wide).day().month(.wide).year()))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(entry.note ?? "")
                    .font(.subheadline)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(.bottom, 4)
    }
}
