# Kindled — iOS Habit Tracker

## Project Overview

iOS habit tracker app. SwiftUI + SwiftData. Monetized via AdMob (ads) + RevenueCat (subscription, not yet live).

- **App name:** Kindled
- **Bundle:** iOS only
- **Language:** Swift, SwiftUI
- **Min target:** iOS 17+
- **Localization:** English (en), German (de)

## Architecture

No external architecture framework. Pattern is MVVM-ish:
- `@Observable` managers injected via `.environment()` in `KindledApp`
- SwiftData for persistence (`@Model` classes)
- `@AppStorage(StorageKeys.xxx)` for user preferences

### Environment-injected managers

| Manager | Injected in | Purpose |
|---------|-------------|---------|
| `AdManager` | `KindledApp` | AdMob interstitials + review prompt |
| `ConsentManager` | `KindledApp` | GDPR/ATT consent flow |
| `AchievementManager` | `ContentView` | Achievement unlock tracking |

`SubscriptionManager` exists but is a **stub** — RevenueCat not yet integrated.

### SwiftData models

```
Habit ──cascade──> HabitEntry
Habit ──cascade──> HabitReminder
```

- `HabitEntry.isCompleted` — always `true` on create; can be toggled `false` on un-complete
- **Never delete a HabitEntry to un-complete** — causes SwiftData validation error (nil properties on save). Always set `isCompleted = false` instead.

## Key Patterns

### AppStorage keys
All `@AppStorage` / `UserDefaults` keys live in `StorageKeys.swift`:
```swift
@AppStorage(StorageKeys.appTheme) private var themeRaw: String = "Purple"
```
Never use raw strings for storage keys.

### Date string lookups
`Habit.ymdFormatter` (static `DateFormatter`, format `"yyyy-MM-dd"`) and `habit.completedDateStrings` (computed `Set<String>`) are defined on `Habit`. Use them everywhere instead of local formatters:
```swift
habit.completedDateStrings.contains(Habit.ymdFormatter.string(from: date))
```

### UIKit scene access
Use `UIApplication.shared.foregroundWindowScene` (defined in `UIApplication+Extensions.swift`) everywhere UIKit needs a scene reference.

### Thread safety for manager callbacks
External SDK callbacks (AdMob, UMP) are not guaranteed to be on the main thread. Always hop:
```swift
// AdMob load callback:
DispatchQueue.main.async { [weak self] in ... }

// UMP consent callback:
Task { @MainActor [weak self] in ... }
```

### completionRate
Formula: `completedEntries / daysSinceCreation` — NOT `completedEntries / entries.count` (entries can have `isCompleted = false`).

## Dependencies (SPM)

- `firebase-ios-sdk` — FirebaseCore, FirebaseAnalytics
- `swift-package-manager-google-mobile-ads` — AdMob
- `swift-package-manager-google-user-messaging-platform` — GDPR consent (UMP)
- `purchases-ios-spm` — RevenueCat (added, not yet wired up)

## File Structure

```
Kindled/
├── KindledApp.swift          — App entry, AppDelegate, environment setup
├── ContentView.swift         — TabView, theme/language/appearance, AchievementManager
├── Models/
│   ├── Habit.swift           — @Model, streak logic, completionRate, ymdFormatter
│   ├── HabitEntry.swift      — @Model
│   ├── HabitReminder.swift   — @Model
│   ├── HabitCategory.swift   — enum (icon, color per category)
│   ├── AdConstants.swift     — AdMob unit IDs (DEBUG = test IDs), interstitialFrequency, reviewPromptThreshold
│   └── StorageKeys.swift     — All AppStorage/UserDefaults key constants
├── Managers/
│   ├── AdManager.swift       — Interstitial ads, review prompt trigger
│   ├── ConsentManager.swift  — ATT + GDPR/UMP flow
│   ├── AchievementManager.swift — Unlock logic, persist to UserDefaults
│   ├── NotificationManager.swift — Local notification scheduling
│   └── SubscriptionManager.swift — STUB, RevenueCat not integrated yet
├── Views/
│   ├── Home/                 — HomeView, HabitCard, NoteEntryView
│   ├── Detail/               — HabitDetailView, CalendarGridView, HeatmapView, HabitChartsView, NotesOverviewView
│   ├── Statistics/           — StatisticsView, OverallChartsView
│   ├── Achievements/         — AchievementsView
│   ├── AddEdit/              — AddEditHabitView, ColorPickerView, IconPickerView
│   ├── Settings/             — SettingsView, ThemePickerView, AppearancePickerView, LanguagePickerView
│   └── Onboarding/           — OnboardingView
├── Components/               — Reusable views (BannerAdView, ProgressRing, ConfettiView, AchievementBanner, StreakBadge, StatCard)
├── Extensions/
│   ├── AppTheme.swift        — AppTheme enum, ThemeColorKey environment key
│   ├── Color+Hex.swift       — Color(hex:) initializer
│   └── UIApplication+Extensions.swift — foregroundWindowScene
└── GoogleService-Info.plist  — Firebase config
```

## What's Not Done Yet

- **RevenueCat integration** — `SubscriptionManager` is empty. Need: `Purchases.configure(withAPIKey:)`, entitlement checks, paywall view, inject into environment, gate ads behind Pro
- **Privacy manifest** — `PrivacyInfo.xcprivacy` required for App Store (AdMob + Firebase + UserDefaults trigger it)
- **App Store Connect** — IAP products, screenshots, description, keywords, privacy policy URL
- **H6** — Weekly reminder weekday hardcoded to day-of-save, no user picker UI

## Known Gotchas

- `AchievementManager.idsKey`/`datesKey` must be `static` — instance constants can't be used in `init()` before `self` is available
- `bannerTask` in `HomeView` must be cancelled in `.onDisappear` to avoid mutating state on invisible view
- Heatmap cells are binary (done / not done), not 4-level intensity
- `AdConstants` in DEBUG uses Google's test IDs automatically via `#if DEBUG`
