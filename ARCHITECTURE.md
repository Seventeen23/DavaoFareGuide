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
- `FareCalculator` — the ported fare rules. Pure functions, no I/O, fully unit tested.
- `RouteFileParser` — parses the legacy `Stop Name,kmIndex` text format.
- `AppCard`, `AppEmptyView` — shared presentation widgets.

## data

- `app_database.dart` — the Drift database, holds the tables and DAOs.
- `tables/app_tables.dart` — `Routes`, `Stops`, `Trips`.
- `daos/route_dao.dart` — route and stop queries.
- `repositories/route_repository.dart` — parses the bundled assets, seeds the database on first
  run, and serves route lookups. Returns `Result`.
- `providers/route_providers.dart` — the shared `databaseProvider`, `routeRepositoryProvider`,
  `routeListProvider`, and `routeDetailProvider`.
- `seed/route_manifest.dart` — generated list of the 69 routes and their file names.
- `models/` — `JeepneyRoute`, `RouteStop`, `PassengerCategory`.

`Trip` is defined in the schema but has no DAO or repository yet.

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
assets/routes/*.txt
  -> RouteFileParser
  -> RouteRepository.seedIfEmpty()   (first run only)
  -> Drift / SQLite
  -> RouteDao
  -> routeListProvider
  -> HomeScreen
```

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
| otherwise | `₱13 + ₱1.50/km` over 4 km | regular − `₱2` |

Zero distance short-circuits before the discount is applied, which matches the original. A zero
fare from identical boarding and drop-off stops is asserted in tests.

## Testing

- `fare_calculator_test.dart` — fare rules, including the zero-distance case
- `route_manifest_test.dart` — manifest/asset consistency and parser behaviour
- `route_and_fare_test.dart` — database seeding and end-to-end fares over real route data,
  including a real Matina trip priced for every category

Fare tests assert parity with the legacy implementation, so a change in one without the other
fails the suite.

## Code generation

Drift generates `app_database.g.dart`. Regenerate with:

```bash
dart run build_runner build
```

The generated file is checked in. Re-run it after any change to the schema or table definitions.
