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

- [x] **De-couple the fare engine from `kmIndex`.** `FareCalculator.calculate` is now pure on a
      `TripDistance`; `calculateByKmIndex` is the explicit fallback for callers that have only the
      published marks, and `resolveTripDistance` is the one place that decides which a trip gets.
      A future distance strategy (fractional km, measured geometry) slots in without touching
      pricing.

Open work:

- [ ] **Whole-km quantization is still the biggest accuracy gap.** A trip of 4.9 km bills as 4 km
      (₱14.00 instead of ≈₱15.80). The formula cannot be more precise than the fare basis, and the
      fare basis is still the curated whole-km mark. Two possible fixes:
      - Re-curate route files with tenths of a km, **or**
      - Let the fare follow the measured road distance now available on `route_stops.distDm`.
        This is a **product decision, not a data fix**: the published tariff is quoted per whole
        kilometre, so switching would change what the app charges, and the measured length is
        only good for 102 of 462 stops, with 4 routes barred outright. The measured value is
        currently shown beside the fare as information.
- [ ] **Latent rounding bug in `percentOff` / `percentFrom`.** On non-round centavo totals the
      two disagree (e.g. ₱0.07 total: `percentOff(20)` saves 1¢ → pay 6¢, `percentFrom(20)` →
      pay 5¢). Unreachable today because every fare is a multiple of ₱1.00, but a footgun.
      Canonical fix: `paid = total.percentFrom(20); deduction = total - paid;` (one source of
      truth).
- [ ] **`abs()` assumes one-way out-and-back lines.** Correct for today's data, but a future
      loop/circuit route would need `min(|a − b|, totalKm − |a − b|)`.
- [ ] **Normalise the 13 route files that do not start at km 0.** Benign to fares (the baseline
      cancels in `abs`), but shifts the route diagram and implies mixed curation. Normalise to
      0 for consistency or document the mixed baselines.

## Real map data (geocoded stops)

Decision (Sep 2026): **geocode the stops, don't chase true road polylines yet.** Audio of
available sources:

> No ready-made geometry exists for the 69 named routes. OSM has real relations only for the
> numbered Poblacion routes (1, 4, 5, 8, 10, 11, 12, 13); named routes exist only as ordered
> street sequences on the OSM wiki (mapping "in progress", older PTv1 scheme, stops missing).
> plexus-gtfs covers Metro Manila only; PARASOL covers Bacolod/GenSan/Iloilo only;
> commute-davao.com draws *computed* shortest paths over the road graph, not the real lines.

This later turned out to be half true: commute-davao.com does ship hand-drawn polylines for
52 routes in its JS bundle, 31 of which match a bundled route. They are **unlicensed** — see
`assets/geo/PROVENANCE.md`, which is a blocker for shipping, not a footnote.

Locked decisions:

- Fares stay on `kmIndex`; **coordinates are display-only**, so the fare model is untouched.
- Rendering: **one static map image per route** (pre-rendered PNG) shown in route detail; the
  schematic diagram remains the fallback when the image is missing or if offline.
- Coordinates stored **nullable** on `route_stops` (schema v2 → v3 migration), filled from one
  deduped geocoding pass (a few hundred unique stop names, not ~2000 rows).

Landed:

- [x] Migration: nullable `lat` / `lng` / `distDm` on `route_stops` (schema v3), plus
      `route_geometries`, `landmark_entries` and `route_landmarks`
- [x] `tool/fetch_route_geometry.py` — imports the out-and-back polylines, splits each at its
      turnaround, and records where the measurement contradicts the curated `totalKm`
- [x] `tool/place_stops.py` — geocodes then **validates against geometry**: a stop is only
      trusted within 250 m of its own route's polyline, which is what rejects the "Puting Bato
      landed 20 km east" class of Nominatim answer. 102 of 462 stops get a distance in decimetres;
      the rest are interpolated from `kmIndex` for display and publish nothing
