# DO NOT USE — unverified route data

Nothing in this directory is loaded by the app, and a test
(`test/data/geo/unverified_assets_test.dart`) asserts that no code path reads it.

## What is here

`route_1_15.json` holds the polylines for the **15 numbered Poblacion
jeepney routes**. They were extracted from the same source as
`../routes.json`, so their geometry is of the same quality.

## Why they are quarantined

These routes exist on `commutedavao.com` but have **no counterpart in this
project**. `assets/routes/` has never contained them, so there is:

- no stop list
- no `kmIndex` — and therefore no fare basis
- no route `.txt` file
- no manifest entry

The fare model is driven by stop distance. With no stops there is nothing to
price, and `kmIndex` in this project is curated whole-kilometre data that
cannot be invented.

## Verification status

`street_sequences.md` records what is independently documented. Be aware that
**the OSM wiki only describes routes 1–5**; for routes 6–15 no street-level
documentation was found anywhere, and the OSM `Relation` column is empty for
every one of these routes, meaning no mapped relation exists either.

## To promote a route

1. Confirm the endpoints and street sequence against a city document or a
   driver/operator.
2. Write `assets/routes/route_N.txt` using the existing `Stop Name,kmIndex`
   format, whole kilometres, strictly monotonic.
3. Run `python3 tool/generate_route_manifest.py` to add the manifest entry.
4. Re-run `python3 tool/fetch_route_geometry.py` so `../routes.json` gains a
   match, then `python3 tool/place_stops.py` to place the stops.
5. Delete the entry from this directory and update the tests.
