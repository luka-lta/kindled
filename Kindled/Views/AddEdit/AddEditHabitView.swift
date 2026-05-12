import SwiftUI
import SwiftData

struct AddEditHabitView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @Query(sort: \Habit.sortOrder) private var allHabits: [Habit]

    var editHabit: Habit? = nil

    @State private var title = ""
    @State private var selectedIcon = "star.fill"
    @State private var selectedColor = "#6C63FF"
    @State private var frequency: HabitFrequency = .daily
    @State private var selectedCategory: HabitCategory = .health
    @State private var reminderEnabled = false
    @State private var reminderTime = Calendar.current.date(
        bySettingHour: 9, minute: 0, second: 0, of: Date()
    ) ?? Date()
    @State private var scheduledTimeEnabled = false
    @State private var scheduledTimeValue = Calendar.current.date(
        bySettingHour: 8, minute: 0, second: 0, of: Date()
    ) ?? Date()

    private let palette = [
        "#6C63FF", "#FF6B6B", "#4ECDC4", "#45B7D1",
        "#96CEB4", "#F7DC6F", "#DDA0DD", "#F0A500",
        "#FF9F43", "#EE5A24", "#0652DD", "#1289A7",
        "#C4E538", "#FDA7DF", "#D980FA", "#9980FA"
    ]

    private var accentColor: Color {
        Color(hex: selectedColor) ?? .purple
    }

    private var canSave: Bool {
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return false }
        return !allHabits.contains {
            $0.title.lowercased() == trimmed.lowercased() && $0.id != editHabit?.id
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    previewCard
                    detailsCard
                    categoryCard
                    customizeCard
                    scheduleCard
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(editHabit == nil ? LocalizedStringKey("New Habit") : LocalizedStringKey("Edit Habit"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.secondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(!canSave)
                        .font(.body.bold())
                        .foregroundStyle(canSave ? accentColor : .secondary)
                }
            }
            .onAppear { loadExisting() }
        }
    }

    // MARK: - Preview

    private var previewCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [accentColor, accentColor.opacity(0.65)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: accentColor.opacity(0.4), radius: 12, y: 6)

            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.2))
                        .frame(width: 90, height: 90)
                    Image(systemName: selectedIcon)
                        .font(.system(size: 42))
                        .foregroundStyle(.white)
                }

                (title.isEmpty ? Text("Habit Name") : Text(verbatim: title))
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .opacity(title.isEmpty ? 0.5 : 1.0)
                    .animation(.easeInOut(duration: 0.15), value: title)

                HStack(spacing: 6) {
                    Text(frequency.rawValue)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.75))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(.white.opacity(0.15), in: Capsule())

                    HStack(spacing: 4) {
                        Image(systemName: selectedCategory.icon)
                            .font(.caption2.bold())
                        Text(LocalizedStringKey(selectedCategory.rawValue))
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundStyle(.white.opacity(0.75))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(.white.opacity(0.15), in: Capsule())
                }
            }
            .padding(.vertical, 36)
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: accentColor)
        .animation(.spring(response: 0.2, dampingFraction: 0.7), value: selectedIcon)
    }

    // MARK: - Details

    private var detailsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            cardHeader(title: "Name", icon: "pencil.line", color: .blue)

            Divider()

            HStack(spacing: 12) {
                Image(systemName: "character.cursor.ibeam")
                    .foregroundStyle(.secondary)
                    .frame(width: 20)
                TextField("e.g. Morning Run", text: $title)
                    .font(.body)
                    .autocorrectionDisabled()
            }
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Category

    private var categoryCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            cardHeader(title: "Category", icon: "square.grid.2x2.fill", color: selectedCategory.color)

            Divider()

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                ForEach(HabitCategory.allCases, id: \.rawValue) { cat in
                    Button {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                            selectedCategory = cat
                        }
                    } label: {
                        VStack(spacing: 8) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedCategory == cat ? cat.color : cat.color.opacity(0.12))
                                    .frame(height: 48)
                                Image(systemName: cat.icon)
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundStyle(selectedCategory == cat ? .white : cat.color)
                            }
                            Text(LocalizedStringKey(cat.rawValue))
                                .font(.caption.bold())
                                .foregroundStyle(selectedCategory == cat ? cat.color : .secondary)
                        }
                    }
                    .buttonStyle(.plain)
                    .scaleEffect(selectedCategory == cat ? 1.04 : 1.0)
                    .animation(.spring(response: 0.2, dampingFraction: 0.7), value: selectedCategory)
                }
            }
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Customize

    private var customizeCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            cardHeader(title: "Customize", icon: "paintbrush.fill", color: accentColor)

            Divider()

            VStack(alignment: .leading, spacing: 10) {
                sectionLabel("Color")
                HabitColorPicker(selectedColor: $selectedColor, colors: palette)
            }

            Divider()

            VStack(alignment: .leading, spacing: 10) {
                sectionLabel("Icon")
                IconPickerView(selectedIcon: $selectedIcon, accentColor: accentColor)
            }
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Schedule

    private var scheduleCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            cardHeader(title: "Schedule", icon: "calendar", color: .green)

            Divider()

            VStack(alignment: .leading, spacing: 10) {
                sectionLabel("Frequency")
                HStack(spacing: 8) {
                    ForEach(HabitFrequency.allCases, id: \.self) { freq in
                        Button {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                                frequency = freq
                            }
                        } label: {
                            Text(LocalizedStringKey(freq.rawValue))
                                .font(.subheadline.weight(.medium))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 9)
                                .background(
                                    frequency == freq ? accentColor : Color(.tertiarySystemFill),
                                    in: Capsule()
                                )
                                .foregroundStyle(frequency == freq ? .white : .primary)
                        }
                        .buttonStyle(.plain)
                        .animation(.spring(response: 0.2, dampingFraction: 0.7), value: frequency)
                    }
                    Spacer()
                }
            }

            Divider()

            HStack {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.orange)
                            .frame(width: 32, height: 32)
                        Image(systemName: "bell.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(frequency == .weekly ? "Weekly Reminder" : "Daily Reminder")
                            .font(.subheadline)
                        (reminderEnabled ? Text(verbatim: reminderTime.formatted(date: .omitted, time: .shortened)) : Text("Off"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Toggle("", isOn: $reminderEnabled)
                    .labelsHidden()
                    .tint(accentColor)
            }

            if reminderEnabled {
                DatePicker("", selection: $reminderTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .frame(maxWidth: .infinity)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }

            Divider()

            HStack {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.blue)
                            .frame(width: 32, height: 32)
                        Image(systemName: "clock.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(LocalizedStringKey("Scheduled Time"))
                            .font(.subheadline)
                        (scheduledTimeEnabled
                            ? Text(verbatim: scheduledTimeValue.formatted(date: .omitted, time: .shortened))
                            : Text(LocalizedStringKey("Off")))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Toggle("", isOn: $scheduledTimeEnabled)
                    .labelsHidden()
                    .tint(accentColor)
            }

            if scheduledTimeEnabled {
                DatePicker("", selection: $scheduledTimeValue, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .frame(maxWidth: .infinity)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: reminderEnabled)
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: scheduledTimeEnabled)
    }

    // MARK: - Helpers

    @ViewBuilder
    private func cardHeader(title: String, icon: String, color: Color) -> some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color)
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
            }
            Text(LocalizedStringKey(title))
                .font(.headline)
        }
        .animation(.spring(response: 0.3), value: color)
    }

    @ViewBuilder
    private func sectionLabel(_ text: String) -> some View {
        Text(LocalizedStringKey(text))
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }

    // MARK: - Data

    private func loadExisting() {
        guard let habit = editHabit else { return }
        title = habit.title
        selectedIcon = habit.icon
        selectedColor = habit.colorHex
        frequency = habit.frequency
        selectedCategory = habit.category
        if let reminder = habit.reminders.first(where: { $0.isEnabled }) {
            reminderEnabled = true
            var comps = DateComponents()
            comps.hour = reminder.hour
            comps.minute = reminder.minute
            reminderTime = Calendar.current.date(from: comps) ?? Date()
        }
        if let st = habit.scheduledTime {
            scheduledTimeEnabled = true
            scheduledTimeValue = st
        }
    }

    private func save() {
        let habit: Habit
        if let existing = editHabit {
            existing.title = title.trimmingCharacters(in: .whitespaces)
            existing.icon = selectedIcon
            existing.colorHex = selectedColor
            existing.frequency = frequency
            existing.category = selectedCategory
            existing.scheduledTime = scheduledTimeEnabled ? scheduledTimeValue : nil
            habit = existing
        } else {
            habit = Habit(
                title: title.trimmingCharacters(in: .whitespaces),
                icon: selectedIcon,
                colorHex: selectedColor,
                frequency: frequency,
                category: selectedCategory,
                sortOrder: allHabits.count,
                scheduledTime: scheduledTimeEnabled ? scheduledTimeValue : nil
            )
            modelContext.insert(habit)
        }

        let oldReminderIDs = habit.reminders.map { $0.notificationID }
        for reminder in habit.reminders {
            modelContext.delete(reminder)
        }

        if reminderEnabled {
            let comps = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
            let reminder = HabitReminder(hour: comps.hour ?? 9, minute: comps.minute ?? 0)
            modelContext.insert(reminder)
            habit.reminders.append(reminder)

            Task {
                let granted = await NotificationManager.shared.requestPermission()
                oldReminderIDs.forEach { NotificationManager.shared.removeReminder(id: $0) }
                if granted {
                    NotificationManager.shared.scheduleReminder(for: habit, reminder: reminder)
                }
                await MainActor.run { dismiss() }
            }
        } else {
            oldReminderIDs.forEach { NotificationManager.shared.removeReminder(id: $0) }
            dismiss()
        }
    }
}
