import SwiftUI

struct NoteEntryView: View {
    @Bindable var entry: HabitEntry
    @Environment(\.dismiss) var dismiss
    @State private var noteText = ""

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text(entry.completedDate.formatted(.dateTime.weekday(.wide).month(.wide).day()))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 20)

                TextField("How did it go? (optional)", text: $noteText, axis: .vertical)
                    .lineLimit(4...8)
                    .padding(14)
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 20)

                Spacer()
            }
            .padding(.top, 12)
            .navigationTitle("Add Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Skip") { dismiss() }
                        .foregroundStyle(.secondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let trimmed = noteText.trimmingCharacters(in: .whitespacesAndNewlines)
                        entry.note = trimmed.isEmpty ? nil : trimmed
                        dismiss()
                    }
                    .font(.body.bold())
                }
            }
            .onAppear { noteText = entry.note ?? "" }
        }
        .presentationDetents([.height(260)])
        .presentationDragIndicator(.visible)
    }
}
