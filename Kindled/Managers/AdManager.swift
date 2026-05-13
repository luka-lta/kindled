import GoogleMobileAds
import StoreKit
import UIKit

@Observable
final class AdManager: NSObject {
    private var interstitial: InterstitialAd?
    private var isLoading = false

    func start() {
        loadInterstitial()
    }

    func recordCompletion(isProUnlocked: Bool = false) {
        let count = UserDefaults.standard.integer(forKey: StorageKeys.adCompletionCount) + 1
        UserDefaults.standard.set(count, forKey: StorageKeys.adCompletionCount)
        if !isProUnlocked, count % AdConstants.interstitialFrequency == 0 {
            showInterstitial()
        }
        if count >= AdConstants.reviewPromptThreshold,
           !UserDefaults.standard.bool(forKey: StorageKeys.reviewRequested) {
            requestReview()
            UserDefaults.standard.set(true, forKey: StorageKeys.reviewRequested)
        }
    }

    func requestReviewAtMilestone(_ streak: Int) {
        var usedMilestones = reviewMilestonesUsed()
        guard !usedMilestones.contains(streak) else { return }
        usedMilestones.insert(streak)
        saveReviewMilestonesUsed(usedMilestones)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.requestReview()
        }
    }

    private func reviewMilestonesUsed() -> Set<Int> {
        let stored = UserDefaults.standard.string(forKey: StorageKeys.reviewRequestedMilestones) ?? ""
        return Set(stored.split(separator: ",").compactMap { Int($0) })
    }

    private func saveReviewMilestonesUsed(_ milestones: Set<Int>) {
        let str = milestones.map(String.init).joined(separator: ",")
        UserDefaults.standard.set(str, forKey: StorageKeys.reviewRequestedMilestones)
    }

    private func requestReview() {
        guard let scene = UIApplication.shared.foregroundWindowScene else { return }
        AppStore.requestReview(in: scene)
    }

    private func loadInterstitial() {
        guard !isLoading else { return }
        isLoading = true
        InterstitialAd.load(
            with: AdConstants.interstitialAdUnitID,
            request: Request()
        ) { [weak self] ad, error in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.isLoading = false
                if let error {
                    print("[AdManager] Interstitial load error: \(error.localizedDescription)")
                    return
                }
                self.interstitial = ad
                self.interstitial?.fullScreenContentDelegate = self
            }
        }
    }

    private func showInterstitial() {
        guard let ad = interstitial else {
            loadInterstitial()
            return
        }
        guard
            let scene = UIApplication.shared.foregroundWindowScene,
            let rootVC = scene.keyWindow?.rootViewController
        else { return }
        ad.present(from: rootVC)
    }
}

extension AdManager: FullScreenContentDelegate {
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        interstitial = nil
        loadInterstitial()
    }

    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        interstitial = nil
        loadInterstitial()
    }
}
