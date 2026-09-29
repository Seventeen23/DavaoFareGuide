"""Build the landmark catalogue in assets/landmarks.json.

Two sources, merged:

  curated  42 hand-placed landmarks from the Commute Davao 3D repository
           (constants/landmarks.ts). Authoritative, but only covers 4 routes.

  osm      Named POIs from OpenStreetMap within 150 m of a route polyline,
           ranked by how much a commuter would recognise them. Covers every
           route that has geometry.

Overpass is asked once for the whole Davao area and the corridor filter is done
locally, which is far cheaper than 31 separate radius queries.

Attribution for the OSM half is owed to the OpenStreetMap Foundation and
contributors under ODbL; see assets/maps/ATTRIBUTION.md.

Regenerate with `python3 tool/fetch_landmarks.py`. Network access required.
"""
import json
import math
import os
import re
import sys
import time
import urllib.parse
import urllib.request

GEO_DIR = os.path.join("assets", "geo")
OUTPUT = os.path.join("assets", "landmarks.json")
CACHE_DIR = os.path.join("tool", ".cache")

RAW_BASE = "https://raw.githubusercontent.com/zopagaduanjr/commute-davao-3d/main/constants"
OVERPASS = "https://overpass-api.de/api/interpreter"
OVERPASS_CACHE = os.path.join(CACHE_DIR, "overpass_davao_pois.json")
CURATED_CACHE = os.path.join(CACHE_DIR, "curated_landmarks.json")
WIKIDATA_CACHE = os.path.join(CACHE_DIR, "wikidata_davao.json")
WIKIDATA_SPARQL = "https://query.wikidata.org/sparql"

USER_AGENT = "davao-jeepney-landmark-import/0.1 (+build-time data import)"
EARTH_RADIUS_KM = 6371.0088

CORRIDOR_KM = 0.15

# Explicit (tag, value) pairs that count as a landmark.
#
# This list is deliberately short. OSM tags Davao as a complete inventory -
# every barangay has a hall, a health centre and a church - so tag presence is
# not a notability signal. Measured against the Davao extract:
#   amenity=bank          -> 63 results, none of them a landmark
#   tourism=hotel         -> 41 inns, dormitories and budget lodging
#   shop=mall             -> "G Store", "KSC", "Novo", a plastic supplier
#   amenity=townhall      -> 19 barangay halls
#   amenity=university    -> 11, and these are real
# Prominence therefore comes from the hand-curated list and from Wikidata.
# Terminals are worth keeping from OSM because a jeepney terminal genuinely is
# where a route begins.
LANDMARK_TAGS = {
    "mall": [("shop", "department_store")],
    "market": [("amenity", "marketplace")],
    "hospital": [("amenity", "hospital")],
    "university": [("amenity", "university")],
    "terminal": [
        ("amenity", "bus_station"),
        ("amenity", "ferry_terminal"),
        ("railway", "station"),
    ],
    "attraction": [("tourism", "attraction")],
}

# Wikidata instance-of classes, mapped to our categories. Anything not listed
# here is not a landmark a commuter would navigate by: rivers, streams,
# mountains, barangays and neighbourhoods are all in Wikidata and all dropped.
WIKIDATA_CLASSES = {
    "university": "university",
    "research university": "university",
    "Catholic university": "university",
    "college": "university",
    "high school": "school",
    "school": "school",
    "academic institution": "school",
    "shopping center": "mall",
    "department store": "mall",
    "hospital": "hospital",
    "international airport": "terminal",
    "commercial traffic aerodrome": "terminal",
    "airport": "terminal",
    "railway station": "terminal",
    "bus station": "terminal",
    "marketplace": "market",
    "highly urbanized city": "civic",
    "consulate general": "civic",
    "city hall": "civic",
    "Buddhist temple": "church",
    "Catholic church": "church",
    "church": "church",
    "mosque": "church",
    "temple": "church",
    "National Historical Commission of the Philippines historical marker": "landmark",
    "historical marker": "landmark",
    "waterfall": "attraction",
    "museum": "attraction",
    "theatre": "attraction",
    "stadium": "attraction",
    "hotel": "hotel",
    "resort": "hotel",
}

