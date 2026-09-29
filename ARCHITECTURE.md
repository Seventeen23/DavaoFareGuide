# Architecture

## Layering

Dependencies point inwards only. `features` may use `data` and `core`. `data` may use `core`.
`core` depends on neither.

```
lib/
  app/          # composition root: router, theme, MaterialApp
  features/     # UI + presentation logic, grouped by screen
  data/         # persistence, models, repositories, shared providers
  core/         # no feature or data knowledge
```

`lib/app/app.dart` builds the `MaterialApp` and mounts the router. Feature screens are imported
by the router alone, which keeps navigation in one place.

## core

Framework-light and dependency-free apart from `intl` and `equatable`.

- `Result<T>` / `Failure` — a typed success-or-failure return type. Repositories return
  `Result` rather than throwing, so callers must handle the failure path.
- `Money` — a value type over integer centavos. Rejects fractional-cent amounts outright.
  All fare arithmetic goes through it.
- `FareCalculator` — the ported fare rules. Pure functions, no I/O, fully unit tested. Priced
  from a `TripDistance`, so a caller says *how far* rather than *which stops*.
- `TripDistance` — a trip length in integer decimetres that records whether it was **measured**
  on the route polyline or **estimated** from the published kilometre marks.
  `resolveTripDistance` is the only place that decision is made: measured only when both ends
  are placed, otherwise the whole trip falls back to the marks.
- `RouteFileParser` — parses the legacy `Stop Name,kmIndex` text format.
- `AppCard`, `AppEmptyView` — shared presentation widgets.

## data

- `app_database.dart` — the Drift database, holds the tables and DAOs. Schema v3.
- `tables/app_tables.dart` — `JeepneyRoutes`, `RouteStops`, `RouteGeometries`, `LandmarkEntries`,
  `RouteLandmarks`, `Trips`, `AppMeta`.
- `daos/route_dao.dart` — route, stop, geometry and landmark queries, plus the usage counter.
- `repositories/route_repository.dart` — parses the bundled assets, seeds the database when the
  bundled data changes, and serves route lookups. Returns `Result`.
- `providers/route_providers.dart` — the shared `databaseProvider`, `routeRepositoryProvider`,
  `routeListProvider`, and `routeDetailProvider`.
- `seed/route_manifest.dart` — generated list of the 69 routes and their file names.
- `seed/geo_assets.dart` — reads the generated map data in `assets/geo/` and
  `assets/landmarks.json`. Every field degrades to null rather than throwing, because a stop
  with no coordinate still has a name and a kilometre mark. `contentFingerprint()` is what tells
  an install that the bundled data changed under it.
- `models/` — `JeepneyRoute`, `RouteStop`, `GeoPoint`, `RouteGeometry`, `MapLandmark`,
  `PassengerCategory`.

`Trip` is defined in the schema but has no DAO or repository yet.

### Generated map data

`assets/geo/routes.json`, `assets/geo/stops.json` and `assets/landmarks.json` are produced
offline by `tool/fetch_route_geometry.py`, `tool/place_stops.py` and `tool/fetch_landmarks.py`.
Never generated at runtime. The stops are geocoded and then *validated against geometry*: a stop
is only trusted within 250 m of its own route's polyline, which is what catches a Nominatim
answer that is 20 km away. The result is sparse by design — 102 of 462 stops carry a measured
distance, and the rest publish a display position only.

`assets/geo/PROVENANCE.md` records that the route geometry is **unlicensed**, which blocks a
release until it is resolved. `assets/geo/unverified/` is quarantined: the 15 numbered Poblacion
routes have no stops, no `kmIndex` and no fare basis, so they are not bundled and
`test/data/geo/unverified_assets_test.dart` asserts that.

Map data is **display-only**. `fareEstimateProvider` prices with `calculateByKmIndex` and shows
the measured road distance beside the fare, because the published tariff is quoted per whole
kilometre in the curated marks.

## features

### home

Route list with search. `route_search_provider.dart` owns the query and filters the list client-side.

### fare_calculator

The main flow. `fare_estimate_provider.dart` derives a `FareEstimate` — boarding stop, drop-off
stop, distance, and per-category fares — from the selected route and the two chosen stops.

