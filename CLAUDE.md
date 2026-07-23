# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Flutter app ("Loop") for interview-skills practice/tracking. Firebase-backed (Auth + Firestore) with a live, voice-driven mock-interview call powered by the Gemini Live API.

## Commands

```bash
flutter pub get                          # install dependencies
flutter run                              # run app (choose device)
flutter analyze                          # lint (flutter_lints + analysis_options.yaml)
flutter test                             # run all tests
flutter test test/widget_test.dart       # run a single test file
node scripts/seed_roadmap_catalog.mjs    # seed the roadmap_catalog Firestore collection
```

There's no CI config in this repo — `flutter analyze` and `flutter test` are the local checks to run before considering a change done.

The Gemini API key is required at runtime (CV analysis, roadmap generation, interview calls). It resolves via `lib/core/config/app_env.dart`: `--dart-define=GEMINI_API_KEY=...` first, falling back to a bundled `env.json` asset (see `env.example.json` for the shape). `env.json` is gitignored; copy `env.example.json` to `env.json` and fill in a key before running locally.

## Architecture

Feature-first, clean-architecture layering under `lib/features/<feature>/`:

```
domain/entities/       plain Dart data classes
domain/repositories/   abstract repository interfaces
domain/usecases/       single-method classes (e.g. GetLoopTracks) that call the repository
data/repositories/     Firestore*Repository / Firebase*Repository implementations of the domain interface
data/services/         feature-specific service classes (Gemini calls, audio I/O, etc.)
presentation/cubit/    flutter_bloc Cubit + State per feature
presentation/          screens/widgets
```

Features: `auth`, `cv_analysis`, `home_dashboard`, `loops`, `profile`, `recap`, `roadmap`, `interview_call`, `onboarding`, `splash`. `interview_call`, `onboarding`, and `splash` are presentation-heavy (mainly services/cubits rather than full repository layers). All repositories are real Firebase implementations — `Firestore*Repository` for Firestore-backed data, `firebase_auth_repository.dart` for auth. There are no more mock repositories.

Wiring happens in `lib/main.dart`: `MultiRepositoryProvider` constructs each repository, then `MultiBlocProvider` constructs each Cubit from its usecase + repository (via `context.read`). New features should follow this same registration pattern in `main.dart`.

### Startup flow

`lib/main.dart`'s `main()` loads env config and settings, then runs `LoopBootstrap` (`lib/core/bootstrap/loop_bootstrap.dart`) *before* `LoopApp`. Bootstrap checks connectivity (`core/connectivity/connectivity_service.dart`) and shows `NoConnectionScreen` if offline, then lazily calls `Firebase.initializeApp` once a connection is confirmed, showing a retry screen on failure. Only after Firebase is ready does it hand off to `LoopApp`, which builds the actual `MaterialApp.router`.

### Routing & auth guarding

`lib/core/navigation/app_router.dart` builds the single `GoRouter` (`AppRouter`, constructed with `authRepository` + `profileRepository`). Its `redirect` callback:
- Sends unauthenticated or unverified-email users to `/welcome` or `/login`.
- Sends authenticated users whose profile isn't complete (checked via `profileRepository.isProfileComplete()`) to `/google-onboarding`, and blocks completed profiles from re-entering onboarding/auth routes.
- Uses `GoRouterRefreshStream` wrapping `authRepository.authStateChanges()` so route guarding re-runs on auth state changes.

Auth/onboarding routes (`/welcome`, `/login`, `/forgot-password`, `/register`, `/google-onboarding`) sit outside the shell. Routes inside `ShellRoute` (`/`, `/loops`, `/cv`, `/roadmap`) render inside `AppShell` (bottom nav). Other standalone routes: `/loops/create`, `/roadmap/lesson/:stepId`, `/profile`, `/interview`, `/recap`. Custom `CustomTransitionPage` builders (`_instantPage`, `_navPage`, `_callPage`, `_recapPage`) define per-route transition styling — reuse the matching one rather than inventing a new transition.

### Interview call (Gemini Live)

`features/interview_call/data/services/` holds the pieces that drive a live mock interview: `gemini_live_service.dart` (WebSocket session to the Gemini Live API, config in `gemini_config.dart`), `audio_service.dart` (mic capture + PCM playback via `record`/`flutter_pcm_sound`), `interview_prompt.dart` (system prompt construction), `interview_session_end.dart` and `interview_report_service.dart` (turning a finished session into a stored report/recap). The `/interview` route feeds into `/recap` after a call ends.

### Roadmap catalog

Roadmap lessons/quizzes are predefined per career goal in Firestore's `roadmap_catalog` collection (JSON source files under `scripts/roadmap_catalog/`, seeded via `scripts/seed_roadmap_catalog.mjs`); `roadmap_service.dart` combines catalog content with AI-driven customization, and the final step of a roadmap is always a call into `interview_call`.

### Cross-cutting (`lib/core/`)

- `bootstrap/` — `LoopBootstrap`, see Startup flow above.
- `config/app_env.dart` — resolves `GEMINI_API_KEY` (see Commands).
- `connectivity/` — `ConnectivityService` + `NoConnectionScreen`, used by bootstrap and available to re-check connectivity anywhere.
- `services/gemini_json_client.dart` — shared helper for calling Gemini with JSON-structured responses (used by CV analysis, roadmap generation).
- `navigation/app_router.dart` — see Routing & auth guarding above.
- `settings/cubit/` — global `SettingsCubit`/`SettingsState` holds theme mode and `AppLanguage` (spanish/english), read via `BlocProvider` at the app root.
- `localization/app_strings.dart` — **not** using Flutter's gen-l10n/arb files. All copy lives in `AppStrings`, a single class with one getter/method per string, each branching on `language == AppLanguage.spanish` via a `_es` bool. `AppStrings.of(context)` reads the current language from `SettingsCubit` reactively. Add new copy here rather than introducing another localization mechanism.
- `theme/` — `LoopTheme.light` / `LoopTheme.dark` (used as `MaterialApp.router.theme`/`darkTheme`) and `loop_colors.dart` for the app's color palette.
- `utils/` — small standalone helpers (e.g. `streak_calculator.dart`), tested directly under `test/`.
- `widgets/` — shared presentational widgets (`LoopCard`, `DeltaBadge`, `MetricProgressBar`, `LevelCircle`, `SectionHeader`, `LoopBreathingMark`) used across feature screens.

State management is `flutter_bloc` Cubits exclusively (no raw `setState`-based feature state, no Provider/Riverpod). Routing is `go_router` exclusively.

## Testing

Repository-layer tests use hand-written fakes (`test/fakes/fake_auth_repository.dart`, `fake_profile_repository.dart`) rather than a mocking framework — follow that pattern for new fakes. Service-level tests (`cv_analysis_service_test.dart`, `gemini_live_service_test.dart`, `roadmap_service_test.dart`, `roadmap_catalog_test.dart`) exercise the `data/services/` layer directly.
