# Plan: replace the third-party route geometry with OSM-routed geometry

**Status:** planned, not started. Nothing in this document has been implemented.
**Why it exists:** `assets/geo/routes.json` is copied from a third party's JS bundle and
carries no license. See `assets/geo/PROVENANCE.md`. This is the plan to replace it with
geometry routed from OpenStreetMap, which is ODbL 1.0 and shippable.

**Decisions already taken (2026-09-30):**
- Landmarks are used as via-points; the router picks which roads connect them. No attempt to
  force the path onto the `via` road named in a route.
- The public OSRM demo server (`router.project-osrm.org`) is the router.

---

## 1. The problem, stated precisely

Two things are in the app today and they have different legal status.

| Data | Source | Status |
| --- | --- | --- |
| Stop names + `kmIndex` + `totalKm` | Davao Fare Rate Guide, via `assets/routes/*.txt` | Fine — published tariff, used since day one |
| **Route polylines** | commutedavao.com JS bundle, copied verbatim | **No license. Redistributing it is the exposure.** |

The user's own read of the situation is right on the important half: the fare guide has stop
names and kilometre marks but **no coordinates**, so it cannot supply a line. The line is the
one genuinely creative artifact, and it is also the only unlicensed thing in the project.

**Everything else in the geo layer is already clean.** `assets/landmarks.json` is curated +
Wikidata (CC0) + OSM POIs. `assets/geo/stops.json` coordinates are Nominatim (ODbL). Only
`routes.json` is a problem, and it is 556,210 bytes of the shipped APK.

## 2. What was actually verified before planning this

Numbers from the repo on 2026-09-30. Do not trust these after a re-seed without re-measuring.

- **1210 stop rows** across 69 routes. (The "462 stops" figure in `AGENTS.md` is *placements* in
  `stops.json`, which only covers the 31 routes the third-party data matched.)
- **565 / 1210 (47%)** of stop rows have a candidate coordinate from
  `tool/.cache/nominatim_stops.json` (456 names cached, 182 non-null) or a curated landmark seed.
- **39 of 69 routes** have a coordinate on *both* the first and last stop → a full end-to-end path.
- **67 of 69 routes** have at least 3 coordinate-bearing stops → a partial path.
- **0 of 69 routes** have every stop geocoded.
- The Nominatim cache is warm, so nothing in Phase 1 needs to re-geocode.
- **OSRM's demo server does cover Davao.** A spot check between two downtown points returned
  `code: Ok`, 1,520 m, 76 geometry points. This was the single biggest technical risk and it is
  now closed.
- `commute-davao-3d` has **no LICENSE file**. The README is untouched `create-next-app`
  boilerplate. 37 commits, 0 stars, 0 forks, 0 issues. 0 issues also means a GitHub issue is a
  clean, unused way to ask the author for permission — worth doing in parallel with this work,
  not instead of it.

**Headline:** the OSM rebuild covers *more routes* than the current data (39 full + more partial,
versus 31), and is licensed. It is thinner *within* a route. That is the tradeoff, and it is a
favorable one.

## 3. The circular dependency, and how it resolves

This is the part that is easy to get wrong. `tool/place_stops.py` uses the polyline for **three**
purposes, not one:

1. **Validation** — snap each geocoded stop to the route and reject anything more than
   `SNAP_LIMIT_KM` (0.25 km) off it. This is load-bearing. Nominatim cannot read jeepney
   jargon: the script's own docstring records that only 47 of 461 unique stop names match an OSM
   name at all, and that of 26 hard names sampled, "Puting Bato" landed 20 km east and "Marilog"
   on a farm.
2. **Measurement** — `distDm`, the distance along the one-way leg, shown beside the fare.
3. **Interpolation** — a display position for stops that could not be placed, derived from
   `kmIndex`.

So the naive reading is circular: *routing between stops* needs coordinates, and *trusting those
coordinates* needs a polyline to validate against.

**It resolves by inverting the order — route first, validate second:**

1. Geocode the stops. Already cached; free.
2. Route between the candidates. A mis-geocoded stop does not break the routing — the router
   simply takes an absurd detour to reach it, and the path is still a valid road path.
3. **That detour is the validator.** A 20 km leg to reach "Puting Bato" is better evidence than
   its distance from a hand-drawn line, because it measures the thing that actually matters:
   whether the stop is plausibly on this route.

The `snap()` function itself does not change. Snapping to an OSM-routed polyline is the same
operation as snapping to a hand-drawn one, and arguably better founded.

## 4. Schema compatibility — the reason this is cheap

`assets/geo/routes.json` is **schema v1** with these keys per route:

```
codeName, siteName, match, loop, turnaroundIndex, onewayKm, loopKm, declaredKm, kmDelta
```

