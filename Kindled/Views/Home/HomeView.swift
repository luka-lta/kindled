import SwiftUI
import SwiftData

private let streakMilestones = Set([7, 30, 100])

struct HomeView: View {
    @Query(sort: \Habit.sortOrder) var habits: [Habit]
    @Environment(\.modelContext) var modelContext
    @Environment(\.themeColor) var themeColor
    @State private var showAddHabit = false
    @State private var editHabit: Habit? = nil
    @State private var confettiFireID: UUID? = nil
    @State private var pendingNoteEntry: HabitEntry? = nil

    private var todayProgress: Double {
        guard !habits.isEmpty else { return 0 }
        return Double(habits.filter { $0.isCompletedToday }.count) / Double(habits.count)
    }

    var body: some View {
        NavigationStack {
            List {
                headerCard
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 4, trailing: 20))

                if habits.isEmpty {
                    emptyState
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                } else {
                    ForEach(habits) { habit in
                        NavigationLink(destination: HabitDetailView(habit: habit)) {
                            HabitCard(habit: habit) {
                                toggleHabit(habit)
                            }
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                        .contextMenu {
                            Button { editHabit = habit } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            Button(role: .destructive) { deleteHabit(habit) } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                    .onMove(perform: moveHabits)
                    .onDelete(perform: deleteHabits)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Habits")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if !habits.isEmpty {
                        EditButton()
                            .foregroundStyle(themeColor)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddHabit = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(themeColor)
                    }
                }
            }
            .sheet(isPresented: $showAddHabit) {
                AddEditHabitView()
            }
            .sheet(item: $editHabit) { habit in
                AddEditHabitView(editHabit: habit)
            }
            .sheet(item: $pendingNoteEntry) { entry in
                NoteEntryView(entry: entry)
            }
            .overlay { ConfettiOverlay(fireID: confettiFireID) }
        }
    }

    private var headerCard: some View {
        HStack(alignment: .center, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text(greeting)
                    .font(.title3.bold())
                Text(Date().formatted(.dateTime.weekday(.wide).month(.wide).day()))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if !habits.isEmpty {
                    Text("\(habits.filter { $0.isCompletedToday }.count) of \(habits.count) done")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.top, 2)
                }
            }
            Spacer()
            ZStack {
                ProgressRing(progress: todayProgress, color: themeColor, lineWidth: 10)
                    .frame(width: 72, height: 72)
                VStack(spacing: 0) {
                    Text("\(Int(todayProgress * 100))")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                    Text("%")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.badge.plus")
                .font(.system(size: 64))
                .foregroundStyle(themeColor.opacity(0.4))
            Text("No habits yet")
                .font(.title3.bold())
            Text("Tap + to add your first habit")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 64)
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        default:      return "Good Evening"
        }
    }

    private func toggleHabit(_ habit: Habit) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let existing = habit.entries.first(where: {
            calendar.startOfDay(for: $0.completedDate) == today
        }) {
            existing.isCompleted.toggle()
            if !existing.isCompleted {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                return
            }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            pendingNoteEntry = existing
        } else {
            let entry = HabitEntry(completedDate: Date(), isCompleted: true)
            modelContext.insert(entry)
            habit.entries.append(entry)
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            pendingNoteEntry = entry
        }

        if streakMilestones.contains(habit.currentStreak) {
            confettiFireID = UUID()
        }
    }

    private func moveHabits(from source: IndexSet, to destination: Int) {
        var reordered = habits
        reordered.move(fromOffsets: source, toOffset: destination)
        for (index, habit) in reordered.enumerated() {
            habit.sortOrder = index
        }
    }

    private func deleteHabits(at offsets: IndexSet) {
        for index in offsets {
            let habit = habits[index]
            NotificationManager.shared.removeAllReminders(for: habit)
            modelContext.delete(habit)
        }
    }

    private func deleteHabit(_ habit: Habit) {
        NotificationManager.shared.removeAllReminders(for: habit)
        modelContext.delete(habit)
    }
}