# Names that mark a small, single-purpose business even when the tag would
# otherwise qualify. "Animal Bite Center" is tagged amenity=clinic and is not
# somewhere anyone catches a jeepney.
#
# Note there is no trailing \b: these are prefixes ("merchandis" has to match
# inside "Merchandise"), and a word boundary after the group would stop every
# one of them from ever firing.
NAME_BLOCKLIST = re.compile(
    r"\b(?:"
    r"animal bite|blood (?:donat|typ|collect)|diagnostic|polyclinic|"
    r"dental|optical|laborator|lab\b|multi[- ]?care|"
    r"computer|technical|vocational|skills|creche|"
    r"trading|traders|grocer|merchandis|enterprise|business hub|"
    r"dry goods|jeans|shirts|plastic|bodega|retailing|confections|"
    r"general (?:merchan|store|store|trading)|store\b|shop\b|"
    r"collection point|remittance|loading|barangay|district hall|"
    r"plaza &|plaza and|shopping center|hotel\b|inn\b|"
    r"apartments?|suites?|residences?|dormitory|lodging|pension|"
    r"travelers inn|bed|boarding"
    r")",
    re.IGNORECASE,
)

# Not landmarks, just things Wikidata happens to have coordinates for.
NAME_DENYLIST = re.compile(r"^(davao city|davao|del sur|apo island|samal island)$", re.IGNORECASE)

CATEGORY_ORDER = [
    "university", "hospital", "terminal", "market", "mall", "attraction",
    "school", "civic", "hotel", "waterfront", "church", "landmark",
]
MAX_LANDMARKS_PER_ROUTE = 10_000


def classify(tags):
    """Map OSM tags to a category, or None if this is not a landmark."""
    for category, pairs in LANDMARK_TAGS.items():
        for key, value in pairs:
            if tags.get(key) == value:
                return category
    return None


def get(url, tries=3, data=None, headers=None):
    last = None
    merged = {"User-Agent": USER_AGENT}
    if headers:
        merged.update(headers)
    for attempt in range(tries):
        try:
            request = urllib.request.Request(
                url, data=data, headers=merged
            )
            with urllib.request.urlopen(request, timeout=120) as response:
                return response.read()
        except Exception as error:  # noqa: BLE001 - retried, then re-raised
            last = error
            print(f"    retry {attempt + 1}/{tries}: {error}", file=sys.stderr)
            time.sleep(5 * (attempt + 1))
    raise last


def haversine_km(a, b):
    lat1, lat2 = math.radians(a[1]), math.radians(b[1])
    d_lat = lat2 - lat1
    d_lng = math.radians(b[0] - a[0])
    h = math.sin(d_lat / 2) ** 2 + math.cos(lat1) * math.cos(lat2) * math.sin(d_lng / 2) ** 2
    return 2 * EARTH_RADIUS_KM * math.asin(math.sqrt(h))


def load_curated():
    """Parse the 3D repo's landmark tables into {var: {id,label,lat,lng}}."""
    if os.path.exists(CURATED_CACHE):
        with open(CURATED_CACHE, encoding="utf-8") as handle:
            return json.load(handle)["landmarks"]

    print("fetching curated landmarks from the 3D repository ...")
    landmarks_ts = get(f"{RAW_BASE}/landmarks.ts").decode("utf-8")
    landmarks = {}
    for name, lm_id, label, lat, lng in re.findall(
        r"export const (\w+): Landmark = \{\s*"
        r"id: '([^']+)',\s*"
        r"label: '([^']*)',\s*"
        r"latlng: \{ lat: ([-\d.]+), lng: ([-\d.]+) \},?\s*\};",
        landmarks_ts,
    ):
        landmarks[name] = {
            "id": lm_id,
            "name": label,
            "lat": float(lat),
            "lng": float(lng),
        }
    print(f"  parsed {len(landmarks)} curated landmarks")

    os.makedirs(CACHE_DIR, exist_ok=True)
    with open(CURATED_CACHE, "w", encoding="utf-8") as handle:
        json.dump({"landmarks": landmarks}, handle, indent=2)
    return landmarks