`FareEstimate` is a presentation model, not a database entity. It exists so the fare screen can
depend on one Riverpod provider rather than recomputing fares inline.

## State management

Riverpod. `Provider` for synchronous dependencies, `FutureProvider` for database reads, `Notifier`
for user input such as the search query. `autoDispose.family` for per-route detail providers.

`databaseProvider` closes the database on dispose, so the connection is not leaked.

## Data flow

```
assets/routes/*.txt   -> RouteFileParser  --+
assets/geo/*.json    -> GeoAssets        --+--> RouteRepository.seedIfStale()
                                              -> Drift / SQLite
                                              -> RouteDao
                                              -> routeListProvider
                                              -> HomeScreen
```

Seeding is keyed on the asset fingerprint, not on emptiness: a new build with new bundled data
re-seeds once, carrying per-route usage counts across by `codeName` rather than by row id.

Selecting a route navigates to `/ride/:codeName`, where `routeDetailProvider` loads the stops and
`fare_estimate_provider` computes fares as the user picks stops.

## Navigation

GoRouter with two routes: `/` for the route list and `/ride/:codeName` for a route's fare
calculator. The code name is the route identifier and is stable across renames.

## Fare computation

`FareCalculator` is a pure function of distance and passenger category, ported from the original
`AlgoHandler.java`:

| Distance | Regular | Discounted |
| --- | --- | --- |
| `0` km | `₱0` | `₱0` |
| first 4 km | `₱14.00` | 20% off the total |
| each km past 4 | `+₱2.00` | 20% off the total |

The tariff in `FareRules` is the Davao Fare Rate Guide's, not the original Swing app's
(`₱13 + ₱1.50/km` − `₱2`); the legacy parity tests were deleted with it. Whole kilometres only,
and zero distance short-circuits before the discount is applied. A zero fare from identical
boarding and drop-off stops is asserted in tests.

## Testing

- `fare_calculator_test.dart` — fare rules, including the zero-distance case
- `route_manifest_test.dart` — manifest/asset consistency and parser behaviour
- `route_and_fare_test.dart` — database seeding and end-to-end fares over real route data,
  including a real Matina trip priced for every category
- `test/data/geo/geo_assets_test.dart` — the contract of the generated map data: placements match
  the route files, an interpolated stop publishes no distance, coordinates stay inside Davao
- `test/data/geo/geo_seeding_test.dart` — what the map data does to the database, and the
  invariant that a measured road distance never changes a fare
- `test/data/geo/unverified_assets_test.dart` — the quarantined geometry is unbundled and never
  reaches the database
- `reseed_test.dart` — the re-seed path: cascades are armed, a changed asset fingerprint rebuilds
  every route, and popularity history survives the rebuild. A fresh install never exercises this.
- `test/features/home/home_route_list_test.dart` — what the home screen is handed on a cold start:
  an untouched search box never filters, and a failed seed surfaces as an error rather than an
  empty list wearing a search-shaped message
- `test/features/fare_calculator/fare_estimate_card_test.dart` — the road distance is shown beside
  the priced km, and never in place of it

The geo tests read the generated files as well as the parsers, so a change to
`tool/place_stops.py` that quietly drops one of its guarantees fails the suite.

### Foreign keys

SQLite ships with `PRAGMA foreign_keys` off, and drift does not turn it on. Every
`ON DELETE CASCADE` in `app_tables.dart` — stops from routes, trips from routes, route landmarks
from both — is therefore a silent no-op unless `AppDatabase.migration`'s `beforeOpen` sets the
pragma. It does. This matters because `RouteDao.deleteRouteData` leans on the routes→stops
cascade: with it off, a re-seed orphans every stop row and then dies on
`UNIQUE(route_id, sequence)`, which surfaces to the user as a route list that is suddenly empty.
`test/data/reseed_test.dart` asserts the pragma is on before it asserts anything about reseeds.

## Code generation

Drift generates `app_database.g.dart`. Regenerate with:

```bash
dart run build_runner build
```

The generated file is checked in. Re-run it after any change to the schema or table definitions.
