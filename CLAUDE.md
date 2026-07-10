# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Flutter app ("Loop") for interview-skills practice/tracking. Firebase-backed, currently uses mock repositories for all data.

## Commands

```bash
flutter pub get                 # install dependencies
flutter run                     # run app (choose device)
flutter analyze                 # lint (flutter_lints + analysis_options.yaml)
flutter test                    # run all tests
flutter test test/widget_test.dart   # run a single test file
```

There's no CI config in this repo — `flutter analyze` and `flutter test` are the local checks to run before considering a change done.

## Architecture

Feature-first, clean-architecture layering under `lib/features/<feature>/`:

```
domain/entities/       plain Dart data classes
domain/repositories/   abstract repository interfaces
domain/usecases/       single-method classes (e.g. GetLoopTracks) that call the repository
data/repositories/     Mock*Repository implementations of the domain interface
presentation/cubit/    flutter_bloc Cubit + State per feature
presentation/          screens/widgets
```

Every feature (`cv_analysis`, `home_dashboard`, `loops`, `profile`, `recap`, `roadmap`, `interview_call`, `onboarding`) follows this pattern. `interview_call` and `onboarding` are presentation-only (no data/domain layers yet). All repositories are `Mock*Repository` classes returning hardcoded data — there is no real backend integration yet even though Firebase is wired into the project (`firebase_core`, `firebase_options.dart`).

Wiring happens in `lib/main.dart`: `MultiRepositoryProvider` constructs each `Mock*Repository`, then `MultiBlocProvider` constructs each Cubit from its usecase + repository (via `context.read`). New features should follow this same registration pattern in `main.dart`.

`lib/core/` holds cross-cutting pieces:
- `navigation/app_router.dart` — single `GoRouter` instance (`appRouter`). Routes inside `ShellRoute` (`/`, `/loops`, `/cv`, `/roadmap`) render inside `AppShell` (bottom nav). Auth/standalone routes (`/welcome`, `/login`, `/register`, `/forgot-password`, `/profile`, `/interview`, `/recap`) sit outside the shell. Custom `CustomTransitionPage` builders (`_instantPage`, `_navPage`, `_callPage`, `_recapPage`) define per-route transition styling — reuse the matching one rather than inventing a new transition.
- `settings/cubit/` — global `SettingsCubit`/`SettingsState` holds theme mode and `AppLanguage` (spanish/english), read via `BlocProvider` at the app root.
- `localization/app_strings.dart` — **not** using Flutter's gen-l10n/arb files. All copy lives in `AppStrings`, a single class with one getter/method per string, each branching on `language == AppLanguage.spanish` via a `_es` bool. `AppStrings.of(context)` reads the current language from `SettingsCubit` reactively. Add new copy here rather than introducing another localization mechanism.
- `theme/` — `LoopTheme.light` / `LoopTheme.dark` (used as `MaterialApp.router.theme`/`darkTheme`) and `loop_colors.dart` for the app's color palette.
- `widgets/` — shared presentational widgets (`LoopCard`, `DeltaBadge`, `MetricProgressBar`, `LevelCircle`, `SectionHeader`, `LoopBreathingMark`) used across feature screens.

State management is `flutter_bloc` Cubits exclusively (no raw `setState`-based feature state, no Provider/Riverpod). Routing is `go_router` exclusively.
