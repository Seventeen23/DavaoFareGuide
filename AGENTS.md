# AGENTS.md — project memory for AI sessions

Read this first. It captures context an assistant would otherwise rediscover and burn tokens on.
See `ROADMAP.md` for what is done/next vs. this file's "current state".

## Project

Modern port of a legacy Java Swing Davao jeepney fare app to Flutter. App `DavaoFare Guide`
computes a fare between two stops on a fixed route. Do **not** modify anything under `Old/`
(legacy Java source, kept for reference).

- Structure: `app/` (entry), `core/` (utils, money), `data/` (Drift DB, DAOs, repos, providers,
  models), `features/` (home, fare_calculator, route_lookup), `assets/routes/*.txt` (69 route
  files: `Stop Name,kmIndex` per line), `assets/geo/*.json` (generated map data, see below),
  `tool/*.py` (offline generators — never run at app runtime).
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

- **Every `ON DELETE CASCADE` depends on `PRAGMA foreign_keys = ON`**, set in
  `AppDatabase.migration`'s `beforeOpen` (`lib/data/local/database/app_database.dart:32`). SQLite
  leaves it off and drift does not turn it on, so without that line every cascade is a silent
  no-op. That is exactly how the home screen ended up claiming "No matching routes": a re-seed
  deleted the routes, the stops survived as orphans, the re-insert died on
  `UNIQUE(route_id, sequence)`, `seedIfStale` returned a `Failure`, `routeListProvider` discarded
  it, and the screen rendered an empty list under a search-shaped message.
  `test/data/reseed_test.dart` is the regression net — a fresh install never exercises it.
- **Never swallow a seed failure.** `routeListProvider` must throw when `seedIfStale` fails;
  a failed seed leaves the route tables empty, and reporting that as "no routes" sends the user
  hunting for a search problem they do not have. `home_screen.dart`'s empty view is also gated on
  `hasQuery` so an empty list with an untouched search box reads as a load failure.
- **Landmarks are searchable, and that is the whole point of the `route_landmarks` links.**
  `landmarkListProvider` (`data/providers/route_providers.dart`) reads all 98 from the asset via
  `RouteRepository.getAllLandmarks`; `landmarkMatchesProvider` ranks matches (exact name > prefix >
  name contains > category); `landmarkRouteCodesProvider` turns a matching landmark into route
  codes; `filteredRoutesProvider` unions those with the plain name search. So typing "Abreeza
  Mall" returns the 15 routes that pass it, not zero — no route is called Abreeza. The 24
  unlinked landmarks are shown but say "no route serves this yet" rather than "0 routes".
  UI: `home_screen.dart`'s `_LandmarksSliver` (browse card with no query, matches with one),
  `landmarks_screen.dart` (browser + category chips + "routes passing through" sheet),
  `widgets/landmark_tile.dart`. Route is `/landmarks`.
- **Widget tests must not do real I/O inside the test body.** Asset reads and DB seeding hang in
  the fake-async zone. Load fixtures in `setUp` (real async) and override
  `landmarkListProvider` / `routeListProvider` (`test/features/home/landmarks_screen_test.dart`).
  Also: never `pumpAndSettle` after typing into a `TextField` — the cursor blink never settles.
- **Do not hardcode or curate popularity list.** "Most popular routes" on the home screen is
  derived from per-route `usageCount` + `lastUsedAt` (Drift `JeepneyRoutes` schema v2,
  `RouteDao.recordUsage` / `getPopularRoutes`). Trigger: `ref.listen` in the fare calculator
  fires `recordRouteUsage` when a selection becomes complete. Usage is keyed by `codeName`, not
  row id, precisely so a re-seed can carry it across.
- Route files are `name` + integer `kmIndex` (cumulative km) only, and all 69 are strictly
  monotonic. The diagram is still a schematic CustomPainter, not a geo map.
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
- **Map data is display-only; the fare still comes from `kmIndex`.** `route_stops` has nullable
  `lat`/`lng`/`distDm` (schema v3) and `TripDistance` carries `precise` vs `estimated`
  provenance, but `fareEstimateProvider` prices with `calculateByKmIndex` and shows the measured
  road distance beside the fare. Don't quietly start charging the measured distance.
- **A trip is measured only if *both* ends are placed** (`resolveTripDistance`); one estimated
  end sends the whole trip back to the marks. 102 of 462 stops have a `distDm`; the rest are
  interpolated for display and publish null.