- [x] `tool/fetch_landmarks.py` — 98 landmarks (curated / Wikidata / OSM POIs in corridor)
- [x] `TripDistance` + `resolveTripDistance` carry **provenance**: a trip is measured only when
      *both* ends are placed, and the fare engine still prices from `kmIndex`; the measured
      distance is shown beside the fare, never charged
- [x] `assets/geo/unverified/` — the 15 numbered Poblacion routes are quarantined (no stops, no
      `kmIndex`, no fare basis), not bundled, and asserted unbundled by
      `test/data/geo/unverified_assets_test.dart`
- [x] `test/data/geo/` — 31 tests over the generated data: placement rows must match the route
      files, interpolated stops must publish no distance, disputed routes must publish none at
      all, coordinates must stay inside Davao, quarantined data must never reach the database
- [x] `test/data/reseed_test.dart` — the re-seed path a fresh install never takes: cascades are
      armed (`PRAGMA foreign_keys`), a changed asset fingerprint rebuilds all 69 routes with their
      stops and geometry, and popularity history survives by `codeName`
- [x] `test/features/home/home_route_list_test.dart` — an untouched search box never filters, and
      a failed seed surfaces as an error instead of an empty list under "No matching routes"

Still open:

- [ ] **Licensing, before any release.** The 31 polylines have no licence. Either ask the author
      for permission with credit, or rebuild the geometry from OSM highway ways.
- [ ] Static image generator: build-time script fetches OSM tiles, draws the route polyline
      through the real stops, exports `assets/routes/{code}.png`; a test asserts every route
      ships an image
- [ ] Route detail: show `Image.asset` map PNG when present, else fall back to the schematic
- [ ] Attribution screen: OSM + geocoder (ODbL); respect OSM tile-usage policy by bundling tiles
      at build time, never hotlinking tiles at runtime
- [ ] Hand-review the 343 interpolated stops in `assets/geo/stops_REVIEW.md`; a few will be
      genuine mis-geocodes worth correcting
- [ ] Decide the four disputed routes (`toril`, `ulas`, `tibungco_via_cabaguio_avenue`,
      `ecoland_subdivision_sm_city_of_davao`): which length is authoritative, the site's or the
      curated `totalKm`? Until then they publish no distance at all.
- [ ] 24 landmarks are on no route, so they cannot be drawn; link them by proximity or drop them

Risks / notes:

- Subdivision stop names ("Rosalina III", "Landmark III") geocode imperfectly → the manual-review
  step in the geocoding job.
- Straight segments between stops — the map corridor is approximate, no road-following.
- Bonus tie-in: once stops have coords, "Landmarks and routes passing through X" becomes nearly
  free. `assets/landmarks.json` is already bundled and seeded; only the UI is missing.

## Later

- [ ] Trip history — deliberately deferred; the user-facing history list is not needed yet
- [ ] Favourited and recently used routes
- [ ] Landmarks and "routes passing through X" search — the data is already bundled and seeded
      (98 landmarks, 74 of them linked to a route); only the search UI is missing
- [ ] Real-time service advisories, which require a backend
- [ ] Optional fare and route data sync from a remote source

## Known issues

- On-device selection persistence after the stop picker closes is still unresolved. The picker
  returns a selection that the fare screen does not keep; `[PICK]` debug logs are in place and
  `fareSelectionProvider`'s `autoDispose` is the prime suspect.
- `RouteRepository` currently owns asset parsing and database seeding together. Split parsing
  (`RouteFileParser` consumers) from persistence when a second route source is added.
- The AVD renders via Mesa `lavapipe`, which is correct but slow. Frame timings sit well above
  what real hardware produces, so profile on a physical device before drawing conclusions
  about UI performance.
- Trip history directories exist but are unpopulated; the feature is not wired up.
- The map data is display-only and unshipped-in-spirit: `assets/geo/PROVENANCE.md` records that
  the source geometry has no licence, so a release built today would redistribute it.
- The root disk sits at 96% capacity. Gradle and emulator work are both slowed by this.
