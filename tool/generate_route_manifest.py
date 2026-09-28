"""Regenerate lib/data/local/seed/route_manifest.dart from assets/routes/*.txt."""
import os
import re

ROUTES_DIR = os.path.join("assets", "routes")
OUTPUT = os.path.join("lib", "data", "local", "seed", "route_manifest.dart")
LEGACY_CONTROLLER = os.path.join(
    "Old", "LE_Project-master", "app", "src", "main", "java",
    "com", "example", "le_project", "ClassController.java",
)

# Filename typos inherited from the legacy asset bundle.
TYPO_FIX = {
    "catititpan_via_dacudao_avenue": "Catitpan via Dacudao Avenue",
    "catititpan_via_jp_laurel_avenue": "Catitpan via JP Laurel Avenue",
    "maa_bankerohan": "Maa Bankerohan",
    "tibungco_via_cabaguio_avenue": "Tibungco via Cabaguio Avenue",
}

ACRONYM = {"jp": "JP", "sm": "SM", "sm city": "SM City", "dav": "Davao"}
ALWAYS_LOWER = {"via", "and", "of", "the", "at", "de"}
ROMAN = {"i", "ii", "iii", "iv", "v"}


def titleize(word):
    low = word.lower()
    if low in ACRONYM:
        return ACRONYM[low]
    if low in ROMAN:
        return low.upper()
    return word[0].upper() + word[1:]


def pretty(code_name):
    words = code_name.split("_")
    tokens = []
    pending = []

    def flush():
        if pending:
            tokens.append(" ".join(pending))
            pending.clear()

    for word in words:
        low = word.lower()
        if low == "r":
            pending.append("R.")
            continue
        if low in ALWAYS_LOWER:
            flush()
            tokens.append(low)
            continue
        pending.append(titleize(word))
    flush()

    return re.sub(r"\s+", " ", " ".join(tokens)).strip()


def legacy_labels():
    if not os.path.exists(LEGACY_CONTROLLER):
        return {}, []
    source = open(LEGACY_CONTROLLER, encoding="utf-8").read()
    block = source.split("options = {")[1].split("};")[0]
    options = re.findall(r'"([^"]+)"', block)
    mapping = {o.lower().replace(" ", "_"): o for o in options}
    return mapping, sorted(set(mapping) - set(code_names()))


def code_names():
    return sorted(f[:-4] for f in os.listdir(ROUTES_DIR) if f.endswith(".txt"))


def main():
    files = code_names()
    labels, unreachable = legacy_labels()
    rows = [(c, TYPO_FIX.get(c) or pretty(c)) for c in files]

    body = ["const List<RouteManifestEntry> kRouteManifest = ["]
    for code, display in rows:
        escaped = display.replace("\\", "\\\\").replace("'", "\\'")
        body.append(f"  RouteManifestEntry(codeName: '{code}', displayName: '{escaped}'),")
    body += [
        "];",
        "",
        "class RouteManifestEntry {",
        "  const RouteManifestEntry({required this.codeName, required this.displayName});",
        "",
        "  final String codeName;",
        "  final String displayName;",
        "",
        r"  String get assetPath => 'assets/routes/$codeName.txt';",
        "}",
    ]

    header = (
        "/// Generated from the {n} bundled route files in `assets/routes/`.\n"
        "///\n"
        "/// This manifest replaces the hardcoded `ClassController.options` array in the\n"
        "/// legacy Java app, which had two defects: its render loop stopped one entry\n"
        "/// short, making `{last}` unreachable, and {bad} of its labels did not match\n"
        "/// their asset filenames, so those routes failed to load.\n"
        "///\n"
        "/// Regenerate with `python3 tool/generate_route_manifest.py`.\n"
    ).format(n=len(rows), last=files[-1], bad=len(unreachable))

    os.makedirs(os.path.dirname(OUTPUT), exist_ok=True)
    with open(OUTPUT, "w", encoding="utf-8") as handle:
        handle.write(header + "\n".join(body) + "\n")

    print(f"wrote {len(rows)} entries to {OUTPUT}")
    for code, display in rows:
        print(f"  {code:<40} -> {display}")


if __name__ == "__main__":
    main()