- **The four disputed routes publish no distance at all** — `toril`, `ulas`,
  `tibungco_via_cabaguio_avenue`, `ecoland_subdivision_sm_city_of_davao` (measured leg vs
  curated `totalKm` differ by >3 km). `place_stops.py` marks them `source: disputed`. This was a
  real bug once: the ban was documented but never applied, so 17 stops shipped a distance.
- `assets/geo/routes.json` geometry is **unlicensed** (see `assets/geo/PROVENANCE.md`) — a
  release blocker, not a footnote. **`OSM_GEOMETRY_PLAN.md` is the plan to replace it** with
  OSM-routed geometry; it is written but not started. `assets/geo/unverified/` (numbered
  Poblacion routes 1-15) is quarantined: not bundled, asserted not bundled by
  `test/data/geo/unverified_assets_test.dart`.
- Regenerate map data with `python3 tool/place_stops.py` (offline once
  `tool/.cache/nominatim_stops.json` is warm — it is). Re-run `test/data/geo/` after; those
  tests assert the generated output's contract.
- `test/data/geo/unverified_assets_test.dart` is the test the unverified README promises. It
  exists — don't "fix" the README by deleting the reference.

## Commands (from repo root)

```bash
flutter analyze
flutter test
flutter build apk --release          # output: build/app/outputs/flutter-apk/app-release.apk
flutter test test/core/utils/fare_calculator_test.dart
flutter test test/data/route_and_fare_test.dart
flutter test test/data/geo/
flutter test test/data/reseed_test.dart       # the re-seed path; a fresh install skips it
flutter test test/features/home/      # home list, landmark search + landmark screen
flutter test test/features/home/landmark_search_test.dart
python3 tool/place_stops.py            # regenerates assets/geo/stops.json
```

Host disk sat at 87% (33 GB free) as of the last release build; it was at 96% earlier, so check
`df -h /` before assuming Gradle or the emulator will be slow.

## Fare test expectations (update together with `FareRules`)

`test/core/utils/fare_calculator_test.dart`: 10 km regular total `Money(2600)`, 10 km
discounted `Money(2080)` (saves `Money(520)`); ≤4 km `Money(1400)` / discounted `Money(1120)`
(saves `Money(280)`).
`test/data/route_and_fare_test.dart` (5 km Matina Bankerohan→Agdao): regular `Money(1600)`,
discounted `Money(1280)`, saving `Money(320)`; end-to-end closeTo `16.0` / `12.8`.

## State of the world (what a fresh session should assume)

- 117 tests passing (47 fare/route + 31 geo data + 7 re-seed + 26 home/landmark + 6 fare card),
  `flutter analyze` clean, release APK built (58.4 MB, **unsigned**) and current with the geo
  layer, the cascade fix, and the landmark search UI. No commit yet — the working tree holds all
  of the above.
- The geo layer is seeded and reachable (`RouteRepository.getGeometry` / `getLandmarks` /
  `getAllLandmarks`, `route_geometries` + `landmark_entries` tables); landmarks are now searchable
  and browsable, and the fare card shows the measured road distance beside the priced km, but
  **no UI draws the route geometry yet**.
- The home-screen "no routes" bug is fixed and covered. If the user reports it again on device,
  suspect the app's database file, not the query: the re-seed now cascades correctly, so an
  empty list means seeding genuinely failed and the error view should be showing. A device that
  already has the pre-fix database may still be holding orphaned stop rows from the failed
  re-seed; uninstalling (or deleting the app's data) is the way to clear them, since the fix only
  governs future re-seeds.
- The crash the user saw alongside the empty list was never captured — no stack trace, and it is
  not known whether it shares a cause with the cascade bug.
- On-device selection persistence after the picker closes is still unresolved — that is the next
  open item, and the `[PICK]` debug logs are still in place for it.
- Wiring lives in `data/providers/route_providers.dart`, `data/repositories/route_repository.dart`,
  screen `features/fare_calculator/presentation/screens/fare_calculator_screen.dart`,
  widgets `stop_picker_sheet.dart`, `route_diagram.dart`, `fare_estimate_card.dart`,
  home `features/home/presentation/screens/home_screen.dart`.
- Docs: `README.md`, `ROADMAP.md` (incl. planned fare/distance-precision work), `ARCHITECTURE.md`.