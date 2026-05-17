import SwiftUI
import SwiftData
import Combine

private let streakMilestones = Set([7, 30, 100])

struct HomeView: View {
    @Query(sort: \Habit.sortOrder) var habits: [Habit]
    @Environment(\.modelContext) var modelContext
    @Environment(\.themeColor) var themeColor
    @Environment(AchievementManager.self) var achievementManager
    @Environment(AdManager.self) var adManager
    @Environment(ConsentManager.self) var consentManager
    @Environment(SubscriptionManager.self) var subscriptionManager
    @AppStorage(StorageKeys.defaultHomeView) private var showTimeline: Bool = false
    @State private var showAddHabit = false
    @State private var editHabit: Habit? = nil
    @State private var confettiFireID: UUID? = nil
    @State private var pendingNoteEntry: HabitEntry? = nil
    @State private var selectedCategory: HabitCategory? = nil
    @State private var achievementQueue: [Achievement] = []
    @State private var visibleAchievement: Achievement? = nil
    @State private var bannerTask: Task<Void, Never>? = nil
    @AppStorage(StorageKeys.hapticEnabled) private var hapticEnabled = true
    @AppStorage(StorageKeys.userName) private var userName: String = ""
    @State private var emptyPulse = false
    @State private var tlNow = Date()
    @State private var milestoneShareHabit: Habit? = nil
    @State private var milestoneShareItems: [Any] = []
    @State private var showMilestoneShareSheet = false
    private let tlClock = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    private static let tlTimeFmt: DateFormatter = {
        let f = DateFormatter()
        f.timeStyle = .short
        f.dateStyle = .none
        return f
    }()

    // MARK: - Timeline helpers

    private func tlMinutes(_ date: Date) -> Int {
        let c = Calendar.current.dateComponents([.hour, .minute], from: date)
        return (c.hour ?? 0) * 60 + (c.minute ?? 0)
    }

    private var tlNowMinutes: Int { tlMinutes(tlNow) }

    private var tlScheduled: [Habit] {
        habits
            .filter { $0.scheduledTime != nil }
            .sorted { tlMinutes($0.scheduledTime!) < tlMinutes($1.scheduledTime!) }
    }

    private var tlUnscheduled: [Habit] {
        habits.filter { $0.scheduledTime == nil }
    }

    private enum TLItem: Identifiable {
        case habit(Habit)
        case nowMarker
        var id: String {
            switch self {
            case .habit(let h): return h.id.uuidString
            case .nowMarker: return "now"
            }
        }
    }

    private var tlItems: [TLItem] {
        var result: [TLItem] = []
        var inserted = false
        for habit in tlScheduled {
            if !inserted && tlMinutes(habit.scheduledTime!) > tlNowMinutes {
                result.append(.nowMarker)
                inserted = true
            }
            result.append(.habit(habit))
        }
        if !inserted { result.append(.nowMarker) }
        return result
    }

    // MARK: - List helpers

    private var filteredHabits: [Habit] {
        guard let category = selectedCategory else { return habits }
        return habits.filter { $0.category == category }
    }

    private var todayProgress: Double {
        guard !habits.isEmpty else { return 0 }
        return Double(habits.filter { $0.isCompletedToday }.count) / Double(habits.count)
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            List {
                headerCard
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 4, trailing: 20))

