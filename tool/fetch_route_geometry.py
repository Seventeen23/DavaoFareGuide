"""Extract Davao jeepney route polylines from commutedavao.com into assets/geo/.

The site is an Angular + Mapbox app whose `main.*.js` bundle embeds a GeoJSON
`FeatureCollection` of 52 routes as `LineString`s. The geometry is hand-drawn
onto the road network, so it follows real streets rather than being computed as
a shortest path. Each route is an out-and-back loop, which is why the loop
length is roughly twice a route's one-way distance.

Writes:
  assets/geo/routes.json                 the 31 routes that match a bundled route
  assets/geo/unverified/route_1_15.json the 15 numbered Poblacion routes
  assets/geo/provenance.json             source, bundle hash, fetch date, licence

Regenerate with `python3 tool/fetch_route_geometry.py`. Network access is
required; the output is committed so the app never needs it.
"""
import json
import math
import os
import re
import sys
import time
import urllib.request

SITE = "https://commutedavao.com"
ROUTES_DIR = os.path.join("assets", "routes")
GEO_DIR = os.path.join("assets", "geo")
UNVERIFIED_DIR = os.path.join(GEO_DIR, "unverified")
ROUTES_JSON = os.path.join(GEO_DIR, "routes.json")
PROVENANCE_JSON = os.path.join(GEO_DIR, "provenance.json")
UNVERIFIED_JSON = os.path.join(UNVERIFIED_DIR, "route_1_15.json")

USER_AGENT = "davao-jeepney-route-geometry/0.1 (+build-time data import)"
EARTH_RADIUS_KM = 6371.0088

# Tokens that carry no identity: generic street words, and the "via" marker.
DROP_TOKENS = {
    "route", "via", "avenue", "ave", "av", "street", "st", "road", "rd",
    "boulevard", "blvd", "highway", "hiway", "drive", "lane", "subd",
    "subdivision", "heights", "homes", "village", "zone", "the", "of", "and",
    "at", "de", "del", "sm", "city", "davao", "san", "santo", "santa", "sta",
}
# The site writes "SM City Davao" and "Panacan - SM City Davao" as one route.
# Nothing else depends on these, so they stay as ordinary tokens.


def get(url, tries=3):
    last = None
    for attempt in range(tries):
        try:
            request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
            with urllib.request.urlopen(request, timeout=60) as response:
                return response.read()
        except Exception as error:  # noqa: BLE001 - retried, then re-raised
            last = error
            time.sleep(3 * (attempt + 1))
    raise last


def haversine_km(a, b):
    """Great-circle distance between two [lng, lat] pairs."""
    lat1, lat2 = math.radians(a[1]), math.radians(b[1])
    d_lat = lat2 - lat1
    d_lng = math.radians(b[0] - a[0])
    h = math.sin(d_lat / 2) ** 2 + math.cos(lat1) * math.cos(lat2) * math.sin(d_lng / 2) ** 2
    return 2 * EARTH_RADIUS_KM * math.asin(math.sqrt(h))


def length_km(coords):
    return sum(haversine_km(coords[i], coords[i + 1]) for i in range(len(coords) - 1))


def cumulative_km(coords):
    running = [0.0]
    for i in range(len(coords) - 1):
        running.append(running[-1] + haversine_km(coords[i], coords[i + 1]))
    return running


def split_round_trip(coords):
    """Cut an out-and-back loop at its turnaround into an out and a back leg.

    The turnaround is the vertex whose cumulative distance is closest to half
    the loop, i.e. where the "distance already travelled" and the "distance
    still to run back" curves cross. On these routes that lands within a few
    percent of the midpoint.
    """
    running = cumulative_km(coords)
    total = running[-1]
    if total <= 0:
        return coords, list(reversed(coords)), 0
    pivot = min(range(len(coords)), key=lambda i: abs(2 * running[i] - total))
    return coords[: pivot + 1], list(reversed(coords[pivot:])), pivot


