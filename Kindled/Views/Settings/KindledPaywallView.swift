import SwiftUI
import RevenueCatUI

struct KindledPaywallView: View {
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        PaywallView(displayCloseButton: true)
            .onPurchaseCompleted { customerInfo in
                subscriptionManager.handleCustomerInfo(customerInfo)
                Task {
                    await subscriptionManager.refreshEntitlement()
                    dismiss()
                }
            }
            .onRestoreCompleted { customerInfo in
                subscriptionManager.handleCustomerInfo(customerInfo)
                Task {
                    await subscriptionManager.refreshEntitlement()
                    if subscriptionManager.isProUnlocked { dismiss() }
                }
            }
    }
}
