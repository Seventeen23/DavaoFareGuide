"""Place every bundled stop onto its route polyline, emitting assets/geo/stops.json.

The stop names in assets/routes/*.txt are local jeepney jargon - "BDO Magsaysay
(Near Ateneo De Davao University)", "Bangkas Brgy. Hall", "Puting Bato" - and
OpenStreetMap barely knows them. Measured against the Davao extract, only 47 of
461 unique stop names match an OSM name at all. So a geocode-and-trust pipeline
is not viable: sampling Nominatim on 26 hard names returned 19 hits, of which
"Puting Bato" landed 20 km east and "Marilog" on a farm.

The pipeline is therefore geocode, then *validate against geometry*:

  1. Dedupe stop names across the 69 route files.
  2. Seed from the curated landmark coordinates, then Nominatim for the rest.
     Results are cached, so re-runs are free.
  3. Snap each candidate to the route's own polyline. A stop that is really on
     the route snaps onto it; a stop that was misgeocoded does not.
  4. Reject anything further than SNAP_LIMIT_KM from the polyline. This is what
     catches the bad geocodes, and it is the reason to never trust Nominatim
     here.
  5. For a stop that survives, record its distance along the one-way leg in
     integer decimetres - that is the fare input.
  6. For a stop that fails, interpolate a display position from its kmIndex so
     the map is not full of gaps, and mark it interpolated. An interpolated
     stop never contributes a fare distance.

Regenerate with `python3 tool/place_stops.py`. Network access required for the
first run; afterwards the cache makes it offline.
"""
import json
import math
import os
import re
import sys
import time
import urllib.parse
import urllib.request

ROUTES_DIR = os.path.join("assets", "routes")
GEO_DIR = os.path.join("assets", "geo")
ROUTES_JSON = os.path.join(GEO_DIR, "routes.json")
STOPS_JSON = os.path.join(GEO_DIR, "stops.json")
REVIEW_MD = os.path.join(GEO_DIR, "stops_REVIEW.md")
CACHE = os.path.join("tool", ".cache", "nominatim_stops.json")

NOMINATIM = "https://nominatim.openstreetmap.org/search"
USER_AGENT = "davao-jeepney-stop-placement/0.1 (+build-time data import)"
EARTH_RADIUS_KM = 6371.0088

# How far a geocoded point may sit from the route before we call it a bad
# geocode. Tight enough to reject the "Puting Bato" class of mistake, loose
# enough for a stop that is genuinely on the far side of a wide road.
SNAP_LIMIT_KM = 0.25

# The four routes where the extracted geometry and the curated totalKm disagree
# by more than 3 km. One of the two is describing a different route; until
# somebody decides which, neither is allowed to set a fare.
# See assets/geo/PROVENANCE.md.
MAX_KM_DELTA = 3.0


def haversine_km(a, b):
    lat1, lat2 = math.radians(a[1]), math.radians(b[1])
    d_lat = lat2 - lat1
    d_lng = math.radians(b[0] - a[0])
    h = math.sin(d_lat / 2) ** 2 + math.cos(lat1) * math.cos(lat2) * math.sin(d_lng / 2) ** 2
    return 2 * EARTH_RADIUS_KM * math.asin(math.sqrt(h))


def cumulative_km(coords):
    running = [0.0]
    for i in range(len(coords) - 1):
        running.append(running[-1] + haversine_km(coords[i], coords[i + 1]))
    return running


def snap(point, coords, running):
    """Nearest point on a polyline: (distance_km, distance_along_km)."""
    best_distance = float("inf")
    best_along = 0.0
    for i in range(len(coords) - 1):
        leg = haversine_km(coords[i], coords[i + 1])
        if leg == 0:
            continue
        # Project the query point onto this segment, in a local flat
        # approximation. Over a kilometre of lat/lng the distortion is far
        # below the 250 m gate, and it is much cheaper than 3D vectors.
        cos_lat = math.cos(math.radians(point[1]))
        ax = (point[0] - coords[i][0]) * cos_lat
        ay = point[1] - coords[i][1]
        bx = (coords[i + 1][0] - coords[i][0]) * cos_lat
        by = coords[i + 1][1] - coords[i][1]
        length_sq = bx * bx + by * by
        if length_sq == 0:
            continue
        t = max(0.0, min(1.0, (ax * bx + ay * by) / length_sq))
        closest = [
            coords[i][0] + (coords[i + 1][0] - coords[i][0]) * t,
            coords[i][1] + (coords[i + 1][1] - coords[i][1]) * t,
        ]
        distance = haversine_km(point, closest)
        if distance < best_distance:
            best_distance = distance
            best_along = running[i] + leg * t
    return best_distance, best_along


