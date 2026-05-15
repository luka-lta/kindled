<div align="center">

<img src="docs/images/app-icon.png" alt="Kindled App Icon" width="120" height="120" />

# Kindled

**Build habits. Keep the flame alive.**

[![Swift](https://img.shields.io/badge/Swift-5.9-orange?logo=swift)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-17%2B-blue?logo=apple)](https://developer.apple.com/ios/)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-%E2%9C%93-blue)](https://developer.apple.com/xcode/swiftui/)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

</div>


## Overview

Kindled is a minimal, beautiful iOS habit tracker built with SwiftUI and SwiftData. Track daily habits, visualize streaks, and stay motivated with achievements — all in a clean, themeable interface.


## Screenshots

<div align="center">

| Home | Habit Detail | Statistics | Achievements |
|:----:|:------------:|:----------:|:------------:|
| <img src="docs/images/screenshot-home.png" alt="Home screen" width="180" /> | <img src="docs/images/screenshot-detail.png" alt="Habit detail screen" width="180" /> | <img src="docs/images/screenshot-statistics.png" alt="Statistics screen" width="180" /> | <img src="docs/images/screenshot-achievements.png" alt="Achievements screen" width="180" /> |

| Add Habit | Heatmap | Settings | Onboarding |
|:---------:|:-------:|:--------:|:----------:|
| <img src="docs/images/screenshot-add.png" alt="Add habit screen" width="180" /> | <img src="docs/images/screenshot-heatmap.png" alt="Heatmap screen" width="180" /> | <img src="docs/images/screenshot-settings.png" alt="Settings screen" width="180" /> | <img src="docs/images/screenshot-onboarding.png" alt="Onboarding screen" width="180" /> |

</div>


## Features

### Core
- **Daily habit tracking** — check off habits with a single tap
- **Streak tracking** — current and longest streak per habit, never lose progress
- **Completion rate** — tracks your real completion rate since habit creation
- **Notes** — attach a note to any completed habit entry
- **Categories** — organize habits by Health, Mind, Lifestyle, and more

### Insights
- **Heatmap view** — GitHub-style activity grid for each habit
- **Charts** — weekly and monthly completion charts via Swift Charts
- **Statistics tab** — overview across all habits

### Motivation
- **Achievements** — unlock badges for streaks, completions, and consistency
- **Confetti celebrations** — milestone animations at 7, 30, and 100 day streaks

### Personalization
- **Themes** — 6 color themes (Purple, Blue, Green, Orange, Pink, Red)
- **Appearance** — Light, Dark, or System mode
- **Localization** — English and German

### Reminders
- **Local notifications** — daily or weekly reminders per habit
- **Custom times** — set reminder time per habit


## Tech Stack

| Layer | Technology |
|-------|-----------|
| Language | Swift 5.9 |
| UI Framework | SwiftUI |
| Persistence | SwiftData |
| Analytics | Firebase Analytics |
| Ads | Google AdMob |
| Consent | Google UMP (GDPR) |
| Subscriptions | RevenueCat *(in progress)* |
| Min Target | iOS 17 |


## Architecture

MVVM-ish pattern with `@Observable` managers injected via SwiftUI environment.

```text
KindledApp
├── ConsentManager      — GDPR/ATT consent flow
├── AdManager           — AdMob interstitials + review prompts
└── ContentView (TabView)
    ├── AchievementManager
    ├── HomeView
    ├── StatisticsView
    ├── AchievementsView
    └── SettingsView
```

**Data model:**

```text
Habit ──cascade──> HabitEntry
Habit ──cascade──> HabitReminder
```


## Project Structure

```text
Kindled/
├── KindledApp.swift
├── ContentView.swift
├── Models/
│   ├── Habit.swift
│   ├── HabitEntry.swift
│   ├── HabitReminder.swift
│   ├── HabitCategory.swift
│   ├── AdConstants.swift
│   └── StorageKeys.swift
├── Managers/
│   ├── AdManager.swift
│   ├── ConsentManager.swift
│   ├── AchievementManager.swift
│   ├── NotificationManager.swift
│   └── SubscriptionManager.swift
├── Views/
│   ├── Home/
│   ├── Detail/
│   ├── Statistics/
│   ├── Achievements/
│   ├── AddEdit/
│   ├── Settings/
│   └── Onboarding/
├── Components/
└── Extensions/
```


## Requirements

- Xcode 15+
- iOS 17+
- Swift 5.9+
- A `GoogleService-Info.plist` (Firebase) — not included in repo


## Getting Started

1. Clone the repo
   ```bash
   git clone https://github.com/luka-lta/kindled.git
   cd kindled
   ```

2. Open `Kindled.xcodeproj` in Xcode

3. Add your own `GoogleService-Info.plist` to `Kindled/` (required for Firebase)

4. Select your simulator or device and hit **Run**

> AdMob uses Google's test ad unit IDs automatically in `DEBUG` builds — no real ads shown during development.


## License

MIT — see [LICENSE](LICENSE) for details.


<div align="center">

Made with ♥ by [luka-lta](https://github.com/luka-lta)

</div>
