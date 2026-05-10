enum AdConstants {
    // Replace with real IDs before App Store submission
    #if DEBUG
    static let appID             = "ca-app-pub-3940256099942544~1458002511"
    static let bannerAdUnitID    = "ca-app-pub-3940256099942544/2934735716"
    static let interstitialAdUnitID = "ca-app-pub-3940256099942544/4411468910"
    #else
    static let appID             = "ca-app-pub-3346959869225055~3848694363"
    static let bannerAdUnitID    = "ca-app-pub-3346959869225055/6304751171"
    static let interstitialAdUnitID = "ca-app-pub-3346959869225055/3124209594"
    #endif

    static let interstitialFrequency = 5
    static let reviewPromptThreshold = 10
}