def load_stops():
    """code_name -> [(name, km_index), ...] in file order."""
    routes = {}
    for filename in sorted(os.listdir(ROUTES_DIR)):
        if not filename.endswith(".txt"):
            continue
        with open(os.path.join(ROUTES_DIR, filename), encoding="utf-8") as handle:
            lines = [line.strip() for line in handle if line.strip()]
        routes[filename[:-4]] = [
            (line.rsplit(",", 1)[0].strip(), int(line.rsplit(",", 1)[1])) for line in lines
        ]
    return routes


def unique_names(stops):
    seen = []
    known = set()
    for entries in stops.values():
        for name, _km in entries:
            if name not in known:
                known.add(name)
                seen.append(name)
    return seen


def geocode(name, cache):
    """Nominatim lookup, rate limited, cached on disk."""
    key = name.strip().lower()
    if key in cache:
        return cache[key]
    query = {
        "q": name,
        "format": "jsonv2",
        "limit": 1,
        "countrycodes": "ph",
        "viewbox": "125.35,7.40,125.80,7.00",
        "bounded": 1,
    }
    url = NOMINATIM + "?" + urllib.parse.urlencode(query)
    try:
        request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
        with urllib.request.urlopen(request, timeout=30) as response:
            results = json.load(response)
        entry = (
            {"lat": float(results[0]["lat"]), "lng": float(results[0]["lon"]), "name": results[0]["name"]}
            if results
            else None
        )
    except Exception as error:  # noqa: BLE001 - a miss must not stop the run
        print(f"    geocode failed for {name!r}: {error}", file=sys.stderr)
        entry = None
    cache[key] = entry
    time.sleep(1.1)  # Nominatim asks for at most one request a second.
    return entry


def as_point(entry):
    """[lng, lat] as floats.

    Nominatim's jsonv2 returns coordinates as strings, and the cache written by
    an earlier version of this script stored them that way, so coerce on read
    rather than trusting either source.
    """
    if entry is None:
        return None
    return [float(entry["lng"]), float(entry["lat"])]


