# Street sequences for the 15 numbered Poblacion routes

Compiled from the OpenStreetMap wiki page
[Davao City/Public transportation](https://wiki.openstreetmap.org/wiki/Davao_City/Public_transportation),
revision 3037573, last edited 8 May 2026. Wiki content is
[CC BY-SA 2.0](https://creativecommons.org/licenses/by-sa/2.0/); attribution is
due to the OpenStreetMap Foundation and contributors.

Each route below is a **loop**, so the wiki lists an outbound and a return leg
rather than a single sequence.

## Documented (routes 1–5)

### Route 1
- Marfori Heights – Chinatown via Lopez Jaena, General Luna, Pelayo, Magallanes, C.M. Recto, Emilio Jacinto, Quezon Boulevard
- Chinatown – Marfori Heights via Magsaysay, Chavez, Sobrecary, Guzman, Bangoy, San Pedro, Ilustre

### Route 2
- Ecoland Terminal – Chinatown via Quezon Boulevard
- Chinatown – Ecoland Terminal via Magsaysay, C. Bangoy, Bonifacio, Bolton, San Pedro, Marfori, Datu Bago Drive, Generoso Bridge

### Route 3
- Marfori Heights – Santa Ana via Lopez Jaena, General Luna, Pelayo, Magallanes, C.M. Recto, dela Cruz, Emilio Jacinto, Aurora Quezon, J. Luna, Sales
- Chinatown – Marfori Heights via Magsaysay, Chavez, Sobrecary, Guzman, Bangoy, San Pedro, Ilustre

Marked **loop** on the wiki.

### Route 4
- Claveria – SPMC loop via C.M. Recto, J.P. Laurel, Cabaguio Road, Aurora Quezon, Quezon Boulevard, San Pedro

### Route 5
- Bankerohan – Agdao loop via Magallanes, J.P. Laurel, Magsaysay, Guzman, Sobrecary, Monteverde, F. Bangoy, Leon Garcia, Quezon Boulevard, Aurora Quezon, San Pedro

## Not documented (routes 6–15)

The OSM wiki **does not describe routes 6–15 at all**. No street sequence,
endpoint pair, or relation was found in any public source reviewed. Do not
infer their paths from the `route_1_15.json` polylines alone — a polyline
shows where the drawn line goes, not the stops along it or the distance fare
basis, and the two have already been shown to disagree on other routes.

The wiki's `Relation` column is empty for every numbered route, so no mapped
public-transport relation exists to cross-check against.

## Cross-check against the extracted geometry

For routes 1–5, the sequences above can be compared against the polylines by
running `tool/place_stops.py` against the wiki's street names once stop files
are written. Note that route 4 in the wiki ("Claveria – SPMC") is the same
line as this project's `spmc`-side routes, and route 5 ("Bankerohan – Agdao")
overlaps `maa_agdao` and `maa_bankerohan`, so numbering is a separate scheme
from the named routes and the two should not be merged.