def js_literal_to_json(text):
    """Turn a minified JS object literal into JSON by quoting bare keys.

    Only walks outside string literals, so a key-shaped substring inside a
    value cannot be rewritten. `json.loads` still validates the result, so a
    mis-parse fails loudly rather than silently changing the data.
    """
    out = []
    index = 0
    length = len(text)
    while index < length:
        char = text[index]
        if char == '"':
            end = index + 1
            while end < length:
                if text[end] == "\\":
                    end += 2
                    continue
                if text[end] == '"':
                    break
                end += 1
            out.append(text[index : end + 1])
            index = end + 1
            continue
        if char.isalpha() or char in "_$":
            end = index
            while end < length and (text[end].isalnum() or text[end] in "_$"):
                end += 1
            word = text[index:end]
            probe = end
            while probe < length and text[probe].isspace():
                probe += 1
            if probe < length and text[probe] == ":":
                out.append('"' + word + '":')
                index = probe + 1
            else:
                out.append(word)
                index = end
            continue
        out.append(char)
        index += 1
    return "".join(out)


def find_feature_collections(bundle):
    """Brace-match every `type:"FeatureCollection"` literal holding named routes."""
    marker = '{type:"FeatureCollection",features:['
    found = []
    for match in re.finditer(re.escape(marker), bundle):
        start = match.start()
        depth = 0
        in_string = False
        index = start
        while index < len(bundle):
            char = bundle[index]
            if in_string:
                if char == "\\":
                    index += 2
                    continue
                if char == '"':
                    in_string = False
            elif char == '"':
                in_string = True
            elif char == "{":
                depth += 1
            elif char == "}":
                depth -= 1
                if depth == 0:
                    fragment = bundle[start : index + 1]
                    if 'properties:{name:' in fragment:
                        found.append(fragment)
                    break
            index += 1
    return found


def match_key(code_name):
    """Identity tokens for a bundled route, used to pair it with a site route.

    The `via` road is deliberately kept: it is what separates `Catititpan via
    Dacudao` from `Catititpan via JP Laurel`, and dropping it would make the
    two indistinguishable.
    """
    tokens = [t for t in re.split(r"[^a-z0-9]+", code_name.lower()) if t]
    kept = [t for t in tokens if t not in DROP_TOKENS]
    return tuple(kept) if kept else tuple(tokens)


def site_key(name):
    tokens = [t for t in re.split(r"[^a-z0-9]+", name.lower()) if t]
    kept = [t for t in tokens if t not in DROP_TOKENS]
    return tuple(kept) if kept else tuple(tokens)


def load_bundled_routes():
    """code_name -> {'display_km': int, 'stops': [str]} for assets/routes/*.txt."""
    routes = {}
    for filename in sorted(os.listdir(ROUTES_DIR)):
        if not filename.endswith(".txt"):
            continue
        code_name = filename[:-4]
        with open(os.path.join(ROUTES_DIR, filename), encoding="utf-8") as handle:
            lines = [line.strip() for line in handle if line.strip()]
        stops = [line.rsplit(",", 1)[0].strip() for line in lines]
        # The parser splits on the last comma, so the last line carries the total.
        routes[code_name] = {"stops": stops, "total_km": int(lines[-1].rsplit(",", 1)[1])}
    return routes


def round_coords(coords):
    """Six decimals is ~0.11 m, well under GPS error, and keeps the asset small."""
    return [[round(c[0], 6), round(c[1], 6)] for c in coords]


