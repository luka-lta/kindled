import AppTrackingTransparency
import GoogleMobileAds
import UserMessagingPlatform // from GoogleUserMessagingPlatform package

@Observable
@MainActor
final class ConsentManager {
    var canShowAds = false

    func requestConsentAndStart(then completion: @escaping () -> Void) {
        gatherConsent {
            self.requestATT {
                MobileAds.shared.start()
                self.canShowAds = true
                completion()
            }
        }
    }

    private func gatherConsent(then completion: @escaping () -> Void) {
        let params = UMPRequestParameters()
        params.tagForUnderAgeOfConsent = false

        UMPConsentInformation.sharedInstance.requestConsentInfoUpdate(with: params) { [weak self] _ in
            guard let self else { completion(); return }
            self.presentFormIfNeeded(then: completion)
        }
    }

    private func presentFormIfNeeded(then completion: @escaping () -> Void) {
        guard
            let scene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
            let root = scene.keyWindow?.rootViewController
        else {
            completion()
            return
        }
        UMPConsentForm.loadAndPresentIfRequired(from: root) { _ in completion() }
    }

    private func requestATT(then completion: @escaping () -> Void) {
        guard ATTrackingManager.trackingAuthorizationStatus == .notDetermined else {
            completion()
            return
        }
        ATTrackingManager.requestTrackingAuthorization { _ in
            DispatchQueue.main.async { completion() }
        }
    }
}