def load_osm_pois():
    if os.path.exists(OVERPASS_CACHE):
        with open(OVERPASS_CACHE, encoding="utf-8") as handle:
            return json.load(handle)["elements"]
    print("querying Overpass for named POIs around Davao ...")
    query = """[out:json][timeout:180];
(
  node["name"]["amenity"](7.00,125.35,7.40,125.80);
  node["name"]["shop"](7.00,125.35,7.40,125.80);
  node["name"]["leisure"](7.00,125.35,7.40,125.80);
  node["name"]["office"](7.00,125.35,7.40,125.80);
  node["name"]["healthcare"](7.00,125.35,7.40,125.80);
  node["name"]["school"](7.00,125.35,7.40,125.80);
  node["name"]["university"](7.00,125.35,7.40,125.80);
  node["name"]["tourism"](7.00,125.35,7.40,125.80);
  node["name"]["place"](7.00,125.35,7.40,125.80);
  node["name"]["building"](7.00,125.35,7.40,125.80);
);
out body;"""
    body = get(
        OVERPASS,
        data=urllib.parse.urlencode({"data": query}).encode(),
        headers={"Content-Type": "application/x-www-form-urlencoded"},
    )
    elements = json.loads(body)["elements"]
    print(f"  {len(elements)} named POIs")
    os.makedirs(CACHE_DIR, exist_ok=True)
    with open(OVERPASS_CACHE, "w", encoding="utf-8") as handle:
        json.dump({"elements": elements}, handle)
    return elements


def classify(tags):
    """Map OSM tags to our category, or None if this is not a landmark."""
    for category, pairs in LANDMARK_TAGS.items():
        for key, value in pairs:
            if tags.get(key) == value:
                return category
    return None


CURATED_CATEGORY_HINTS = [
    ("mall", ("mall", "gaisano", "sm ")),
    ("market", ("market", "bankerohan")),
    ("university", ("university", "college", "addu", "usep", "um ")),
    ("hospital", ("hospital", "doctor", "clinic")),
    ("school", ("school", "academy")),
    ("civic", ("city hall", "panlungsod", "public market")),
    ("office", ("office", "land district", "water district")),
    ("waterfront", ("waterfront", "ferry", "azuela", "seawind", "cove")),
    ("church", ("cathedral", "chapel", "church", "parish")),
    ("terminal", ("terminal", "pier", "wharf")),
    ("market", ("bankerohan",)),
]


def classify_curated(name):
    low = name.lower()
    for category, hints in CURATED_CATEGORY_HINTS:
        if any(hint in low for hint in hints):
            return category
    return "landmark"


def load_wikidata():
    """Notable places in Davao City, with coordinates.

    This is the notability signal the project needs and OSM does not provide:
    a barangay hall exists in OSM and in Wikidata only if it matters enough to
    have an article. Q1473 is Davao City; P131* walks the administrative
    hierarchy, P625 is the coordinate and P31 the instance-of class.
    """
    if os.path.exists(WIKIDATA_CACHE):
        with open(WIKIDATA_CACHE, encoding="utf-8") as handle:
            return json.load(handle)["places"]
    print("querying Wikidata for notable places in Davao City ...")
    query = """SELECT ?item ?itemLabel ?coord ?classLabel WHERE {
  ?item wdt:P131* wd:Q1473 .
  ?item wdt:P625 ?coord .
  OPTIONAL { ?item wdt:P31 ?class . }
  SERVICE wikibase:label { bd:serviceParam wikibase:language "en,fil". }
}"""
    body = get(
        WIKIDATA_SPARQL,
        data=urllib.parse.urlencode({"query": query}).encode(),
        headers={
            "Content-Type": "application/x-www-form-urlencoded",
            "Accept": "application/sparql-results+json",
        },
    )
    places = {}
    dropped = 0
    for row in json.loads(body)["results"]["bindings"]:
        category = WIKIDATA_CLASSES.get(row.get("classLabel", {}).get("value", ""))
        if category is None:
            dropped += 1
            continue
        match = re.match(r"Point\(([-\d.]+) ([-\d.]+)\)", row["coord"]["value"])
        if not match:
            continue
        if NAME_DENYLIST.match(row["itemLabel"]["value"].strip()):
            continue
        item_id = row["item"]["value"].rsplit("/", 1)[-1]
        places[item_id] = {
            "id": f"wd-{item_id}",
            "name": row["itemLabel"]["value"],
            "lat": float(match.group(2)),
            "lng": float(match.group(1)),
            "category": category,
        }
    print(f"  {len(places)} notable places ({dropped} rows dropped as rivers, mountains, districts...)")

    os.makedirs(CACHE_DIR, exist_ok=True)
    with open(WIKIDATA_CACHE, "w", encoding="utf-8") as handle:
        json.dump({"places": places}, handle, indent=2)
    return places


