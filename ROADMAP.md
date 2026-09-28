# Roadmap

## Done

- [x] Port the project to Flutter from the original Java Swing app
- [x] Adopt a modular `app` / `core` / `data` / `features` structure
- [x] Add Riverpod for state and GoRouter for navigation
- [x] Replace the in-memory model with Drift + SQLite
- [x] Seed the database from the 69 bundled route files
- [x] Port the fare rules and verify them against the original implementation
- [x] Add integer-centavos `Money` to remove floating-point rounding errors
- [x] Redesign the UI around a ride-booking flow
- [x] Show regular and discounted fares side by side
- [x] Add route search and a searchable stop picker
- [x] Remove the account, login, and profile screens
- [x] Add a route manifest generator script
- [x] Cover fare logic, route parsing, and end-to-end fares with tests
- [x] Stabilise the Pixel 4a emulator on this host
- [x] Record route usage locally — increment a per-route counter each time a fare is calculated
- [x] Add a `TripDao` / `TripRepository` to store that usage data
- [x] Ship the home screen in release builds
- [x] Add the legacy `loglo_launcher` app icon and the "DavaoFare Guide" label
- [x] Replace the legacy discount deduction with a 20% discount (`discountPercent`) and delete
      the legacy `LegacyAlgo` parity tests
- [x] Build a release APK under the current fare spec (`build/app/outputs/flutter-apk/app-release.apk`)

## Next

- [ ] Confirm Android release signing configuration (build a signed APK/AAB for the Play Store)
- [ ] Splash branding (currently ships the default Flutter splash)
- [ ] Verify on a physical device — frame timings on the `lavapipe` emulator are not representative
- [ ] Re-run `flutter analyze` + `flutter test` and rebuild the APK whenever fare rules change

## Most popular routes

Popularity is **derived from the routes the user actually rides**, not hardcoded or hand-picked.
There is no curated popularity list, so the ranking reflects real local usage only.

Done:

- [x] Rank routes by locally recorded usage count, most-used first
- [x] Show a "Most popular routes" section on the home screen
- [x] Order ties by most recent use, then alphabetically for a stable result
- [x] Exclude routes the user has never ridden, so the section stays meaningful at first launch
- [x] Keep the section hidden rather than empty when there is no usage history

## Fare model & distance precision (km algorithm)

Offers the user feedback:

> "the algorithm is fine — the data is the ceiling. The math (`abs(start − end)` +
> billable-km + base/per-km) is the correct standard model and the storage is cleanly
> normalized. The real accuracy limiter is whole-number km."

Findings from an audit of all 69 route files (they are strictly monotonic: 0 duplicate km
indices, 0 inversions, median length 14 km, 13 files do not start their file at km 0).

Open work:

- [ ] **Whole-km quantization is the biggest accuracy gap.** A trip of 4.9 km bills as 4 km
      (₱14.00 instead of ≈₱15.80). The formula cannot be more precise than the data. Two
      possible fixes:
      - Re-curate route files with tenths of a km, **or**
      - Store per-stop lat/lng and derive distance some other way. Note kmIndex is cumulative
        *route* distance, which is closer to real jeepney fare computation than straight-line
        distance, so coordinates are a larger effort for roughly the same result.
- [ ] **Latent rounding bug in `percentOff` / `percentFrom`.** On non-round centavo totals the
      two disagree (e.g. ₱0.07 total: `percentOff(20)` saves 1¢ → pay 6¢, `percentFrom(20)` →
      pay 5¢). Unreachable today because every fare is a multiple of ₱1.00, but a footgun.
      Canonical fix: `paid = total.percentFrom(20); deduction = total - paid;` (one source of
      truth).
- [ ] **`abs()` assumes one-way out-and-back lines.** Correct for today's data, but a future
      loop/circuit route would need `min(|a − b|, totalKm − |a − b|)`.
- [ ] **De-couple the fare engine from `kmIndex`.** `FareCalculator.calculate(startKm, endKm)`
      hardcodes the storage notion of kmIndex. Cleaner: make the calculator pure on
      `distanceKm` and move `|start − end|` into a route-level helper so a future distance
      strategy (fractional km, coordinates) can slot in without touching pricing.
- [ ] **Normalise the 13 route files that do not start at km 0.** Benign to fares (the baseline
      cancels in `abs`), but shifts the route diagram and implies mixed curation. Normalise to
      0 for consistency or document the mixed baselines.

## Later

- [ ] Trip history — deliberately deferred; the user-facing history list is not needed yet
- [ ] Favourited and recently used routes
- [ ] Landmarks and "routes passing through X" search
- [ ] Offline map or route-corridor visualisation
- [ ] Real-time service advisories, which require a backend
- [ ] Optional fare and route data sync from a remote source

## Known issues

- `RouteRepository` currently owns asset parsing and database seeding together. Split parsing
  (`RouteFileParser` consumers) from persistence when a second route source is added.
- The AVD renders via Mesa `lavapipe`, which is correct but slow. Frame timings sit well above
  what real hardware produces, so profile on a physical device before drawing conclusions
  about UI performance.
- Trip history directories exist but are unpopulated; the feature is not wired up.
- The root disk sits at 96% capacity. Gradle and emulator work are both slowed by this.
