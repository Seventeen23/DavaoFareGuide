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

## Next

- [ ] Record route usage locally — increment a per-route counter each time a fare is calculated
- [ ] Add a `TripDao` / `TripRepository` to store that usage data
- [ ] Export the home screen to release builds
- [ ] Add app icon and splash branding
- [ ] Confirm Android release signing configuration

## Most popular routes

Popularity must be **derived from the routes the user actually rides**, not hardcoded or
hand-picked. There is no curated popularity list, so the ranking reflects real local usage only.

Depends on the route usage recording in **Next**, so it cannot land first.

- [ ] Rank routes by locally recorded usage count, most-used first
- [ ] Show a "Most popular routes" section on the home screen
- [ ] Order ties by most recent use, then alphabetically for a stable result
- [ ] Exclude routes the user has never ridden, so the section stays meaningful at first launch
- [ ] Fall back to the default alphabetical list while usage data is still empty
- [ ] Keep the section hidden rather than empty when there is no usage history

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