def build_grid(route_polylines, cell_deg=0.01):
    """Bucket every polyline vertex into a lat/lng grid.

    Without this the corridor test is 11k POIs x 31 routes x 600 vertices of
    haversine, which does not finish. Each POI then only has to look at the
    vertices in its own cell and the eight around it.
    """
    grid = {}
    for route_index, (code_name, coords) in enumerate(route_polylines.items()):
        for point in coords:
            key = (int(math.floor(point[1] / cell_deg)), int(math.floor(point[0] / cell_deg)))
            grid.setdefault(key, []).append((route_index, point))
    return grid, cell_deg


def routes_within(point, grid, cell_deg, limit_km):
    """Route indices whose polyline passes within [limit_km] of [point]."""
    lat_cell = int(math.floor(point[1] / cell_deg))
    lng_cell = int(math.floor(point[0] / cell_deg))
    reached = set()
    for d_lat in (-1, 0, 1):
        for d_lng in (-1, 0, 1):
            for route_index, vertex in grid.get((lat_cell + d_lat, lng_cell + d_lng), ()):
                if route_index not in reached and haversine_km(point, vertex) <= limit_km:
                    reached.add(route_index)
    return reached


def main():
    os.makedirs(CACHE_DIR, exist_ok=True)
    with open(os.path.join(GEO_DIR, "routes.json"), encoding="utf-8") as handle:
        routes = json.load(handle)["routes"]
    print(f"{len(routes)} routes with geometry")

    curated = load_curated()
    wikidata = load_wikidata()
    pois = load_osm_pois()

    # Curated landmarks are the seeds. They carry no route labels that mean
    # anything here - the 3D repository's route names (Obrero, Sasa, Route 4)
    # do not line up with this project's code names - so they are attached by
    # proximity to the corridor, exactly like the OSM ones.
    catalogue = {}
    for var, lm in curated.items():
        entry = dict(lm)
        entry["source"] = "curated"
        entry["category"] = classify_curated(lm["name"])
        entry["routes"] = []
        catalogue[lm["id"]] = entry
    for item_id, place in wikidata.items():
        catalogue[place["id"]] = {
            "id": place["id"],
            "name": place["name"],
            "lat": place["lat"],
            "lng": place["lng"],
            "source": "wikidata",
            "category": place["category"],
            "routes": [],
        }

    route_polylines = {r["codeName"]: r["loop"] for r in routes}
    all_coords = [c for loop in route_polylines.values() for c in loop]
    lats = [c[1] for c in all_coords]
    lngs = [c[0] for c in all_coords]
    print(f"corridor bbox lat {min(lats):.4f}..{max(lats):.4f} lng {min(lngs):.4f}..{max(lngs):.4f}")

    grid, cell_deg = build_grid(route_polylines)
    route_names = list(route_polylines.keys())

    curated_routes = 0
    for entry in catalogue.values():
        nearby = routes_within([entry["lng"], entry["lat"]], grid, cell_deg, CORRIDOR_KM)
        entry["routes"] = [route_names[index] for index in nearby]
        curated_routes += 1 if nearby else 0
    print(f"{curated_routes}/{len(catalogue)} curated + wikidata landmarks sit on a corridor")

    kept = 0
    skipped_noise = 0
    # Seed the dedupe with the curated and Wikidata names, so an OSM node for a
    # place we already have ("Gaisano Mall of Davao") merges into that entry
    # instead of appearing a second time.
    seen_names = {}
    for entry in catalogue.values():
        seen_names.setdefault(entry["name"].strip().lower(), entry["id"])
    for element in pois:
        if "lat" not in element:
            continue
        tags = element.get("tags", {})
        name = tags.get("name")
        if not name:
            continue
        category = classify(tags)
        if category is None:
            continue
        if NAME_BLOCKLIST.search(name) or NAME_DENYLIST.match(name.strip()):
            skipped_noise += 1
            continue
        point = [element["lon"], element["lat"]]
        if not (min(lats) - 0.01 <= point[1] <= max(lats) + 0.01):
            continue
        if not (min(lngs) - 0.01 <= point[0] <= max(lngs) + 0.01):
            continue

        nearby = routes_within(point, grid, cell_deg, CORRIDOR_KM)
        if not nearby:
            continue

        # Two nodes of the same place ("Computer Sense College" x2) would
        # otherwise occupy two slots on the same route.
        key_name = name.strip().lower()
        if key_name in seen_names:
            for other in nearby:
                if route_names[other] not in catalogue[seen_names[key_name]]["routes"]:
                    catalogue[seen_names[key_name]]["routes"].append(route_names[other])
            continue
        key = f"osm-{element['type']}-{element['id']}"
        entry = {
            "id": key,
            "name": name,
            "lat": element["lat"],
            "lng": element["lon"],
            "source": "osm",
            "category": category,
            "routes": [route_names[index] for index in nearby],
        }
        catalogue[key] = entry
        seen_names[key_name] = key
        kept += 1
    print(
        f"{kept} OSM landmarks inside a corridor"
        f" ({skipped_noise} dropped as small businesses, {len(seen_names)} distinct names)"
    )
    # Trim each route to its most recognisable landmarks.
    per_route = {}
    for entry in catalogue.values():
        if not entry["routes"]:
            continue
        if entry["source"] == "curated":
            rank = 0
        elif entry["category"] in CATEGORY_ORDER:
            rank = CATEGORY_ORDER.index(entry["category"]) + 1
        else:
            rank = 99
        for code_name in entry["routes"]:
            per_route.setdefault(code_name, []).append((rank, entry["name"], entry))

    dropped = 0
    for code_name, entries in per_route.items():
        entries.sort(key=lambda item: (item[0], item[1]))
        keep_ids = {entry["id"] for _, _, entry in entries[:MAX_LANDMARKS_PER_ROUTE]}
        dropped += len(entries) - len(keep_ids)
        for entry in list(catalogue.values()):
            if code_name in entry["routes"] and entry["id"] not in keep_ids:
                entry["routes"].remove(code_name)
                if not entry["routes"]:
                    del catalogue[entry["id"]]

    landmarks = sorted(catalogue.values(), key=lambda e: e["name"].lower())
    for entry in landmarks:
        entry["routes"] = sorted(entry["routes"])

    with open(OUTPUT, "w", encoding="utf-8") as handle:
        json.dump(
            {
                "schemaVersion": 1,
                "generatedAt": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
                "corridorKm": CORRIDOR_KM,
                "landmarks": landmarks,
            },
            handle,
            indent=1,
        )
        handle.write("\n")

    counts = {}
    for entry in landmarks:
        counts[entry["category"]] = counts.get(entry["category"], 0) + 1
    print(f"\nwrote {OUTPUT}: {len(landmarks)} landmarks ({dropped} dropped as low-value)")
    for category, count in sorted(counts.items(), key=lambda kv: -kv[1]):
        print(f"  {category:12} {count}")
    covered = {c for entry in landmarks for c in entry["routes"]}
    print(f"routes with at least one landmark: {len(covered)}/{len(routes)}")

    # The curated and Wikidata halves are trustworthy. The OSM half is a
    # heuristic, so list it for a human to confirm or delete.
    review = os.path.join("assets", "landmarks_REVIEW.md")
    auto = [e for e in landmarks if e["source"] == "osm"]
    with open(review, "w", encoding="utf-8") as handle:
        handle.write(
            "# Landmarks needing a human decision\n\n"
            f"{len(auto)} of the {len(landmarks)} landmarks were picked automatically from\n"
            "OpenStreetMap tags. They are inside a route corridor and survived a\n"
            "keyword filter, but nobody has confirmed a commuter would recognise them.\n"
            "Delete the rows you disagree with here and re-run the script.\n\n"
            "The other two thirds are either hand-curated (`source: curated`) or have a\n"
            "Wikipedia article (`source: wikidata`) and need no review.\n\n"
            "| Landmark | Category | Routes | OSM id |\n"
            "| --- | --- | --- | --- |\n"
        )
        for entry in sorted(auto, key=lambda e: (e["category"], e["name"])):
            routes_cell = ", ".join(f"`{r}`" for r in entry["routes"][:4])
            if len(entry["routes"]) > 4:
                routes_cell += f" +{len(entry['routes']) - 4}"
            handle.write(
                f"| {entry['name']} | {entry['category']} | {routes_cell} | `{entry['id']}` |\n"
            )
    print(f"wrote {review}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
