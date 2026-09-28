# AGENTS.md — project memory for AI sessions

Read this first. It captures context an assistant would otherwise rediscover and burn tokens on.
See `ROADMAP.md` for what is done/next vs. this file's "current state".

## Project

Modern port of a legacy Java Swing Davao jeepney fare app to Flutter. App `DavaoFare Guide`
computes a fare between two stops on a fixed route. Do **not** modify anything under `Old/`
(legacy Java source, kept for reference).

- Structure: `app/` (entry), `core/` (utils, money), `data/` (Drift DB, DAOs, repos, providers,
  models), `features/` (home, fare_calculator, route_lookup), `assets/routes/*.txt` (69 route
  files: `Stop Name,kmIndex` per line).
- Stack: Flutter 3.47.1, Dart 3.13.1, Riverpod, Drift + SQLite, GoRouter.
- `applicationId` `ph.davaojeepney.davao_jeepney`, version 1.0.0+1.
- `Money` wraps an **integer centavo** count (`Money(1400)` = ₱14.00) to avoid float errors.
  `percentFrom` and `percentOff` both use `~/` integer math.

## Current fare spec (user-owned truth)

- `FareRules` in `lib/core/utils/fare_calculator.dart`:
  `baseFare = Money(1400)` (₱14.00, first 4 km), `perKilometer = Money(200)` (₱2.00/km past
  4 km), `discountPercent = 20` (student/senior/pwd get 20% off the **total**).
- Zero distance = ₱0, **no discount**.
- Discount math: `total = baseFare + distanceCharge`, then
  `deduction = total.percentOff(rules.discountPercent)`,
  `paid = total - deduction`. The **deduction is the amount saved** (20% of total, shown as
  `−20% discount`), NOT the paid price.
- The old `discountedCategoryDeduction` field is **gone**. Do not reintroduce it. The old fare
  (₱13 base + ₱1.50/km − ₱2 flat) is obsolete; the `LegacyAlgo` parity tests were deleted.

## Key invariants / gotchas

- **Do not hardcode or curate popularity list.** "Most popular routes" on the home screen is
  derived from per-route `usageCount` + `lastUsedAt` (Drift `JeepneyRoutes` schema v2,
  `RouteDao.recordUsage` / `getPopularRoutes`). Trigger: `ref.listen` in the fare calculator
  fires `recordRouteUsage` when a selection becomes complete.
- Route data has **no coordinates** — stops are `name` + integer `kmIndex` (cumulative km).
  The diagram is a schematic CustomPainter, not a geo map. All 69 files are strictly monotonic.
- **Selection bug fix**: `stop_picker_sheet.dart` sets
  `constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.75)` —
  `BoxConstraints.maxHeight` takes **pixels, not a fraction**. Don't "fix" it back to `0.75`.
- Emulator on this host: AVD `Pixel_4a` persistently uses `hw.gpu.mode=software` (Mesa
  `lavapipe`) in `~/.android/avd/Pixel_4a.avd/config.ini` (backup `config.ini.bak`) because
  `swiftshader_indirect` crashes. It boots in ~18s. Do **not** set `QT_QPA_PLATFORM=xcb`.
- Android Studio must be **closed** during emulator work (it respawns emulators / stale locks).
  Clear stale locks from `~/.android/avd/Pixel_4a.avd/*.lock` and `/run/user/1000/avd/running/`.
- Open work the user may re-point you at: on-device selection persistence after the picker
  closes (`[PICK]` debug logs were added; `autoDispose` of `fareSelectionProvider` is suspect).

## Commands (from repo root)

```bash
flutter analyze
flutter test
flutter build apk --release          # output: build/app/outputs/flutter-apk/app-release.apk
flutter test test/core/utils/fare_calculator_test.dart
flutter test test/data/route_and_fare_test.dart
```

Host is tight on disk (~96% full); Gradle/emulator are slower than usual.

## Fare test expectations (update together with `FareRules`)

`test/core/utils/fare_calculator_test.dart`: 10 km regular total `Money(2600)`, 10 km
discounted `Money(2080)` (saves `Money(520)`); ≤4 km `Money(1400)` / discounted `Money(1120)`
(saves `Money(280)`).
`test/data/route_and_fare_test.dart` (5 km Matina Bankerohan→Agdao): regular `Money(1600)`,
discounted `Money(1280)`, saving `Money(320)`; end-to-end closeTo `16.0` / `12.8`.

## State of the world (what a fresh session should assume)

- 41 tests passing, `flutter analyze` clean, release APK built (57.7 MB, **unsigned**).
- Wiring lives in `data/providers/route_providers.dart`, `data/repositories/route_repository.dart`,
  screen `features/fare_calculator/presentation/screens/fare_calculator_screen.dart`,
  widgets `stop_picker_sheet.dart`, `route_diagram.dart`, `fare_estimate_card.dart`,
  home `features/home/presentation/screens/home_screen.dart`.
- Docs: `README.md`, `ROADMAP.md` (incl. planned fare/distance-precision work), `ARCHITECTURE.md`.