def main():
    print(f"fetching {SITE}/ ...")
    index_html = get(SITE + "/").decode("utf-8", "replace")
    bundle_match = re.search(r'src="(main\.[0-9a-f]+\.js)"', index_html)
    if not bundle_match:
        print("could not find main.*.js in index.html", file=sys.stderr)
        return 1
    bundle_name = bundle_match.group(1)
    print(f"  bundle: {bundle_name}")
    bundle = get(f"{SITE}/{bundle_name}").decode("utf-8", "replace")
    print(f"  bytes:  {len(bundle)}")

    collections = find_feature_collections(bundle)
    if not collections:
        print("no route FeatureCollection found - upstream layout changed", file=sys.stderr)
        return 1
    biggest = max(collections, key=len)
    print(f"  route collections: {len(collections)} (largest {len(biggest)} bytes)")

    parsed = json.loads(js_literal_to_json(biggest))
    site_routes = {}
    for feature in parsed["features"]:
        name = feature["properties"]["name"]
        coords = feature["geometry"]["coordinates"]
        if feature["geometry"]["type"] != "LineString" or len(coords) < 2:
            continue
        site_routes[name] = {
            "coords": coords,
            "color": feature["properties"].get("color"),
        }
    print(f"  parsed routes:    {len(site_routes)}")

    by_key = {}
    for name, data in site_routes.items():
        by_key.setdefault(site_key(name), []).append(name)

    bundled = load_bundled_routes()

    matched, unmatched, ambiguous = [], [], []
    for code_name, info in sorted(bundled.items()):
        candidates = by_key.get(match_key(code_name), [])
        if len(candidates) == 1:
            matched.append((code_name, candidates[0], "exact"))
        elif len(candidates) > 1:
            ambiguous.append((code_name, candidates))
        else:
            unmatched.append(code_name)

    print(f"\nmatched {len(matched)}, ambiguous {len(ambiguous)}, unmatched {len(unmatched)}")
    for code_name, candidates in ambiguous:
        print(f"  AMBIGUOUS {code_name} -> {candidates}")

    os.makedirs(UNVERIFIED_DIR, exist_ok=True)

    verified = []
    for code_name, site_name, confidence in matched:
        coords = site_routes[site_name]["coords"]
        out, back, pivot = split_round_trip(coords)
        oneway_km = length_km(out)
        declared_km = bundled[code_name]["total_km"]
        verified.append(
            {
                "codeName": code_name,
                "siteName": site_name,
                "match": confidence,
                "loop": round_coords(coords),
                "turnaroundIndex": pivot,
                "onewayKm": round(oneway_km, 3),
                "loopKm": round(length_km(coords), 3),
                "declaredKm": declared_km,
                "kmDelta": round(oneway_km - declared_km, 3),
            }
        )
        flag = "  <-- declared totalKm differs a lot" if abs(oneway_km - declared_km) > 3 else ""
        print(
            f"  {code_name:<40} {len(out):>5} pts  oneway {oneway_km:7.2f} km"
            f"  declared {declared_km:>3} km{flag}"
        )

    numbered = {}
    for name, data in site_routes.items():
        if re.fullmatch(r"Route \d+", name):
            coords = data["coords"]
            out, _back, _pivot = split_round_trip(coords)
            numbered[name] = {
                "siteName": name,
                "loop": round_coords(coords),
                "turnaroundIndex": _pivot,
                "onewayKm": round(length_km(out), 3),
                "loopKm": round(length_km(coords), 3),
            }

    os.makedirs(GEO_DIR, exist_ok=True)
    with open(ROUTES_JSON, "w", encoding="utf-8") as handle:
        json.dump(
            {"schemaVersion": 1, "routes": verified},
            handle,
            separators=(",", ":"),
        )
        handle.write("\n")

    with open(UNVERIFIED_JSON, "w", encoding="utf-8") as handle:
        json.dump(
            {
                "schemaVersion": 1,
                "warning": (
                    "UNVERIFIED. Geometry only - these 15 numbered Poblacion routes "
                    "have no stop list, no kmIndex and no fare basis, and must not "
                    "be shown to users until checked against city documents."
                ),
                "routes": numbered,
            },
            handle,
            indent=2,
        )
        handle.write("\n")

    provenance = {
        "schemaVersion": 1,
        "fetchedAt": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        "source": {
            "site": SITE,
            "bundle": f"{SITE}/{bundle_name}",
            "routeCount": len(site_routes),
            "author": "Commute Davao, by Zaldy Pagaduan Jr.",
            "authorRepo": "https://github.com/zopagaduanjr/commute-davao-3d",
        },
        "licence": {
            "status": "none-found",
            "note": (
                "Neither the site nor the author's repository carries a licence. "
                "Redistribution rights are unconfirmed - see PROVENANCE.md before "
                "publishing."
            ),
        },
        "derivation": (
            "Polylines were copied from the site's minified JS bundle, then split "
            "at the turnaround of each out-and-back loop to produce the one-way leg "
            "used for distance."
        ),
        "unverifiedCount": len(numbered),
        "verifiedCount": len(verified),
        "unmatchedBundledRoutes": unmatched,
    }
    with open(PROVENANCE_JSON, "w", encoding="utf-8") as handle:
        json.dump(provenance, handle, indent=2)
        handle.write("\n")

    print(f"\nwrote {ROUTES_JSON} ({len(verified)} routes)")
    print(f"wrote {UNVERIFIED_JSON} ({len(numbered)} unverified routes)")
    print(f"wrote {PROVENANCE_JSON}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
