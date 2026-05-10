import SwiftUI

struct OnboardingPage {
    let icon: String
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    let features: [LocalizedStringKey]
    let gradient: [Color]
}

private let onboardingPages: [OnboardingPage] = [
    OnboardingPage(
        icon: "checkmark.circle.fill",
        title: "Build Better Habits",
        subtitle: "Small daily actions compound into extraordinary results over time.",
        features: ["Track any habit", "Daily reminders", "Beautiful progress"],
        gradient: [Color(red: 0.42, green: 0.39, blue: 1.0), Color(red: 0.62, green: 0.35, blue: 0.95)]
    ),
    OnboardingPage(
        icon: "flame.fill",
        title: "Build Your Streak",
        subtitle: "Complete habits daily to grow your streak. Consistency is everything.",
        features: ["🔥 7 days — Habit forming", "🏆 30 days — Locked in", "⭐ 100 days — Unstoppable"],
        gradient: [Color(red: 1.0, green: 0.42, blue: 0.18), Color(red: 1.0, green: 0.65, blue: 0.05)]
    ),
    OnboardingPage(
        icon: "chart.bar.fill",
        title: "See Your Progress",
        subtitle: "Year-at-a-glance heatmap, stats, and streak leaderboard keep you motivated.",
        features: ["Yearly heatmap", "Completion stats", "Confetti milestones 🎉"],
        gradient: [Color(red: 0.12, green: 0.72, blue: 0.48), Color(red: 0.08, green: 0.55, blue: 0.70)]
    )
]

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("userName") private var savedUserName: String = ""
    @State private var currentPage = 0
    @State private var nameInput: String = ""

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $currentPage) {
                ForEach(Array(onboardingPages.enumerated()), id: \.offset) { index, page in
                    OnboardingPageView(page: page)
                        .tag(index)
                }
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
    }

    private var pageDots: some View {
        HStack(spacing: 8) {
            ForEach(0..<onboardingPages.count, id: \.self) { index in
                Capsule()
                    .fill(currentPage == index ? Color.white : Color.white.opacity(0.35))
                    .frame(width: currentPage == index ? 28 : 8, height: 8)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
            }
        }
    }

    private var actionButton: some View {
        let isLast = currentPage == onboardingPages.count - 1
        let page = onboardingPages[currentPage]
        let buttonColor = page.gradient.first ?? .purple

        return VStack(spacing: 12) {
            if isLast {
                TextField("Your name (optional)", text: $nameInput)
                    .font(.system(size: 16))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(.white.opacity(0.2), in: RoundedRectangle(cornerRadius: 14))
                    .foregroundStyle(.white)
                    .tint(.white)
                    .submitLabel(.done)
            }

            Button {
                if isLast {
                    savedUserName = nameInput.trimmingCharacters(in: .whitespaces)
                    hasSeenOnboarding = true
                } else {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        currentPage += 1
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Text(isLast ? LocalizedStringKey("Get Started") : "Next")
                        .font(.system(size: 17, weight: .bold))
                    if !isLast {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 15, weight: .bold))
                    } else {
                        Image(systemName: "checkmark")
                            .font(.system(size: 15, weight: .bold))
                    }
                }
                .foregroundStyle(buttonColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(.white, in: RoundedRectangle(cornerRadius: 18))
            }
            .buttonStyle(ScaleButtonStyle())
        }
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var appeared = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: page.gradient,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Decorative background circles
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

                // Icon
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.12))
                        .frame(width: 170, height: 170)
                    Circle()
                        .fill(.white.opacity(0.12))
                        .frame(width: 130, height: 130)
                    Image(systemName: page.icon)
                        .font(.system(size: 68))
                        .foregroundStyle(.white)
                }
                .scaleEffect(appeared ? 1.0 : 0.7)
                .opacity(appeared ? 1.0 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.65).delay(0.1), value: appeared)

                Spacer().frame(height: 44)

                // Title + subtitle
                VStack(spacing: 14) {
                    Text(page.title)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    Text(page.subtitle)
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 12)
                }
                .offset(y: appeared ? 0 : 20)
                .opacity(appeared ? 1.0 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.2), value: appeared)

                Spacer().frame(height: 36)

                // Feature list
                VStack(spacing: 12) {
                    ForEach(Array(page.features.enumerated()), id: \.offset) { index, feature in
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 18))
                                .foregroundStyle(.white.opacity(0.9))
                            Text(feature)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.white.opacity(0.9))
                            Spacer()
                        }
                        .padding(.horizontal, 28)
                        .offset(y: appeared ? 0 : 16)
                        .opacity(appeared ? 1.0 : 0)
                        .animation(
                            .spring(response: 0.5, dampingFraction: 0.7)
                                .delay(0.3 + Double(index) * 0.08),
                            value: appeared
                        )
                    }
                }

                Spacer()
                Spacer()
            }
        }
        .onAppear {
            appeared = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                appeared = true
            }
        }
        .onDisappear { appeared = false }
    }
}
