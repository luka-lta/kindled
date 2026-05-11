import SwiftUI

struct ProLockedView<Content: View>: View {
    @Environment(SubscriptionManager.self) private var subscriptionManager
    let title: LocalizedStringKey
    let content: () -> Content
    @State private var showPaywall = false

    init(title: LocalizedStringKey, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }

    var body: some View {
        if subscriptionManager.isProUnlocked {
            content()
        } else {
            content()
                .blur(radius: 8)
                .overlay { lockOverlay }
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .contentShape(RoundedRectangle(cornerRadius: 20))
                .onTapGesture { showPaywall = true }
                .sheet(isPresented: $showPaywall) {
                    KindledPaywallView()
                }
        }
    }

    private var lockOverlay: some View {
        VStack(spacing: 12) {
            Image(systemName: "lock.fill")
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(.white)
            Text(title)
                .font(.subheadline.bold())
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            Button("Unlock Pro") {
                showPaywall = true
            }
            .buttonStyle(.borderedProminent)
            .tint(.purple)
            .controlSize(.small)
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
}