                if !showTimeline {
                    categoryFilterBar
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 4, trailing: 0))
                }

                if showTimeline {
                    timelineContent
                } else {
                    habitListContent
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Habits")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if !showTimeline {
                        EditButton()
                            .foregroundStyle(themeColor)
                            .opacity(habits.isEmpty ? 0 : 1)
                            .disabled(habits.isEmpty)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { showTimeline.toggle() }
                    } label: {
                        Image(systemName: showTimeline ? "list.bullet" : "clock")
                            .font(.title3)
                            .foregroundStyle(themeColor)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAddHabit = true } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(themeColor)
                    }
                }
            }
            .sheet(isPresented: $showAddHabit) { AddEditHabitView() }
            .sheet(item: $editHabit) { habit in AddEditHabitView(editHabit: habit) }
            .sheet(item: $pendingNoteEntry) { entry in NoteEntryView(entry: entry) }
            .safeAreaInset(edge: .bottom) {
                if consentManager.canShowAds {
                    BannerAdView().frame(height: BannerAdView.height)
                }
            }
            .overlay { ConfettiOverlay(fireID: confettiFireID) }
            .overlay(alignment: .top) {
                if let achievement = visibleAchievement {
                    AchievementBanner(achievement: achievement) { dismissBanner() }
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .padding(.top, 8)
                        .zIndex(10)
                }
            }
            .overlay(alignment: .bottom) {
                if let shareHabit = milestoneShareHabit {
                    MilestoneShareBanner(
                        habit: shareHabit,
                        themeColor: themeColor,
                        onShare: {
                            withAnimation(.easeOut(duration: 0.25)) { milestoneShareHabit = nil }
                            prepareMilestoneShare(habit: shareHabit)
                        },
                        onDismiss: {
                            withAnimation(.easeOut(duration: 0.25)) { milestoneShareHabit = nil }
                        }
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, consentManager.canShowAds ? BannerAdView.height : 0)
                    .zIndex(8)
                }
            }
            .sheet(isPresented: $showMilestoneShareSheet) {
                ShareSheet(activityItems: milestoneShareItems)
            }
            .onReceive(tlClock) { tlNow = $0 }
            .onDisappear {
                bannerTask?.cancel()
                bannerTask = nil
            }
        }
    }

    // MARK: - Timeline rows

    @ViewBuilder
    private var timelineContent: some View {
        if habits.isEmpty {
            emptyState
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
        } else {
            ForEach(tlItems) { item in
                switch item {
                case .habit(let h):
                    NavigationLink(destination: HabitDetailView(habit: h)) {
                        tlHabitRow(h)
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 2, leading: 20, bottom: 2, trailing: 20))
                case .nowMarker:
                    tlNowLine
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 4, leading: 20, bottom: 4, trailing: 20))
                }
            }
            if !tlUnscheduled.isEmpty {
                Text(LocalizedStringKey("Unscheduled"))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 16, leading: 20, bottom: 4, trailing: 20))
                ForEach(tlUnscheduled) { h in
                    NavigationLink(destination: HabitDetailView(habit: h)) {
                        tlHabitRow(h, isUnscheduled: true)
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 2, leading: 20, bottom: 2, trailing: 20))
                }
            }
        }
    }

    private var tlNowLine: some View {
        HStack(spacing: 10) {
            Text(LocalizedStringKey("Now"))
                .font(.caption.bold())
                .foregroundStyle(themeColor)
                .frame(width: 54, alignment: .trailing)
            Rectangle()
                .fill(themeColor)
                .frame(height: 2)
        }
        .padding(.vertical, 4)
    }

    private func tlHabitRow(_ habit: Habit, isUnscheduled: Bool = false) -> some View {
        HStack(spacing: 10) {
            Group {
                if isUnscheduled {
                    Text("—")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                } else if let st = habit.scheduledTime {
                    Text(verbatim: Self.tlTimeFmt.string(from: st))
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                } else {
                    Text("")
                }
            }
            .frame(width: 54, alignment: .trailing)

            Circle()
                .fill(habit.isCompletedToday
                    ? (Color(hex: habit.colorHex) ?? themeColor)
                    : Color(.tertiaryLabel))
                .frame(width: 10, height: 10)

            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill((Color(hex: habit.colorHex) ?? themeColor)
                        .opacity(habit.isCompletedToday ? 1.0 : 0.15))
                    .frame(width: 32, height: 32)
                Image(systemName: habit.icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(habit.isCompletedToday ? .white : (Color(hex: habit.colorHex) ?? themeColor))
            }

            Text(habit.title)
                .font(.subheadline)
                .strikethrough(habit.isCompletedToday, color: .secondary)
                .foregroundStyle(habit.isCompletedToday ? .secondary : .primary)
                .lineLimit(1)

            Spacer()

            Button { toggleHabit(habit) } label: {
                Image(systemName: habit.isCompletedToday ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(habit.isCompletedToday
                        ? (Color(hex: habit.colorHex) ?? themeColor)
                        : .secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 6)
    }

    // MARK: - Habit list rows

    @ViewBuilder
    private var habitListContent: some View {
        if habits.isEmpty {
            emptyState
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
        } else if filteredHabits.isEmpty {
            filteredEmptyState
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
        } else {
            ForEach(filteredHabits) { habit in
                NavigationLink(destination: HabitDetailView(habit: habit)) {
                    HabitCard(habit: habit) { toggleHabit(habit) }
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                .contextMenu {
                    Button { editHabit = habit } label: { Label("Edit", systemImage: "pencil") }
                    Button(role: .destructive) { deleteHabit(habit) } label: { Label("Delete", systemImage: "trash") }
                }
            }
            .onMove(perform: moveHabitsIfUnfiltered)
            .onDelete(perform: deleteHabits)
        }
    }

    // MARK: - Header card

    private var headerCard: some View {
        HStack(alignment: .center, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                greetingText
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

    private var categoryFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                CategoryChip(label: "All", icon: "square.grid.2x2.fill", color: themeColor, isSelected: selectedCategory == nil) {
                    withAnimation(.easeInOut(duration: 0.2)) { selectedCategory = nil }
                }
                ForEach(HabitCategory.allCases, id: \.self) { category in
                    CategoryChip(label: LocalizedStringKey(category.rawValue), icon: category.icon, color: category.color, isSelected: selectedCategory == category) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedCategory = selectedCategory == category ? nil : category
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 4)
        }
        .sensoryFeedback(.selection, trigger: selectedCategory)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.badge.plus")
                .font(.system(size: 64))
                .foregroundStyle(themeColor.opacity(0.4))
                .scaleEffect(emptyPulse ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: emptyPulse)
                .onAppear { emptyPulse = true }
                .onDisappear { emptyPulse = false }
            Text("No habits yet")
                .font(.title3.bold())
            Text("Tap + to add your first habit")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 64)
    }

    private var filteredEmptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .font(.system(size: 48))
                .foregroundStyle(.secondary.opacity(0.5))
            Text("No habits in this category")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 48)
    }

    private var greetingText: Text {
        let hour = Calendar.current.component(.hour, from: Date())
        let base: LocalizedStringKey
        switch hour {
        case 0..<12: base = "Good Morning"
        case 12..<17: base = "Good Afternoon"
        default:      base = "Good Evening"
        }
        let name = userName.trimmingCharacters(in: .whitespaces)
        return name.isEmpty ? Text(base) : Text(base) + Text(", \(name)")
    }

    // MARK: - Actions

    private func toggleHabit(_ habit: Habit) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let existing = habit.entries.first(where: {
            calendar.startOfDay(for: $0.completedDate) == today
        }) {
            existing.isCompleted.toggle()
            if hapticEnabled {
                UIImpactFeedbackGenerator(style: existing.isCompleted ? .medium : .light).impactOccurred()
            }
            if !existing.isCompleted {
                AnalyticsManager.habitUncompleted(category: habit.category.rawValue)
            }
            NotificationManager.shared.scheduleStreakProtectionReminder(habits: habits)
            if !existing.isCompleted { return }
            pendingNoteEntry = existing
            return
        }

        let entry = HabitEntry(completedDate: Date(), isCompleted: true)
        modelContext.insert(entry)
        habit.entries.append(entry)
        if hapticEnabled { UIImpactFeedbackGenerator(style: .medium).impactOccurred() }
        pendingNoteEntry = entry

        let streak = habit.currentStreak
        let isMilestone = streakMilestones.contains(streak)

        AnalyticsManager.habitCompleted(
            name: habit.title,
            category: habit.category.rawValue,
            streak: streak,
            hasScheduledTime: habit.scheduledTime != nil
        )

        if isMilestone {
            AnalyticsManager.streakMilestone(streak: streak)
        }

        adManager.recordCompletion(
            isProUnlocked: subscriptionManager.isProUnlocked,
            isMilestone: isMilestone
        )

        if isMilestone {
            confettiFireID = UUID()
            adManager.requestReviewAtMilestone(streak)
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                milestoneShareHabit = habit
            }
        }

        NotificationManager.shared.scheduleStreakProtectionReminder(habits: habits)

        let newAchievements = achievementManager.check(habits: habits)
        if !newAchievements.isEmpty {
            newAchievements.forEach { AnalyticsManager.achievementUnlocked(id: $0.id, name: $0.title) }
            achievementQueue.append(contentsOf: newAchievements)
            showNextBanner()
        }
    }

    private func showNextBanner() {
        guard visibleAchievement == nil, let next = achievementQueue.first else { return }
        achievementQueue.removeFirst()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            visibleAchievement = next
        }
        bannerTask = Task {
            try? await Task.sleep(for: .seconds(3))
            guard !Task.isCancelled else { return }
            await MainActor.run { dismissBanner() }
        }
    }

    private func dismissBanner() {
        bannerTask?.cancel()
        withAnimation(.easeOut(duration: 0.3)) {
            visibleAchievement = nil
        }
        bannerTask = Task {
            try? await Task.sleep(for: .seconds(0.35))
            guard !Task.isCancelled else { return }
            await MainActor.run { showNextBanner() }
        }
    }

    private func moveHabitsIfUnfiltered(from source: IndexSet, to destination: Int) {
        guard selectedCategory == nil else { return }
        moveHabits(from: source, to: destination)
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
            let habit = filteredHabits[index]
            AnalyticsManager.habitDeleted(category: habit.category.rawValue)
            NotificationManager.shared.removeAllReminders(for: habit)
            modelContext.delete(habit)
        }
    }

    private func deleteHabit(_ habit: Habit) {
        AnalyticsManager.habitDeleted(category: habit.category.rawValue)
        NotificationManager.shared.removeAllReminders(for: habit)
        modelContext.delete(habit)
    }

    @MainActor
    private func prepareMilestoneShare(habit: Habit) {
        let card = StreakShareCardView(habit: habit, themeColor: themeColor)
        let renderer = ImageRenderer(content: card)
        renderer.proposedSize = .init(width: 1080, height: 1920)
        renderer.scale = 1
        guard let uiImage = renderer.uiImage else { return }
        milestoneShareItems = [uiImage]
        showMilestoneShareSheet = true
    }
}

private struct MilestoneShareBanner: View {
    let habit: Habit
    let themeColor: Color
    let onShare: () -> Void
    let onDismiss: () -> Void

    private var habitColor: Color {
        Color(hex: habit.colorHex) ?? themeColor
    }

    private var streakLabel: String {
        String(format: NSLocalizedString("%lld day streak", comment: ""), habit.currentStreak)
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(habitColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: habit.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(habitColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: "\(streakLabel) 🔥")
                    .font(.subheadline.bold())
                Text(LocalizedStringKey("Share your milestone"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button(action: onShare) {
                Text(LocalizedStringKey("Share"))
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(habitColor, in: Capsule())
            }

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                    .padding(8)
            }
        }
        .padding(14)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18))
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .task {
            do {
                try await Task.sleep(for: .seconds(5))
                onDismiss()
            } catch {
                // Task cancelled (view removed) — skip onDismiss
            }
        }
    }
}

private struct CategoryChip: View {
    let label: LocalizedStringKey
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.caption)
                Text(label)
                    .font(.caption.weight(.medium))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(isSelected ? color : Color(.secondarySystemGroupedBackground), in: Capsule())
            .foregroundStyle(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}
