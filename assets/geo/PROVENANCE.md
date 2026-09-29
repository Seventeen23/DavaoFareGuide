# Provenance of the route geometry

`routes.json` and `unverified/route_1_15.json` were imported from a third party.
Read this before publishing.

## Source

- **Site:** <https://commutedavao.com> — "Commute Davao"
- **Author:** Zaldy Pagaduan Jr. (`zopagaduanjr`), Davao City
- **Related repository:** <https://github.com/zopagaduanjr/commute-davao-3d>
- **Fetched:** see `provenance.json` for the exact timestamp and bundle hash

The polylines were extracted from the site's minified JavaScript bundle, which
embeds a GeoJSON `FeatureCollection` of 52 routes as `LineString` geometries.

## Licensing — unresolved

**Neither the site nor the author's repository carries a licence.** That means
no permission to copy or redistribute has been granted in writing, and
"publicly visible" is not the same as "licensed".

This data is a derived work of somebody else's route research. Before an app
carries it, one of these needs to happen:

1. Ask the author for explicit permission to use the polylines, with credit.
2. Replace it with geometry built independently from OpenStreetMap road data.

Note the irony that option 2 is well supported: the OSM wiki records that the
system "has been mapped" using the older PTv1 scheme, so the roads are there
even though the stop nodes are not. Rebuilding route paths from OSM highway
ways would be a larger job and would lose the hand-drawn fidelity of these
lines, but it would be unambiguously licensed.

Until then this is a development-time import. The commit that introduced it
should not ship to users as-is.

## What was done to the data

1. Copied the 52 polylines verbatim from the bundle.
2. Rounded coordinates to 6 decimal places (~0.11 m).
3. Split each route at its **turnaround** — the vertex where cumulative
   distance crosses half the loop — into an out leg and a back leg. The out leg
   is the fareable direction. Splitting relies on these routes being out-and-
   back loops, which was verified for all 31 matched routes: pairing the first
   half of each loop with the reversed second half gives a mean separation
   under 1 km.
4. Matched each site route to a bundled `assets/routes/*.txt` route by
   identity token, keeping the `via` road so that, for example,
   `Catititpan via Dacudao` is not confused with `Catititpan via JP Laurel`.
   31 of 69 bundled routes matched; the 38 that did not are listed in
   `provenance.json`.

## Known disagreement with the bundled `totalKm`

27 of the 31 matched routes have an extracted one-way length within 3 km of the
`totalKm` declared in their `.txt` file. These four do not:

| Route | Extracted one-way | Declared `totalKm` |
| --- | --- | --- |
| `toril` | 17.55 km | 29 km |
| `ulas` | 16.64 km | 11 km |
| `tibungco_via_cabaguio_avenue` | 14.24 km | 18 km |
| `ecoland_subdivision_sm_city_of_davao` | 6.67 km | 10 km |

`kmDelta` is stored per route in `routes.json`. A disagreement means the site
and this project are describing different variants of the route, not that one
is wrong. **These four routes are excluded from distance-based fares** until
someone decides which is authoritative — see `tool/place_stops.py`, which
refuses to emit a distance for them.
