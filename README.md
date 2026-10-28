# The Coaches Notepad — Flutter app (navy blue theme)

A real Flutter app implementing the 6 screens from the navy-blue design prompt: **Dashboard, Sessions, Reflect, Progress, Session Builder, and Session Detail & Reflection**. It runs on sample data ("Jamie" the coach) so it's fully browsable without a backend — the next step is wiring it to Supabase using the schema started separately for this project.

## Running it

This was written in a sandboxed environment with no network access to Google's package servers, so it could not be compiled or run here — see "How this was verified" below. To run it yourself:

```bash
flutter pub get
flutter run            # any connected device/emulator
flutter run -d chrome  # or in a browser
```

Requires Flutter 3.19+ (Dart 3.3+), which covers any current Flutter install.

## What's here

```
lib/
  main.dart                     # app entry point, dark navy theme
  theme/app_theme.dart          # navy blue palette + ThemeData
  models/                       # Session, Reflection, Player, ReflectionStatus
  data/sample_data.dart         # hardcoded sample data matching the screenshots
  widgets/                      # StatCard, StatusBadge, StarRating, charts, pitch diagram
  screens/
    home_shell.dart             # bottom-nav shell (Dashboard/Sessions/Reflect/Progress)
    dashboard_screen.dart
    sessions_screen.dart
    reflect_screen.dart
    progress_screen.dart
    session_builder_screen.dart
    session_detail_screen.dart
```

Charts (session rating line chart, mood distribution bar chart) are hand-drawn with `CustomPainter` rather than an external package, so there's nothing extra to resolve from pub.dev beyond Flutter itself.

## What's not wired up yet

This is the UI layer only, on sample data:

- No Supabase auth, database, or storage calls yet — buttons like "Save as Planned" and "Log Reflection" show a demo confirmation instead of writing anywhere.
- No Stripe billing, no OneSignal push notifications, no offline sync — all out of scope for this pass.
- Player availability, drill library browsing, PDF export, and the onboarding flow aren't built yet.

Natural next step: connect it to the Supabase schema (tables for sessions, session_sections, drills, reflections, players, player_observations) so the sample data is replaced by real per-coach data.

## How this was verified

The sandbox this was built in blocks all Google-hosted download endpoints (`storage.googleapis.com`, `dl.google.com`, `pub.dev`), which is where Flutter fetches its bundled Dart SDK/engine from on first run — so `flutter pub get`, `flutter analyze`, and `flutter build` could not actually be executed here. Cloning the Flutter SDK itself from GitHub worked, but it couldn't be made runnable without those blocked hosts.

In place of that, every file was checked by hand plus a couple of scripted passes: a bracket/brace/paren balance check across all 21 files, and a cross-reference of every `AppColors.*` and `SampleData.*` call site against its definition. No fewer risky or version-sensitive APIs were used than necessary (e.g. hand-rolled charts instead of a pub package with an unverifiable version; `withOpacity` instead of the newer `withValues` for broader SDK compatibility).

None of that replaces an actual `flutter analyze` — please run it once you have the file locally; if anything surfaces, it should be minor given the above.
