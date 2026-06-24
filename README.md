# mySuite

> **Your day, in one place.**
> An all-in-one, offline-first daily productivity & wellness app built with Flutter — Notes, Medicine, Habits, Tasks, Expenses and Focus in one modular suite.

Built from the feature specification with a modern Material 3 design, Lucide
icons, light/dark theming and the spec's design tokens.

---

## ✨ What's inside

| Module | Highlights |
|---|---|
| 📝 **Notes** | Masonry note grid, pin, color, tags, full-text search, markdown body |
| 💊 **Medicine** | Course setup, **monthly schedule generator**, per-day/timeslot table, adherence %, stock run-out forecast, day-by-day dose tracking |
| ☕ **Habits** | Build/reduce goals, quick `+1` logging, streaks, GitHub-style heatmap, presets, daily-limit warnings |
| ✅ **Tasks** | Natural-language quick add (`Pay rent tomorrow #home !p1`), Today/Upcoming/Inbox/All views, priorities P1–P4, subtasks, swipe to delete |
| 💰 **Expenses** | 2-tap entry, income/expense, **bKash / Nagad / Rocket** accounts, category pie chart, monthly summary, balance |
| ⏱ **Focus** | Pomodoro / 52-17 / Deep 90 / Flow modes, animated ring timer, task linking, auto time-logging, daily goal & stats |

Plus the app-wide layer from the spec:

- **Dashboard (Today)** — live snapshot across every enabled module
- **Quick Add FAB** — log anything in ≤2 taps from one sheet
- **Global Search** — across notes, tasks, habits, medicines, expenses
- **Insights** — cross-module weekly digest + 7-day focus/spend charts
- **Settings** — theme mode, accent color, per-module enable/disable
- **Onboarding** — pick your modules on first run
- **Offline-first** — everything persists locally; no account or network required

---

## 🏗 Architecture

```
lib/
├── main.dart                 # bootstraps LocalStore + providers
├── app.dart                  # MaterialApp, theming, onboarding gate
├── core/
│   ├── theme/                # design tokens (AppColors) + Material 3 themes
│   ├── constants/            # module registry, habit/expense metadata
│   ├── storage/              # LocalStore (SharedPreferences JSON)
│   └── utils/                # date & currency formatters
├── models/                   # plain Dart models with toJson/fromJson
├── state/                    # ChangeNotifier controllers (one per module)
├── features/                 # one folder per screen/feature
└── widgets/                  # shared UI (AppCard, StatTile, EmptyState…)
```

- **State management:** `provider` + `ChangeNotifier`, one controller per module.
- **Persistence:** offline-first via `shared_preferences` (JSON per module).
  The `LocalStore` API is intentionally swappable for SQLite/Drift later.
- **Design system:** central `AppColors` tokens + `AppTheme` for light/dark,
  Lucide icons (`lucide_icons_flutter`), Inter type (`google_fonts`),
  charts via `fl_chart`.

---

## 🚀 Getting started

This repository contains the full Dart source. Generate the platform folders
(`android/`, `ios/`, …) once, then run:

```bash
# 1. Ensure Flutter is installed (stable, >= 3.27)
flutter --version

# 2. From the project root, scaffold platform folders WITHOUT touching lib/.
#    flutter create reuses the existing pubspec.yaml and lib/.
flutter create . --platforms=android,ios,web

# 3. Fetch packages
flutter pub get

# 4. Run on a device/emulator
flutter run

# Run tests
flutter test
```

> `flutter create .` only adds the missing native scaffolding; it will not
> overwrite `lib/`, `pubspec.yaml`, `test/`, or this README.

---

## 📦 Dependencies (latest stable)

- `provider` — state management
- `shared_preferences` — local persistence
- `lucide_icons_flutter` — Lucide icon set
- `google_fonts` — Inter typeface
- `fl_chart` — pie & bar charts
- `intl`, `uuid`, `collection` — utilities

---

## 🗺 Roadmap (Phase 2, per spec)

Cloud sync, OCR prescription/receipt scan, voice input, rich-text & handwriting
notes, budgets & forecasts, Kanban/Eisenhower task views, ambient sounds,
biometric lock, Bangla localization, home-screen & wearable widgets.

---

*Built with Flutter · Material 3 · offline-first.*
