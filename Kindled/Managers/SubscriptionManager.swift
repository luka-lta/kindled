import RevenueCat
import Foundation

@Observable
final class SubscriptionManager {
    private(set) var isProUnlocked = false

    static var entitlementID: String {
        #if DEBUG
        return "Kindled Pro"
        #else
        return "kindled_pro"
        #endif
    }

    private static var apiKey: String {
        #if DEBUG
        return Bundle.main.object(forInfoDictionaryKey: "RevenueCatTestAPIKey") as? String ?? ""
        #else
        return Bundle.main.object(forInfoDictionaryKey: "RevenueCatAPIKey") as? String ?? ""
        #endif
    }

    func configure() {
        Purchases.logLevel = .error
        Purchases.configure(withAPIKey: Self.apiKey)
        Task { @MainActor in
            await refreshEntitlement()
        }
    }

    func refreshEntitlement() async {
        do {
            let info = try await Purchases.shared.customerInfo()
            isProUnlocked = info.entitlements[Self.entitlementID]?.isActive == true
        } catch {
            print("[SubscriptionManager] entitlement check failed: \(error)")
        }
    }

    func handleCustomerInfo(_ info: CustomerInfo) {
        Task { @MainActor in
            isProUnlocked = info.entitlements[Self.entitlementID]?.isActive == true
            if !isProUnlocked {
                await refreshEntitlement()
            }
        }
    }
}
