import GoogleMobileAds
import UIKit

@Observable
final class AdManager: NSObject {
    private var interstitial: InterstitialAd?
    private var isLoading = false

    override init() {
        super.init()
    }

    func start() {
        loadInterstitial()
    }

    func recordCompletion() {
        let count = UserDefaults.standard.integer(forKey: "habitCompletionCount") + 1
        UserDefaults.standard.set(count, forKey: "habitCompletionCount")
        if count % AdConstants.interstitialFrequency == 0 {
            showInterstitial()
        }
    }

    private func loadInterstitial() {
        guard !isLoading else { return }
        isLoading = true
        InterstitialAd.load(
            with: AdConstants.interstitialAdUnitID,
            request: Request()
        ) { [weak self] ad, error in
            self?.isLoading = false
            if let error {
                print("[AdManager] Interstitial load error: \(error.localizedDescription)")
                return
            }
            self?.interstitial = ad
            self?.interstitial?.fullScreenContentDelegate = self
        }
    }

    private func showInterstitial() {
        guard let ad = interstitial else {
            loadInterstitial()
            return
        }
        guard
            let windowScene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
            let rootVC = windowScene.keyWindow?.rootViewController
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