The coordinates are under `loop` — the **full out-and-back loop** — with `turnaroundIndex`
saying where to cut it. `place_stops.py:232` reconstructs the fareable leg as:

```python
oneway = loop[: route_geometry["turnaroundIndex"] + 1]
```

The generator does not need an out-and-back at all, because it routes stop 0 → stop N directly.
So it can synthesise the loop to match the existing schema exactly:

```
loop            = oneway + reversed(oneway[1:])
turnaroundIndex = len(oneway) - 1
```

which makes `loop[:turnaroundIndex+1]` *identical* to the routed one-way leg.

**Consequence: zero Dart changes.** `GeoAssets.loadGeometries()` and `RouteGeometry` keep working
untouched, `place_stops.py`'s split logic keeps working untouched, and
`geo_assets_test.dart`'s existing loop tests keep passing. Unknown JSON keys are ignored by
`geo_assets.dart`, so new fields are additive.

## 5. The one correctness trap in Phase 1

`place_stops.py:290` maps an unplaced stop onto the polyline like this:

```python
fraction = km_index / declared_max
index   = min(len(oneway) - 1, int(fraction * (len(oneway) - 1)))
```

This is only correct if the polyline spans the route's **whole** `kmIndex` range. The current
hand-drawn loops do. Routed geometry will not: if the waypoints only cover km 0–5 of a 0–8
route, a stop at km 7 would be drawn at 87% along a line that physically ends at km 5. Every
unplaced stop in the uncovered tail would be placed in the wrong place, silently.

**Fix:** emit `coveredKm: [min, max]` per route, and remap interpolation through that range
instead of `[0, totalKm]`. A stop outside `coveredKm` must publish `lat`/`lng` of `null` rather
than a plausible-looking wrong position. Marking it interpolated and honest beats drawing it.

## 6. Phase 1 — `tool/build_osm_geometry.py` (new)

The whole job. Offline after the first run; output committed so the app never needs it.

**Inputs:** `assets/routes/*.txt` (stop order + `kmIndex`), `tool/.cache/nominatim_stops.json`,
`assets/landmarks.json`.

**Waypoints per route,** ordered nearest-neighbour starting from `kmIndex` 0:
- stops that have a candidate coordinate
- plus that route's landmarks from `assets/landmarks.json` (74 of the 98 are route-linked)

`assets/landmarks.json` stores `routes` as an unordered set per landmark, so the ordering has to
be derived. Nearest-neighbour from the first stop is sufficient and deterministic.

**Routing:** one `OSRM /route/v1/driving/` call per route with
`overview=full&geometries=geojson`. About 69 calls, trivial load for the demo server. Cache every
raw response to `tool/.cache/osrm_routes.json` so re-runs are free and reproducible — same
pattern as the existing Nominatim cache, and the same reason: the committed output must be
regenerable without hitting a network.

**Per-leg sanity gate:** for each consecutive waypoint pair, compare the routed leg length
against the `kmIndex` delta between those stops. A leg that detours absurdly — jeepney runs a
one-way against the router's preference, or a stop is mis-geocoded — falls back to a straight
line and downgrades the route to `partial`.

**Output:** schema v1, byte-compatible per §4, with two additions:
- `source: "routed" | "partial"`
- `coveredKm: [min, max]` per §5

`siteName` and `match` are third-party provenance fields. They should be dropped or replaced with
an OSM provenance string — leaving a field named `siteName` pointing at commutedavao in a
cleanly-licensed file would be its own kind of lie.

**Exit criterion: report the real coverage numbers before touching anything else.** How many
routes come out `routed`, how many `partial`, and how many legs the gate rejected. If coverage
lands near 39 rather than 69, that is worth knowing now rather than after Phases 2–4.

## 7. Phase 2 — `place_stops.py` (small)

- Snap onto the routed polyline. Algorithm unchanged.
- Replace the "reject if >250 m off" verdict with the leg-length evidence from Phase 1.
- Remap interpolation through `coveredKm` (§5).
- Recompute `onewayKm` and `kmDelta`; revisit the disputed-route bar.

**Keep the existing per-stop `source` values** — `geocoded`, `disputed`, `interpolated` —
because `StopPlacement.isMeasured` in `geo_assets.dart` tests `source == 'geocoded'`. The new
`routed`/`partial` is route-level and lives in `routes.json`. No Dart change.

`flutter test test/data/geo/` must pass before moving on.

## 8. Phase 3 — kill the import

- Delete `tool/fetch_route_geometry.py` outright, not merely de-referenced.
- Rewrite `assets/geo/PROVENANCE.md` and `provenance.json` as OSM-derived, with
  `© OpenStreetMap contributors` and the ODbL 1.0 notice.
