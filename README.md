# Verda — Expense Tracker

A premium, offline-first expense manager for **Android and iOS**, built with Flutter. Original branding and UI — green fintech accent, floating cards, glassmorphism, light/dark themes, and full English + Hindi localization.

## Feature highlights

- **Authentication** — splash, 3-page onboarding, register/login (local mock, keychain-backed), forgot password + placeholder OTP (`123456`), biometric login (Face ID / fingerprint), optional app lock.
- **Dashboard** — total balance, today's/monthly spending, budget progress, quick-add categories, 7-day chart preview, savings overview, upcoming bills, recent expenses.
- **Expenses** — full CRUD with title, amount, category, date, time, payment method, notes, tags, currency, location and **multiple receipt images** (camera or gallery, stored in app-private storage). Search (`#tag` supported), filters (category, date presets + custom range, amount range, type) and sorting.
- **Categories** — 13 localized defaults plus user categories with icon & color pickers. Deleting a category safely reassigns its expenses to *Other*.
- **Analytics** — animated pie, weekly bars, monthly/yearly lines, income vs expense, budget comparison and a GitHub-style spending heatmap.
- **Budgets** — overall + per-category monthly budgets with progress bars and local notifications at 80% and on overspend.
- **Bills** — recurring bills (weekly/monthly/yearly/one-time) with due chips, "mark paid" roll-forward and day-before reminders.
- **Reports** — monthly/annual/category reports exported as **PDF, CSV or Excel** and shared via the system share sheet.
- **Settings** — language (English/हिन्दी, live switch, no restart), theme, currency, notification toggles + reminder time, JSON backup/restore, app lock, privacy/about/feedback, clear-all-data, logout.
- **Offline-first** — everything lives in a local Drift (SQLite) database; repository interfaces are storage-agnostic so Firebase/Supabase sync can be added without touching the UI.

## Tech stack

| Concern | Choice |
| --- | --- |
| State management | Riverpod 3 (`Notifier`, `StreamProvider`, derived providers) |
| Navigation | GoRouter (`StatefulShellRoute` bottom navigation) |
| Database | Drift (SQLite) via `drift_flutter` |
| Models | Freezed + json_serializable |
| Charts | fl_chart |
| Localization | Flutter gen-l10n (ARB), English + Hindi, RTL-ready |
| Theming | Material 3, dynamic color (Material You), Cupertino adaptations on iOS |
| Notifications | flutter_local_notifications + timezone |
| Security | flutter_secure_storage, local_auth |
| Media | image_picker (camera + gallery) |
| Reports | pdf, csv, excel, share_plus |
| Responsive | responsive_framework + adaptive layouts (NavigationRail on tablets) |

## Architecture

Clean Architecture / MVVM with the repository pattern:

```
lib/
 ├── core/            # theme, router, database, services, utils, l10n glue
 ├── features/
 │    ├── authentication/   # data (secure-storage repo) + presentation
 │    ├── dashboard/
 │    ├── expenses/         # domain (entities, repo contracts) / data / presentation
 │    ├── analytics/        # pure aggregation math + chart screens
 │    ├── budgets/
 │    ├── bills/
 │    ├── reports/
 │    ├── settings/
 │    └── profile/
 ├── shared/          # reusable widgets, providers, display helpers
 └── main.dart
```

- **domain/** — immutable Freezed entities and abstract repository interfaces (no Flutter/storage imports).
- **data/** — Drift implementations mapping rows ⇄ entities.
- **presentation/** — Riverpod providers + screens/widgets.

## Getting started

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # drift/freezed codegen
flutter gen-l10n                                           # runs automatically on build too
flutter run
```

Requires Flutter 3.44+ / Dart 3.12+. Open in Android Studio, VS Code, or Xcode (`ios/Runner.xcworkspace`).

- **Demo data**: the first launch seeds ~3 months of deterministic dummy expenses, budgets and bills so every screen has content. Use *Settings → Clear all data* for a clean slate.
- **Demo OTP**: `123456`.
- **Tests**: `flutter test` covers formatters, date ranges, search/filter/sort logic, analytics math, budget/bill rules, Drift repositories (in-memory) and backup round-trips.

## Platform notes

- **Android** — Material 3 + dynamic color, edge-to-edge UI, notification channels, boot-persistent reminders, `FlutterFragmentActivity` for biometrics, core-library desugaring enabled, targets Android 14+.
- **iOS** — Cupertino page transitions, date/time pickers and dialogs, haptic feedback, Face ID (`NSFaceIDUsageDescription`), camera/photo permission strings, safe-area aware everywhere.

## Future-ready seams

- `ExpenseRepository` & friends are interfaces → swap in a synced remote implementation (Firebase/Supabase).
- Versioned JSON backup format doubles as a sync payload.
- Receipt storage is isolated behind the expense form → OCR pipeline can hook in later.
- `dio` is wired in dependencies for upcoming network features.

## Known limitations

- Authentication is an offline mock (single local account); OTP and password reset are placeholders.
- PDF export uses ASCII currency codes (the built-in PDF fonts lack ₹/Devanagari glyphs); bundle a Noto font to render Hindi reports.
