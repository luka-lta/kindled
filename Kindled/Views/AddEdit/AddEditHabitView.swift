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
    @State private var reminderWeekday: Int = 2
    @State private var stackName: String = ""
    @State private var isTypingNewStack: Bool = false
    @FocusState private var stackFieldFocused: Bool

    private var existingStackNames: [String] {
        Array(Set(allHabits.compactMap { $0.stackName }.filter { !$0.isEmpty })).sorted()
    }
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

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespaces)
    }

    private var canSave: Bool {
        guard !trimmedTitle.isEmpty else { return false }
        return !allHabits.contains {
            $0.title.lowercased() == trimmedTitle.lowercased() && $0.id != editHabit?.id
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    PreviewCard(
                        title: title,
                        selectedIcon: selectedIcon,
                        selectedColor: selectedColor,
                        frequency: frequency,
                        selectedCategory: selectedCategory
                    )
                    detailsCard
                    CategoryCard(selectedCategory: $selectedCategory)
                    customizeCard
                    ScheduleCard(
                        frequency: $frequency,
                        accentColor: accentColor,
                        reminderEnabled: $reminderEnabled,
                        reminderTime: $reminderTime,
                        reminderWeekday: $reminderWeekday,
                        scheduledTimeEnabled: $scheduledTimeEnabled,
                        scheduledTimeValue: $scheduledTimeValue
                    )
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

    // MARK: - Inner Structs

    private struct PreviewCard: View {
        let title: String
        let selectedIcon: String
        let selectedColor: String
        let frequency: HabitFrequency
        let selectedCategory: HabitCategory

        private var accentColor: Color {
            Color(hex: selectedColor) ?? .purple
        }

        var body: some View {
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
    }

    private struct CategoryCard: View {
        @Binding var selectedCategory: HabitCategory

        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                AddEditHabitView.cardHeader(title: "Category", icon: "square.grid.2x2.fill", color: selectedCategory.color)

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
    }

    private struct ScheduleCard: View {
        @Binding var frequency: HabitFrequency
        let accentColor: Color
        @Binding var reminderEnabled: Bool
        @Binding var reminderTime: Date
        @Binding var reminderWeekday: Int
        @Binding var scheduledTimeEnabled: Bool
        @Binding var scheduledTimeValue: Date

        private static let weekdays: [(Int, String)] = [
            (2, "Monday"), (3, "Tuesday"), (4, "Wednesday"),
            (5, "Thursday"), (6, "Friday"), (7, "Saturday"), (1, "Sunday")
        ]

        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                AddEditHabitView.cardHeader(title: "Schedule", icon: "calendar", color: .green)

                Divider()

                VStack(alignment: .leading, spacing: 10) {
                    AddEditHabitView.sectionLabel("Frequency")
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

                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.orange)
                            .frame(width: 32, height: 32)
                        Image(systemName: "bell.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    Text(frequency == .weekly ? "Weekly Reminder" : "Daily Reminder")
                        .font(.subheadline)
                    Spacer()
                    if reminderEnabled {
                        DatePicker("", selection: $reminderTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .tint(accentColor)
                    }
                    Toggle("", isOn: $reminderEnabled)
                        .labelsHidden()
                        .tint(accentColor)
                }

                if reminderEnabled && frequency == .weekly {
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.orange.opacity(0.15))
                                .frame(width: 32, height: 32)
                            Image(systemName: "calendar.badge.clock")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color.orange)
                        }
                        Text(LocalizedStringKey("Day of Week"))
                            .font(.subheadline)
                        Spacer()
                        Picker("", selection: $reminderWeekday) {
                            ForEach(Self.weekdays, id: \.0) { value, name in
                                Text(LocalizedStringKey(name)).tag(value)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(accentColor)
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }

                Divider()

                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.blue)
                            .frame(width: 32, height: 32)
                        Image(systemName: "clock.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    Text(LocalizedStringKey("Scheduled Time"))
                        .font(.subheadline)
                    Spacer()
                    if scheduledTimeEnabled {
                        DatePicker("", selection: $scheduledTimeValue, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .tint(accentColor)
                    }
                    Toggle("", isOn: $scheduledTimeEnabled)
                        .labelsHidden()
                        .tint(accentColor)
                }
            }
            .padding(20)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
            .animation(.spring(response: 0.2, dampingFraction: 0.8), value: reminderEnabled)
            .animation(.spring(response: 0.2, dampingFraction: 0.8), value: scheduledTimeEnabled)
        }
    }

    // MARK: - Details

    private var detailsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Self.cardHeader(title: "Name", icon: "pencil.line", color: .blue)

            Divider()

            HStack(spacing: 12) {
                Image(systemName: "character.cursor.ibeam")
                    .foregroundStyle(.secondary)
                    .frame(width: 20)
                TextField("e.g. Morning Run", text: $title)
                    .font(.body)
                    .autocorrectionDisabled()
            }

            Divider()

            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "rectangle.stack.fill")
                        .foregroundStyle(Color.indigo)
                        .frame(width: 20)
                    Text(LocalizedStringKey("Stack"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    if !stackName.isEmpty && !isTypingNewStack {
                        Button {
                            withAnimation(.spring(response: 0.2)) { stackName = "" }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }

                if isTypingNewStack {
                    HStack(spacing: 8) {
                        TextField(LocalizedStringKey("Stack name"), text: $stackName)
                            .font(.subheadline)
                            .autocorrectionDisabled()
                            .focused($stackFieldFocused)
                        Button {
                            withAnimation(.spring(response: 0.2)) {
                                isTypingNewStack = false
                                stackName = ""
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.indigo.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(existingStackNames, id: \.self) { name in
                                Button {
                                    withAnimation(.spring(response: 0.2)) {
                                        stackName = stackName == name ? "" : name
                                    }
                                } label: {
                                    Text(name)
                                        .font(.caption.weight(.semibold))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            stackName == name ? Color.indigo : Color.indigo.opacity(0.12),
                                            in: Capsule()
                                        )
                                        .foregroundStyle(stackName == name ? Color.white : Color.indigo)
                                }
                                .buttonStyle(.plain)
                            }
                            Button {
                                withAnimation(.spring(response: 0.2)) {
                                    isTypingNewStack = true
                                    stackName = ""
                                }
                                stackFieldFocused = true
                            } label: {
                                Label(LocalizedStringKey("New"), systemImage: "plus")
                                    .font(.caption.weight(.semibold))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.indigo.opacity(0.12), in: Capsule())
                                    .foregroundStyle(Color.indigo)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isTypingNewStack)
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Customize

    private var customizeCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Self.cardHeader(title: "Customize", icon: "paintbrush.fill", color: accentColor)

            Divider()

            VStack(alignment: .leading, spacing: 10) {
                Self.sectionLabel("Color")
                HabitColorPicker(selectedColor: $selectedColor, colors: palette)
            }

            Divider()

            VStack(alignment: .leading, spacing: 10) {
                Self.sectionLabel("Icon")
                IconPickerView(selectedIcon: $selectedIcon, accentColor: accentColor)
            }
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Helpers

    @ViewBuilder
    static func cardHeader(title: String, icon: String, color: Color) -> some View {
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
    static func sectionLabel(_ text: String) -> some View {
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
            reminderWeekday = reminder.weekday
        }
        if let st = habit.scheduledTime {
            scheduledTimeEnabled = true
            scheduledTimeValue = st
        }
        let loaded = habit.stackName ?? ""
        stackName = loaded
        isTypingNewStack = !loaded.isEmpty && !existingStackNames.contains(loaded)
    }

    private func save() {
        if let existing = editHabit {
            updateExistingHabit(existing)
        } else {
            createNewHabit()
        }
    }

    private func createNewHabit() {
        let habit = Habit(
            title: trimmedTitle,
            icon: selectedIcon,
            colorHex: selectedColor,
            frequency: frequency,
            category: selectedCategory,
            sortOrder: allHabits.count,
            scheduledTime: scheduledTimeEnabled ? scheduledTimeValue : nil
        )
        habit.stackName = stackName.trimmingCharacters(in: .whitespaces).isEmpty ? nil : stackName.trimmingCharacters(in: .whitespaces)
        modelContext.insert(habit)
        AnalyticsManager.habitCreated(
            category: selectedCategory.rawValue,
            frequency: frequency.rawValue,
            hasReminder: reminderEnabled,
            hasScheduledTime: scheduledTimeEnabled
        )
        applyReminders(to: habit)
    }

    private func updateExistingHabit(_ habit: Habit) {
        habit.title = trimmedTitle
        habit.icon = selectedIcon
        habit.colorHex = selectedColor
        habit.frequency = frequency
        habit.category = selectedCategory
        habit.scheduledTime = scheduledTimeEnabled ? scheduledTimeValue : nil
        habit.stackName = stackName.trimmingCharacters(in: .whitespaces).isEmpty ? nil : stackName.trimmingCharacters(in: .whitespaces)
        AnalyticsManager.habitEdited(category: selectedCategory.rawValue, frequency: frequency.rawValue)
        applyReminders(to: habit)
    }

    private func applyReminders(to habit: Habit) {
        let oldReminderIDs = habit.reminders.map { $0.notificationID }
        for reminder in habit.reminders {
            modelContext.delete(reminder)
        }

        if reminderEnabled {
            let comps = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
            let weekday = frequency == .weekly ? reminderWeekday : 2
            let reminder = HabitReminder(hour: comps.hour ?? 9, minute: comps.minute ?? 0, weekday: weekday)
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