- Delete `assets/geo/unverified/`. Those 15 numbered Poblacion routes came from the same source
  and have no stop list, no `kmIndex` and no fare basis, so OSM cannot route them. They are
  already unbundled; now they are gone.
  `test/data/geo/unverified_assets_test.dart` currently asserts the data is *not bundled* — it
  should become an assertion that the file **is absent**. Update the reference in
  `assets/geo/unverified/README.md` (or delete it with the directory); do not delete the test.
- **Attribution is a legal obligation, not polish.** Minimum: a credit line on the landmarks
  screen, which is currently the only UI that consumes geo data, plus a CREDITS block in
  `README.md`. A full attribution *screen* can wait for the map UI, and is already a ROADMAP
  item.

## 9. Phase 4 — tests, including the one that is supposed to fail

`test/data/geo/geo_assets_test.dart:127` asserts:

```dart
expect(kmDelta.abs() > maxKmDeltaKm, kDisputedRoutes.contains(entry.key));
```

That is an **equality** between the hardcoded list and the computed set. Routing changes every
measured distance, so this test will fail, and it should. The failure is the curation
checkpoint, not an obstacle: a new disagreement means "the router took a different path", which
is a *different claim* from the old "the site drew a different route". The list needs a human
re-decision. **Do not auto-derive it** — the comment at `geo_assets_test.dart:14-16` explains
that a test recomputing the list from the same field it is checking would agree with any value
of it, including a wrong one. That reasoning still holds after the rebuild.

The four currently disputed routes are `toril`, `ulas`, `tibungco_via_cabaguio_avenue`,
`ecoland_subdivision_sm_city_of_davao` — extracted one-way length disagreeing with declared
`totalKm` by more than 3 km (`MAX_KM_DELTA`).

New assertions:
- every geometry route carries a `source`
- every routed leg is within tolerance of its `kmIndex` delta
- no coordinate lies outside the Davao box (`kDavaoLat` 6.9–7.6, `kDavaoLng` 125.2–125.9)
- the ODbL attribution string is present
- no stop is placed outside its route's `coveredKm`

`flutter test` and `flutter analyze` after every phase.

`GeoAssets.contentFingerprint()` is a byte-length fingerprint of the three geo assets, so
existing installs will re-seed automatically when the new assets land. No schema version bump
needed for that, but `place_stops.py` writing a different `source` set is worth a re-seed.

## 10. Risks, stated plainly

**Routed geometry follows roads; a hand-drawn line follows habit.** Where a jeepney runs against
a one-way restriction or onto a way tagged `access=no`, OSRM will detour onto a parallel street.
The output will be *more accurate and less familiar* at the same time. The `routed`/`partial`
marker and the per-leg gate are what keep that honest rather than silent.

**Coverage could land nearer 39 than 69 routes.** The 47% coordinate rate is the ceiling. This is
the expected failure mode and Phase 1's exit criterion exists to surface it early.

**One-way restrictions are the most likely source of bad routes.** If Phase 1 shows systematic
detours, the fallback options in order of preference are: try a relaxed profile, then route with
`continue_straight` options, then accept and mark `partial`. Do not silently relax the gate.

**ODbL is share-alike.** Derived data (the routed geometry, arguably a database) must carry
attribution and the ODbL notice. That is compatible with shipping in an app, but it is a real
obligation and Phase 3 is where it is discharged.

## 11. Explicitly out of scope

- Any map UI. This work is data only; `getGeometry` has no caller under `lib/features/` and that
  stays true.
- A full attribution screen (already a ROADMAP item; Phase 3 ships only the credit line).
- The 15 Poblacion routes — deleted, not rebuilt.
- Auto-curating `kDisputedRoutes`.
- Contacting the author. Worth doing in parallel, and it is still the cheapest path to keeping
  the better-looking geometry; this plan is what happens if he does not reply.

## 12. Session-to-session context

- Stops are already geocoded and cached. Nothing needs Nominatim again.
- The Nominatim hit rate on jeepney stop names is genuinely bad. Do not raise
  `SNAP_LIMIT_KM` to force more placements through; the 250 m gate is doing real work and the
  roadmap to more coverage is better stop names, not looser validation.
- **Fares must not start using routed distance.** `fareEstimateProvider` prices with
  `calculateByKmIndex` and shows the measured road distance beside the fare. That separation is
  load-bearing and there is a test for it
  (`test/data/geo/geo_seeding_test.dart` — "a measured road distance never changes a fare").
  Routing will make those numbers *more* accurate and therefore *more* tempting to charge. Do not.
- Android Studio must be closed during emulator work; the `Pixel_4a` AVD runs on Mesa `lavapipe`
  and boots in ~18 s. Check `df -h /` first — the host has been as high as 96% full.
