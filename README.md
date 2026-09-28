# Davao Jeepney

A Davao City jeepney fare calculator and route guide, rebuilt in Flutter from the original Java Swing desktop app.

Pick a route, choose your boarding and drop-off points, and see the regular and discounted fares side by side.

## Features

- Browse and search all 69 jeepney routes
- Pick boarding and drop-off stops from the route timeline, with one-tap swap
- See **regular** and **discounted** fares side by side
- Fully offline — route data ships in the app, no network required
- Persistent local database seeded from bundled route files

## Tech stack

| Concern | Choice |
| --- | --- |
| UI | Flutter 3.47.1 / Dart 3.13.1 |
| State | Riverpod |
| Persistence | Drift + SQLite |
| Navigation | GoRouter |
| Money | Integer centavos (no floating point) |

Targets Android, iOS, and Linux. Primary target is the **Pixel 4a** emulator (Android 12 / API 31).

## Getting started

```bash
flutter pub get
dart run build_runner build      # regenerate Drift code after schema changes
flutter run
```

Quality gates:

```bash
flutter analyze                  # must report "No issues found!"
flutter test
```

## Project layout

```
lib/
  app/         App root, router, theme
  core/        Result, Failure, Money, FareCalculator, shared widgets
  data/        Drift database, DAOs, repositories, models, providers
  features/    home/, fare_calculator/
assets/routes/ 69 legacy route files
test/          fare logic, route parsing, end-to-end fare checks
tool/          route manifest generator
```

See [ARCHITECTURE.md](ARCHITECTURE.md) for the details and [ROADMAP.md](ROADMAP.md) for planned work.

## Fare rules

Ported from the original `AlgoHandler.java`:

- Distance of `0` km → `₱0` (no discount applied)
- Otherwise → `₱14` base, plus `₱2` per km beyond the first `4` km
- Discounted fare subtracts a further `%20` for **Student**, **Senior**, and **PWD** passengers

All arithmetic runs on integer centavos. `Money` rejects amounts that cannot be represented exactly.

## Legacy source

The original app is preserved untouched for reference:

- `Old/LE_Project-master/` — original Java sources
- `Assets/jeepneys/` — original route text files

## Development notes

### Regenerating the route manifest

```bash
python3 tool/generate_route_manifest.py
```

Writes `lib/data/local/seed/route_manifest.dart` from `assets/routes/`.

### Emulator configuration

The Pixel 4a AVD renders through Mesa. The default `swiftshader_indirect` GPU mode segfaults on this host, so the AVD is configured with `hw.gpu.mode=software` (Mesa `lavapipe`), which is stable.

A backup of the original AVD config is at `~/.android/avd/Pixel_4a.avd/config.ini.bak`.

If the emulator ever crash-loops, clear stale locks before relaunching:

```bash
rm -f ~/.android/avd/Pixel_4a.avd/*.lock
rm -rf /run/user/1000/avd/running/
```

## License

Route data and fare rules originate from the original project and its contributors.