def main():
    os.makedirs(os.path.dirname(CACHE), exist_ok=True)
    with open(ROUTES_JSON, encoding="utf-8") as handle:
        geometry = {r["codeName"]: r for r in json.load(handle)["routes"]}

    stops = load_stops()
    names = unique_names(stops)
    print(f"{len(stops)} routes, {sum(len(v) for v in stops.values())} stop rows, "
          f"{len(names)} unique names")

    cache = {}
    if os.path.exists(CACHE):
        with open(CACHE, encoding="utf-8") as handle:
            cache = json.load(handle)
        print(f"  geocode cache: {len(cache)} entries")

    # Seed coordinates from landmarks we already trust, matched by name.
    seeds = {}
    with open(os.path.join("assets", "landmarks.json"), encoding="utf-8") as handle:
        for entry in json.load(handle)["landmarks"]:
            if entry["source"] in ("curated", "wikidata"):
                seeds.setdefault(entry["name"].strip().lower(), entry)

    print("geocoding stops not covered by a landmark seed ...")
    geocoded = 0
    for index, name in enumerate(names, 1):
        seed = seeds.get(name.strip().lower())
        if seed is not None:
            continue
        if geocode(name, cache) is not None:
            geocoded += 1
        if index % 50 == 0:
            print(f"  {index}/{len(names)}")
    with open(CACHE, "w", encoding="utf-8") as handle:
        json.dump(cache, handle, indent=1)
    print(f"  {geocoded} newly geocoded this run, {len(cache)} cached in total")

    result = {}
    placed = interpolated = rejected = 0
    review = []
    blocked_routes = []
    review.append("| Route | Stop | kmIndex | Snap | Outcome |")
    review.append("| --- | --- | --- | --- | --- |")

    for code_name, entries in stops.items():
        route_geometry = geometry.get(code_name)
        if route_geometry is None:
            continue  # No geometry: nothing to place, kmIndex remains the source.

        # One-way leg only: the fare is measured outbound.
        loop = route_geometry["loop"]
        oneway = loop[: route_geometry["turnaroundIndex"] + 1]
        running = cumulative_km(oneway)
        oneway_km = running[-1]

        # A route whose geometry and curated kmIndex disagree is not trusted
        # to set a fare, so its stops are placed for display only.
        disputed = abs(route_geometry["kmDelta"]) > MAX_KM_DELTA
        if disputed:
            blocked_routes.append((code_name, route_geometry["kmDelta"]))

        declared_max = max(km for _name, km in entries) or 1
        rows = []
        for name, km_index in entries:
            seed = seeds.get(name.strip().lower())
            point = as_point(seed) if seed is not None else as_point(
                cache.get(name.strip().lower())
            )

            distance = dist_dm = None
            display = None
            outcome = "unplaced"
            if point is not None:
                snap_km, along_km = snap(point, oneway, running)
                if snap_km <= SNAP_LIMIT_KM:
                    distance = round(snap_km * 1000)
                    dist_dm = int(round(along_km * 10))
                    display = point
                    outcome = "placed"
                    placed += 1
                else:
                    outcome = f"rejected ({snap_km * 1000:.0f} m off route)"
                    rejected += 1
                    review.append(
                        f"| `{code_name}` | {name} | {km_index} | "
                        f"{snap_km * 1000:.0f} m | geocode rejected, interpolated |"
                    )
            else:
                outcome = "no geocode"
                rejected += 1
                review.append(
                    f"| `{code_name}` | {name} | {km_index} | - | no geocode, interpolated |"
                )

            if display is None:
                # Fall back to a position along the polyline from kmIndex, so
                # the map shows a marker rather than a gap. Display only.
                fraction = (km_index / declared_max) if declared_max else 0.0
                index = min(len(oneway) - 1, max(0, int(fraction * (len(oneway) - 1))))
                display = oneway[index]
                interpolated += 1
                if outcome == "placed":
                    outcome = "placed"

            rows.append(
                {
                    "name": name,
                    "kmIndex": km_index,
                    "lat": round(display[1], 6),
                    "lng": round(display[0], 6),
                    "distDm": dist_dm,
                    "source": "geocoded" if dist_dm is not None else "interpolated",
                }
            )

        result[code_name] = rows

    with open(STOPS_JSON, "w", encoding="utf-8") as handle:
        json.dump({"schemaVersion": 1, "routes": result}, handle, separators=(",", ":"))
        handle.write("\n")

    with open(REVIEW_MD, "w", encoding="utf-8") as handle:
        handle.write(
            "# Stops that were not geocoded onto their route\n\n"
            f"{placed} stops were geocoded and snapped onto their polyline. "
            f"{interpolated} could not be and were interpolated from their\n"
            "kmIndex instead, which is a display position only. An interpolated\n"
            "stop has `distDm: null` and never contributes a fare distance - the\n"
            "trip falls back to the curated whole-kilometre kmIndex.\n\n"
            "These are the ones to check by hand. Most are subdivision gates,\n"
            "barangay halls and small junctions that OSM has never heard of; a few\n"
            "will be genuine mis-geocodes worth correcting.\n\n"
        )
        handle.write("\n".join(review))
        handle.write("\n")
        if blocked_routes:
            handle.write(
                "\n## Routes barred from setting fares\n\n"
                "The extracted one-way length and the curated `totalKm` disagree by\n"
                "more than 3 km, so these routes are placed for display but their\n"
                "stops carry no `distDm`. See `PROVENANCE.md`.\n\n"
            )
            for code_name, delta in sorted(blocked_routes):
                handle.write(f"- `{code_name}` (oneway - declared = {delta:+.2f} km)\n")

    total_rows = sum(len(v) for v in result.values())
    fareable = sum(
        1 for rows in result.values() for row in rows if row["distDm"] is not None
    )
    print(f"\nplaced {placed}, interpolated {interpolated}, rejected {rejected}")
    print(f"wrote {STOPS_JSON}: {len(result)} routes, {total_rows} stops, "
          f"{fareable} with a fare distance")
    print(f"wrote {REVIEW_MD}")
    if blocked_routes:
        print(f"barred from fares: {', '.join(c for c, _ in blocked_routes)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
