import SwiftUI

struct OnboardingView: View {
    @AppStorage(StorageKeys.hasSeenOnboarding) private var hasSeenOnboarding = false
    @AppStorage(StorageKeys.userName) private var savedUserName: String = ""
    @AppStorage(StorageKeys.appTheme) private var themeRaw: String = "Purple"
    @AppStorage(StorageKeys.defaultHomeView) private var showTimeline: Bool = false

    @State private var currentPage = 0
    @State private var nameInput: String = ""
    @State private var selectedTheme: AppTheme = .purple

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $currentPage) {
                WelcomePageView(selectedTheme: selectedTheme)
                    .tag(0)
                PersonalizePageView(
                    nameInput: $nameInput,
                    selectedTheme: $selectedTheme,
                    showTimeline: $showTimeline
                )
                .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()

            VStack(spacing: 20) {
                pageDots
                actionButton
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 52)
        }
        .ignoresSafeArea()
        .onAppear {
            nameInput = savedUserName
            selectedTheme = AppTheme(rawValue: themeRaw) ?? .purple
        }
    }

    private var pageDots: some View {
        HStack(spacing: 8) {
            ForEach(0..<2, id: \.self) { index in
                Capsule()
                    .fill(currentPage == index ? Color.white : Color.white.opacity(0.35))
                    .frame(width: currentPage == index ? 28 : 8, height: 8)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
            }
        }
    }

    private var actionButton: some View {
        let isLast = currentPage == 1

        return Button {
            if isLast {
                savedUserName = nameInput.trimmingCharacters(in: .whitespaces)
                themeRaw = selectedTheme.rawValue
                AnalyticsManager.onboardingCompleted(
                    theme: selectedTheme.rawValue,
                    homeView: showTimeline ? "timeline" : "list"
                )
                hasSeenOnboarding = true
            } else {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    currentPage = 1
                }
            }
        } label: {
            HStack(spacing: 8) {
                Text(isLast ? LocalizedStringKey("Get Started") : LocalizedStringKey("Next"))
                    .font(.system(size: 17, weight: .bold))
                Image(systemName: isLast ? "checkmark" : "arrow.right")
                    .font(.system(size: 15, weight: .bold))
            }
            .foregroundStyle(selectedTheme.color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(.white, in: RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct WelcomePageView: View {
    let selectedTheme: AppTheme
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

            VStack(spacing: 0) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(.white.opacity(0.12))
                        .frame(width: 170, height: 170)
                    Circle()
                        .fill(.white.opacity(0.12))
                        .frame(width: 130, height: 130)
                    Image(systemName: "flame.fill")
                        .font(.system(size: 68))
                        .foregroundStyle(.white)
                }
                .scaleEffect(appeared ? 1.0 : 0.7)
                .opacity(appeared ? 1.0 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.65).delay(0.1), value: appeared)

                Spacer().frame(height: 44)

                VStack(spacing: 14) {
                    Text("Kindled")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text(LocalizedStringKey("Build better habits, daily"))
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                .offset(y: appeared ? 0 : 20)
                .opacity(appeared ? 1.0 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.2), value: appeared)

                Spacer()
                Spacer()
            }
        }
        .onAppear {
            appeared = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { appeared = true }
        }
        .onDisappear { appeared = false }
    }
}

struct PersonalizePageView: View {
    @Binding var nameInput: String
    @Binding var selectedTheme: AppTheme
    @Binding var showTimeline: Bool
    @State private var appeared = false

    private let columns = Array(repeating: GridItem(.flexible()), count: 4)

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [selectedTheme.color, selectedTheme.color.opacity(0.65)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.3), value: selectedTheme.rawValue)

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
                VStack(alignment: .leading, spacing: 28) {
                    Text(LocalizedStringKey("Make it yours"))
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .opacity(appeared ? 1.0 : 0)
                        .offset(y: appeared ? 0 : 16)
                        .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1), value: appeared)

                    nameSection
                        .opacity(appeared ? 1.0 : 0)
                        .offset(y: appeared ? 0 : 16)
                        .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.2), value: appeared)

                    colorSection
                        .opacity(appeared ? 1.0 : 0)
                        .offset(y: appeared ? 0 : 16)
                        .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.3), value: appeared)

                    homeViewSection
                        .opacity(appeared ? 1.0 : 0)
                        .offset(y: appeared ? 0 : 16)
                        .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.4), value: appeared)

                    Spacer().frame(height: 110)
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

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("What should we call you?")

            TextField(
                "",
                text: $nameInput,
                prompt: Text(LocalizedStringKey("Your name (optional)"))
                    .foregroundStyle(.white.opacity(0.5))
            )
            .font(.system(size: 16))
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(.white.opacity(0.2), in: RoundedRectangle(cornerRadius: 14))
            .foregroundStyle(.white)
            .tint(.white)
            .submitLabel(.done)
        }
    }

    private var colorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("Choose a color")

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(AppTheme.allCases, id: \.rawValue) { theme in
                    Button {
                        withAnimation { selectedTheme = theme }
                    } label: {
                        Circle()
                            .fill(theme.color)
                            .frame(height: 52)
                            .overlay(
                                Circle()
                                    .strokeBorder(.white, lineWidth: selectedTheme == theme ? 3 : 0)
                                    .padding(2)
                            )
                            .shadow(color: theme.color.opacity(0.5), radius: selectedTheme == theme ? 10 : 0)
                            .scaleEffect(selectedTheme == theme ? 1.12 : 1.0)
                            .animation(.spring(response: 0.25, dampingFraction: 0.65), value: selectedTheme)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(Text(LocalizedStringKey(theme.rawValue)))
                    .accessibilityAddTraits(selectedTheme == theme ? .isSelected : [])
                }
            }
        }
    }

    private var homeViewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("Your home view")

            HStack(spacing: 12) {
                HomeViewCard(
                    icon: "list.bullet",
                    title: LocalizedStringKey("Habit List"),
                    isSelected: !showTimeline
                ) {
                    withAnimation(.spring(response: 0.3)) { showTimeline = false }
                }
                HomeViewCard(
                    icon: "clock.fill",
                    title: LocalizedStringKey("Timeline"),
                    isSelected: showTimeline
                ) {
                    withAnimation(.spring(response: 0.3)) { showTimeline = true }
                }
            }
        }
    }

    private func sectionLabel(_ key: LocalizedStringKey) -> some View {
        Text(key)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.white.opacity(0.7))
            .textCase(.uppercase)
            .kerning(0.5)
    }
}

struct HomeViewCard: View {
    let icon: String
    let title: LocalizedStringKey
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 26))
                    .foregroundStyle(isSelected ? .white : .white.opacity(0.55))
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(isSelected ? .white : .white.opacity(0.55))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? .white.opacity(0.22) : .white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(isSelected ? .white.opacity(0.7) : .clear, lineWidth: 1.5)
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
