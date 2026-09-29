# Stops that were not geocoded onto their route

119 stops were geocoded and snapped onto their polyline. 343 could not be and were interpolated from their
kmIndex instead, which is a display position only. An interpolated
stop has `distDm: null` and never contributes a fare distance - the
trip falls back to the curated whole-kilometre kmIndex.

These are the ones to check by hand. Most are subdivision gates,
barangay halls and small junctions that OSM has never heard of; a few
will be genuine mis-geocodes worth correcting.

| Route | Stop | kmIndex | Snap | Outcome |
| --- | --- | --- | --- | --- |
| `bago_aplaya` | DXSS (Bangkal) | 4 | - | no geocode, interpolated |
| `bago_aplaya` | ABS-CBN Junction | 7 | - | no geocode, interpolated |
| `bago_aplaya` | SM City Davao | 8 | 253 m | geocode rejected, interpolated |
| `bago_aplaya` | Ecoland Terminal Crossing | 9 | - | no geocode, interpolated |
| `bangkal` | Bangkal | 0 | 29627 m | geocode rejected, interpolated |
| `bangkal` | DLC Bldg. (McArthur Hi-way,Balusong) | 2 | - | no geocode, interpolated |
| `bangkal` | San Antonio Vill (infront GSIS) | 3 | - | no geocode, interpolated |
| `bangkal` | Davao Exec. Homes (Quimpo Blvd.) | 4 | - | no geocode, interpolated |
| `bangkal` | SM City Davao | 5 | 253 m | geocode rejected, interpolated |
| `bangkal` | Agro School Foundation | 7 | - | no geocode, interpolated |
| `bangkal` | Guerrero cor. Magsaysay Ave. | 10 | - | no geocode, interpolated |
| `bangkal` | F. Bangoy cor. Magsaysay Ave. | 11 | - | no geocode, interpolated |
| `bangkal` | Magsaysay Ave. (Park) | 12 | - | no geocode, interpolated |
| `buhangin_via_dacudao` | Buhangin | 0 | 8165 m | geocode rejected, interpolated |
| `buhangin_via_dacudao` | Orange Groove Hotel | 1 | - | no geocode, interpolated |
| `buhangin_via_dacudao` | Watusi Street | 2 | 260 m | geocode rejected, interpolated |
| `buhangin_via_dacudao` | Dacudao Fly Over (TOYOBAC) | 3 | - | no geocode, interpolated |
| `buhangin_via_dacudao` | Vinzon cor. Cabaguio Ave. | 4 | - | no geocode, interpolated |
| `buhangin_via_dacudao` | L. Garcia St. (Sunrise) | 5 | - | no geocode, interpolated |
| `buhangin_via_dacudao` | Magsaysay Avenue (Park) | 6 | - | no geocode, interpolated |
| `buhangin_via_jp_laurel_avenue` | Buhangin | 0 | 8165 m | geocode rejected, interpolated |
| `buhangin_via_jp_laurel_avenue` | Watusi St. (Buhangin) | 2 | 260 m | geocode rejected, interpolated |
| `buhangin_via_jp_laurel_avenue` | Dacudao Fly Over (Entrance) | 3 | - | no geocode, interpolated |
| `buhangin_via_jp_laurel_avenue` | Cor. Palma Gil St. (Obrero) | 5 | - | no geocode, interpolated |
| `bunawan_via_buhangin` | Bunawan | 0 | 3804 m | geocode rejected, interpolated |
| `bunawan_via_buhangin` | Bunawan Plywood | 2 | - | no geocode, interpolated |
| `bunawan_via_buhangin` | Northern Hills Sawmill | 3 | - | no geocode, interpolated |
| `bunawan_via_buhangin` | Mahayag | 4 | 2449 m | geocode rejected, interpolated |
| `bunawan_via_buhangin` | Manpower RMTC | 5 | - | no geocode, interpolated |
| `bunawan_via_buhangin` | Davao Extension Lumber | 6 | - | no geocode, interpolated |
| `bunawan_via_buhangin` | Tibungco Elem. School | 7 | - | no geocode, interpolated |
| `bunawan_via_buhangin` | U.M. College (Ilang) | 8 | - | no geocode, interpolated |
| `bunawan_via_buhangin` | Bacnotan Cement | 9 | - | no geocode, interpolated |
| `bunawan_via_buhangin` | Mindanao Coco Corp. | 11 | - | no geocode, interpolated |
| `bunawan_via_buhangin` | Land Mark III | 12 | - | no geocode, interpolated |
| `bunawan_via_buhangin` | Davao Int'l Airport | 13 | - | no geocode, interpolated |
| `bunawan_via_buhangin` | R. Tecson Const. (Km. 8) | 15 | - | no geocode, interpolated |
| `bunawan_via_buhangin` | Caltex Gasoline Station | 16 | - | no geocode, interpolated |
| `bunawan_via_buhangin` | Waling-Waling St. (Diversion Road) | 17 | - | no geocode, interpolated |
| `bunawan_via_buhangin` | Pag-asa St. (Buhangin Road) | 18 | - | no geocode, interpolated |
| `bunawan_via_buhangin` | Dacudao Fly Over | 19 | - | no geocode, interpolated |
| `bunawan_via_buhangin` | Cerbantes/Veloso Sts. | 20 | - | no geocode, interpolated |
| `bunawan_via_buhangin` | Cor. Villa Abrille/Guerrero Sts. | 21 | - | no geocode, interpolated |
| `bunawan_via_buhangin` | Roxas/Gomez Sts. | 22 | - | no geocode, interpolated |
| `bunawan_via_sasa` | Bunawan | 0 | 3804 m | geocode rejected, interpolated |
| `bunawan_via_sasa` | Bunawan Plywood | 2 | - | no geocode, interpolated |
| `bunawan_via_sasa` | Northern Hills Sawmill | 3 | - | no geocode, interpolated |
| `bunawan_via_sasa` | Mahayag | 4 | 2449 m | geocode rejected, interpolated |
| `bunawan_via_sasa` | Manpower RMTC | 5 | - | no geocode, interpolated |
| `bunawan_via_sasa` | Davao Extension Lumber | 6 | - | no geocode, interpolated |
| `bunawan_via_sasa` | Tibungco Elem. School | 7 | - | no geocode, interpolated |
| `bunawan_via_sasa` | U.M. College (Ilang) | 8 | - | no geocode, interpolated |
| `bunawan_via_sasa` | Ilang Basketball Court | 9 | - | no geocode, interpolated |
| `bunawan_via_sasa` | Bacnotan Cement | 10 | - | no geocode, interpolated |
| `bunawan_via_sasa` | Sagrada Familia St. (Km. 13) | 12 | - | no geocode, interpolated |
| `bunawan_via_sasa` | Going to Babak | 13 | - | no geocode, interpolated |
| `bunawan_via_sasa` | Marginal Wharf | 14 | - | no geocode, interpolated |
| `bunawan_via_sasa` | Old Crossing Airport | 15 | - | no geocode, interpolated |
| `bunawan_via_sasa` | Hizon Elem. School | 16 | - | no geocode, interpolated |
| `bunawan_via_sasa` | Alcantara & Sons | 17 | 788 m | geocode rejected, interpolated |
| `bunawan_via_sasa` | Crossing Ubalde | 18 | - | no geocode, interpolated |
| `bunawan_via_sasa` | Jacinto Crossing | 21 | - | no geocode, interpolated |
| `calinan` | Magsaysay/Villafuerte | 0 | - | no geocode, interpolated |
| `calinan` | Angel Funeral Parlor | 1 | - | no geocode, interpolated |
| `calinan` | San Roque Chapel | 2 | 3343 m | geocode rejected, interpolated |
| `calinan` | Puting Bato | 4 | 17062 m | geocode rejected, interpolated |
| `calinan` | Catallas Residence | 6 | - | no geocode, interpolated |
| `calinan` | Talomo River Bridge | 7 | 5121 m | geocode rejected, interpolated |
| `calinan` | Quarry Bridge | 8 | 606 m | geocode rejected, interpolated |
| `calinan` | Old Tagakpan Road | 9 | 288 m | geocode rejected, interpolated |
| `calinan` | Dacudao Farm | 11 | - | no geocode, interpolated |
| `calinan` | Mintal Elem. School | 12 | - | no geocode, interpolated |
| `calinan` | Mintal Catholic Church | 13 | - | no geocode, interpolated |
| `calinan` | Trese Cat. Pequeno | 14 | - | no geocode, interpolated |
| `calinan` | Crossing Cat. Pequeno | 15 | - | no geocode, interpolated |
| `calinan` | Dayrit Farm | 16 | - | no geocode, interpolated |
| `calinan` | Reyes Residence | 17 | - | no geocode, interpolated |
| `calinan` | Cal's Residence Shop | 18 | - | no geocode, interpolated |
| `calinan` | DXSS | 20 | - | no geocode, interpolated |
| `calinan` | ABS-CBN Junction | 23 | - | no geocode, interpolated |
| `calinan` | Kar Asia Bldg. | 24 | - | no geocode, interpolated |
| `calinan` | Crossing Maa | 25 | 5078 m | geocode rejected, interpolated |
| `calinan` | Generoso Bridge | 26 | 951 m | geocode rejected, interpolated |
| `calinan` | El Gusto Family Lodge | 27 | - | no geocode, interpolated |
| `calinan` | Suico Center Recto | 28 | - | no geocode, interpolated |
| `calinan` | Madrazo Fruit Stand | 29 | - | no geocode, interpolated |
| `calinan` | Davao Doctors Hospital | 30 | 1126 m | geocode rejected, interpolated |
| `calinan` | Bankerohan | 31 | 1384 m | geocode rejected, interpolated |
| `catalunan_grande` | Catalunan Grande | 3 | 750 m | geocode rejected, interpolated |
| `catalunan_grande` | Matina (ABS-CBN Junction) | 6 | - | no geocode, interpolated |
| `catalunan_grande` | Ecoland Terminal Crossing | 8 | - | no geocode, interpolated |
| `catalunan_grande` | San Pedro Extension (PNB) | 9 | - | no geocode, interpolated |
| `catalunan_grande` | Roxas Avenue | 10 | 485 m | geocode rejected, interpolated |
| `ecoland_subdivision_sm_city_of_davao` | Philippine Banking Institute (Near CSC) | 1 | - | no geocode, interpolated |
| `ecoland_subdivision_sm_city_of_davao` | Tecarro Technical Institute | 3 | - | no geocode, interpolated |
| `ecoland_subdivision_sm_city_of_davao` | Oro Derm Bldg. (Corner Rizal Street/Claveria) | 5 | - | no geocode, interpolated |
| `ecoland_subdivision_sm_city_of_davao` | BDO Magsaysay (Near Ateneo De Davao University) | 6 | - | no geocode, interpolated |
| `ecoland_subdivision_sm_city_of_davao` | NCCC Uyanguren | 7 | 4698 m | geocode rejected, interpolated |
| `ecoland_subdivision_sm_city_of_davao` | Suazo Street Corner Quezon Boulevard | 8 | - | no geocode, interpolated |
| `ecoland_subdivision_sm_city_of_davao` | Rizal Street Extension Corner Quezon Boulevard | 9 | - | no geocode, interpolated |
| `ecoland_subdivision_sm_city_of_davao` | Bolton Bridge II | 10 | - | no geocode, interpolated |
| `emily_homes` | Emily Homes | 3 | 265 m | geocode rejected, interpolated |
| `emily_homes` | Watusi St. (Buhangin Road) | 4 | - | no geocode, interpolated |
| `emily_homes` | Cor. Palma Gil St. (Obrero) | 6 | - | no geocode, interpolated |
| `emily_homes` | Bonifacio St. | 8 | 2564 m | geocode rejected, interpolated |
| `jade_valley` | Jade Valley | 0 | 386 m | geocode rejected, interpolated |
| `jade_valley` | Spring Valley (Crossing) | 2 | - | no geocode, interpolated |
| `jade_valley` | Metro Bank (Buhangin) | 3 | - | no geocode, interpolated |
| `jade_valley` | Fly Over (Dacudao) | 4 | - | no geocode, interpolated |
| `jade_valley` | Cor. Palma Gil (Obrero) | 6 | - | no geocode, interpolated |
| `jade_valley` | City Health (Magallanes) | 9 | 436 m | geocode rejected, interpolated |
| `lasang_via_buhangin` | Crossing Tambongan | 1 | - | no geocode, interpolated |
| `lasang_via_buhangin` | Crossing Lelawan | 2 | - | no geocode, interpolated |
| `lasang_via_buhangin` | Baclayon Plantation | 3 | - | no geocode, interpolated |
| `lasang_via_buhangin` | Bunawan Plywood | 4 | - | no geocode, interpolated |
| `lasang_via_buhangin` | Bunawan Elem. School | 5 | - | no geocode, interpolated |
| `lasang_via_buhangin` | Before Bunawan Elem. School | 6 | - | no geocode, interpolated |
| `lasang_via_buhangin` | Northern Hills Sawmill | 7 | - | no geocode, interpolated |
| `lasang_via_buhangin` | Mahayag | 8 | 2449 m | geocode rejected, interpolated |
| `lasang_via_buhangin` | Manpower RMTC | 9 | - | no geocode, interpolated |
| `lasang_via_buhangin` | Davao Extension Lumber | 10 | - | no geocode, interpolated |
| `lasang_via_buhangin` | Tibungco Elem. School | 11 | - | no geocode, interpolated |
| `lasang_via_buhangin` | U.M. College (Ilang) | 12 | - | no geocode, interpolated |
| `lasang_via_buhangin` | Bacnotan Cement | 13 | - | no geocode, interpolated |
| `lasang_via_buhangin` | Sarmiento | 14 | 305 m | geocode rejected, interpolated |
| `lasang_via_buhangin` | Mindanao Coco Corp. | 16 | - | no geocode, interpolated |
| `lasang_via_buhangin` | Land Mark III | 17 | - | no geocode, interpolated |
| `lasang_via_buhangin` | Davao Int'l Airport | 18 | - | no geocode, interpolated |
| `lasang_via_buhangin` | R. Tecson Const. (Km. 8) | 19 | - | no geocode, interpolated |
| `lasang_via_buhangin` | Caltex Gasoline Station | 20 | - | no geocode, interpolated |
| `lasang_via_buhangin` | Waling-Waling St. (Diversion Road) | 21 | - | no geocode, interpolated |
| `lasang_via_buhangin` | Pag-asa St. (Buhangin Road) | 22 | - | no geocode, interpolated |
| `lasang_via_buhangin` | Dacudao Fly Over | 23 | - | no geocode, interpolated |
| `lasang_via_buhangin` | Cerbantes/Veloso Sts. | 24 | - | no geocode, interpolated |
| `lasang_via_buhangin` | Garden of Oases (Porras St.) | 25 | - | no geocode, interpolated |
| `lasang_via_buhangin` | Cor. Villa Abrille/Guerrero Sts. | 26 | - | no geocode, interpolated |
| `lasang_via_buhangin` | Roxas/Gomez Sts. | 27 | - | no geocode, interpolated |
| `lasang_via_sasa` | Crossing Tambongan | 1 | - | no geocode, interpolated |
| `lasang_via_sasa` | Crossing Lelawan | 2 | - | no geocode, interpolated |
| `lasang_via_sasa` | Baclayon Plantation | 3 | - | no geocode, interpolated |
| `lasang_via_sasa` | Bunawan Plywood | 4 | - | no geocode, interpolated |
| `lasang_via_sasa` | Bunawan Elem. School | 5 | - | no geocode, interpolated |
| `lasang_via_sasa` | Before Bunawan Elem. School | 6 | - | no geocode, interpolated |
| `lasang_via_sasa` | Northern Hills Sawmill | 7 | - | no geocode, interpolated |
| `lasang_via_sasa` | Mahayag | 8 | 2449 m | geocode rejected, interpolated |
| `lasang_via_sasa` | Manpower RMTC | 9 | - | no geocode, interpolated |
| `lasang_via_sasa` | Davao Extension Lumber | 10 | - | no geocode, interpolated |
| `lasang_via_sasa` | Tibungco Elem. School | 11 | - | no geocode, interpolated |
| `lasang_via_sasa` | U.M. College (Ilang) | 12 | - | no geocode, interpolated |
| `lasang_via_sasa` | Ilang Basketball Court | 13 | - | no geocode, interpolated |
| `lasang_via_sasa` | Bacnotan Cement | 14 | - | no geocode, interpolated |
| `lasang_via_sasa` | Sagrada Familia St. (Km. 13) | 16 | - | no geocode, interpolated |
| `lasang_via_sasa` | Going to Babak | 17 | - | no geocode, interpolated |
| `lasang_via_sasa` | Old Crossing Airport | 18 | - | no geocode, interpolated |
| `lasang_via_sasa` | Hizon Elem. School | 19 | - | no geocode, interpolated |
| `lasang_via_sasa` | Alcantara & Sons | 20 | 788 m | geocode rejected, interpolated |
| `lasang_via_sasa` | Crossing Ubalde | 21 | - | no geocode, interpolated |
| `lasang_via_sasa` | Agdai Crossing | 23 | - | no geocode, interpolated |
| `lasang_via_sasa` | Jacinto Crossing | 25 | - | no geocode, interpolated |
| `maa_agdao` | Bachelor Bus Garage | 5 | - | no geocode, interpolated |
| `maa_agdao` | Sandawa | 7 | 304 m | geocode rejected, interpolated |
| `maa_agdao` | AVON Office (CM Recto) | 9 | - | no geocode, interpolated |
| `maa_agdao` | MSSD | 10 | - | no geocode, interpolated |
| `maa_agdao` | Agdao (Dalisay) | 12 | - | no geocode, interpolated |
| `maa_bankerohan` | Bachelor Bus Garage | 5 | - | no geocode, interpolated |
| `maa_bankerohan` | Sandawa Crossing | 7 | 644 m | geocode rejected, interpolated |
| `matina` | La Suerte Gallera | 2 | - | no geocode, interpolated |
| `matina` | Tulip Drive | 3 | 1390 m | geocode rejected, interpolated |
| `matina` | McDonald's (Ateneo) | 4 | - | no geocode, interpolated |
| `matina` | Bankerohan | 5 | 437 m | geocode rejected, interpolated |
| `matina` | SP Building (Pichon) | 6 | - | no geocode, interpolated |
| `matina` | Avon (CM Recto) | 7 | - | no geocode, interpolated |
| `matina` | DSWD (R. Magsaysay Avenue) | 8 | - | no geocode, interpolated |
| `matina_aplaya` | Baqui (Punta Dumalag) | 1 | - | no geocode, interpolated |
| `matina_aplaya` | Petalcorin Res. (Matina Aplaya) | 3 | - | no geocode, interpolated |
| `matina_aplaya` | Caltex Gas Station (Matina) | 6 | - | no geocode, interpolated |
| `matina_aplaya` | SURECO Cpd. (Matina) | 7 | - | no geocode, interpolated |
| `matina_aplaya` | Generoso Bridge II | 8 | - | no geocode, interpolated |
| `matina_aplaya` | City Hall Drive (Pichon) | 9 | - | no geocode, interpolated |
| `matina_aplaya` | Recto Ave. cor. Palma Gil Sts. | 10 | - | no geocode, interpolated |
| `matina_aplaya` | Magsaysay cor. Guerrero Sts. | 11 | - | no geocode, interpolated |
| `matina_aplaya` | Magsaysay cor. F. Bangoy | 12 | - | no geocode, interpolated |
| `matina_aplaya` | Cor. Aquino/Leon Garcia | 13 | - | no geocode, interpolated |
| `matina_crossing` | La Suerte Gallera | 2 | - | no geocode, interpolated |
| `matina_crossing` | Tulip Drive | 3 | 1390 m | geocode rejected, interpolated |
| `matina_crossing` | McDonald's (Ateneo) | 4 | - | no geocode, interpolated |
| `matina_crossing` | Bankerohan | 5 | 437 m | geocode rejected, interpolated |
| `matina_crossing` | SP Building (Pichon) | 6 | - | no geocode, interpolated |
| `matina_crossing` | Avon (CM Recto) | 7 | - | no geocode, interpolated |
| `matina_crossing` | DSWD (R. Magsaysay Avenue) | 8 | - | no geocode, interpolated |
| `matina_crossing` | UM (Bangoy) | 9 | 434 m | geocode rejected, interpolated |
| `matina_crossing` | Agdao | 10 | 1042 m | geocode rejected, interpolated |
| `matina_pangi` | Matina Pangi | 0 | 396 m | geocode rejected, interpolated |
| `matina_pangi` | Junct. Quimpo Blvd/McArthur Highway | 1 | - | no geocode, interpolated |
| `matina_pangi` | Shell Gas Station (before Memorial Park) | 2 | - | no geocode, interpolated |
| `matina_pangi` | Ma-a Crossing | 3 | 3519 m | geocode rejected, interpolated |
| `matina_pangi` | Flying V (Sandawa) | 4 | - | no geocode, interpolated |
| `matina_pangi` | Cor. Camus/Quirino Sts. | 5 | - | no geocode, interpolated |
| `matina_pangi` | Cor. Sales/Magsaysay Sts. | 7 | - | no geocode, interpolated |
| `matina_pangi` | Magsaysay Ave. (Park) | 8 | - | no geocode, interpolated |
| `mintal` | Dayrit Farm | 4 | - | no geocode, interpolated |
| `mintal` | Reyes Residence | 5 | - | no geocode, interpolated |
| `mintal` | Cal's Repair Shop | 6 | - | no geocode, interpolated |
| `mintal` | Ulas | 7 | 742 m | geocode rejected, interpolated |
| `mintal` | DXSS | 8 | - | no geocode, interpolated |
| `mintal` | ABS-CBN Junstion (Matina) | 11 | - | no geocode, interpolated |
| `mintal` | Ecoland Terminal Crossing | 13 | - | no geocode, interpolated |
| `panacan_sm_city_route` | Sagrada Familia St. (Km. 13) | 1 | - | no geocode, interpolated |
| `panacan_sm_city_route` | Going to Babak | 2 | - | no geocode, interpolated |
| `panacan_sm_city_route` | Marginal Whard | 3 | - | no geocode, interpolated |
| `panacan_sm_city_route` | Old Crossing Airport | 4 | - | no geocode, interpolated |
| `panacan_sm_city_route` | Hizon Elem. School | 5 | - | no geocode, interpolated |
| `panacan_sm_city_route` | Alcantara & Sons | 6 | 853 m | geocode rejected, interpolated |
| `panacan_sm_city_route` | DAMOSA | 7 | 1125 m | geocode rejected, interpolated |
| `panacan_sm_city_route` | Dacudao Fly Over (Entrance) | 9 | - | no geocode, interpolated |
| `panacan_sm_city_route` | Cor. Palma Gil St. (Obrero) | 11 | - | no geocode, interpolated |
| `panacan_sm_city_route` | San Pedro St. near Bankerohan | 13 | - | no geocode, interpolated |
| `panacan_sm_city_route` | SIR/Matina Alliance Church | 14 | - | no geocode, interpolated |
| `panacan_via_cabaguio_avenue` | Sagrada Familia St. (Km. 13) | 1 | - | no geocode, interpolated |
| `panacan_via_cabaguio_avenue` | Going to Babak | 2 | - | no geocode, interpolated |
| `panacan_via_cabaguio_avenue` | Marginal Wharf | 3 | - | no geocode, interpolated |
| `panacan_via_cabaguio_avenue` | Old Crossing Airport | 4 | - | no geocode, interpolated |
| `panacan_via_cabaguio_avenue` | Hizon Elem. School | 5 | - | no geocode, interpolated |
| `panacan_via_cabaguio_avenue` | Alcantara & Sons | 6 | 853 m | geocode rejected, interpolated |
| `panacan_via_cabaguio_avenue` | DAMOSA | 7 | 1125 m | geocode rejected, interpolated |
| `panacan_via_cabaguio_avenue` | Esmeralda Mkt. Garden (Cabaguio) | 9 | - | no geocode, interpolated |
| `panacan_via_cabaguio_avenue` | Metro Bank (Agdao Fly Over) | 10 | - | no geocode, interpolated |
| `panacan_via_cabaguio_avenue` | Sulpicio Lines (L. Garcia) | 11 | - | no geocode, interpolated |
| `panacan_via_cabaguio_avenue` | Suazo/Magsaysay Sts. | 12 | - | no geocode, interpolated |
| `panacan_via_cabaguio_avenue` | Cor. Aurora/Roxas | 13 | - | no geocode, interpolated |
| `panacan_via_cabaguio_avenue` | Cor.Roxas/Recto | 14 | - | no geocode, interpolated |
| `sasa_via_cabaguio_avenue` | Legaspi Oil Corp. | 3 | - | no geocode, interpolated |
| `sasa_via_cabaguio_avenue` | Sto. Domingo Village | 4 | 692 m | geocode rejected, interpolated |
| `sasa_via_cabaguio_avenue` | BPI (Insular Village) | 5 | - | no geocode, interpolated |
| `sasa_via_cabaguio_avenue` | Guadalupe Village | 6 | 423 m | geocode rejected, interpolated |
| `sasa_via_cabaguio_avenue` | Lanang Country Club | 7 | - | no geocode, interpolated |
| `sasa_via_cabaguio_avenue` | DMC Overpass | 8 | - | no geocode, interpolated |
| `sasa_via_cabaguio_avenue` | Agdao Fly Over (EXIT) | 10 | - | no geocode, interpolated |
| `sasa_via_cabaguio_avenue` | Palma Gil/Ponciano | 13 | - | no geocode, interpolated |
| `sasa_via_cabaguio_avenue` | City Health (Pichon/Magallanes) | 14 | - | no geocode, interpolated |
| `sasa_via_jp_laurel_avenue` | Sasa Fly Over going to babak | 1 | - | no geocode, interpolated |
| `sasa_via_jp_laurel_avenue` | Brgy. Hall Sasa | 2 | - | no geocode, interpolated |
| `sasa_via_jp_laurel_avenue` | Old Airport | 3 | - | no geocode, interpolated |
| `sasa_via_jp_laurel_avenue` | Hizon Elementary School | 4 | - | no geocode, interpolated |
| `sasa_via_jp_laurel_avenue` | Junction Caltex | 5 | - | no geocode, interpolated |
| `sasa_via_jp_laurel_avenue` | Damosa | 6 | 1125 m | geocode rejected, interpolated |
| `sasa_via_jp_laurel_avenue` | DCWD | 7 | - | no geocode, interpolated |
| `sasa_via_jp_laurel_avenue` | Buhangin Fly Over | 8 | - | no geocode, interpolated |
| `sasa_via_jp_laurel_avenue` | Bacaca Road | 9 | 884 m | geocode rejected, interpolated |
| `sasa_via_jp_laurel_avenue` | V. Mapa. St. | 10 | 348 m | geocode rejected, interpolated |
| `sasa_via_jp_laurel_avenue` | City Hall | 12 | 261 m | geocode rejected, interpolated |
| `sasa_via_r_castillo_street` | Sasa Fly Over | 1 | - | no geocode, interpolated |
| `sasa_via_r_castillo_street` | Old Airport | 3 | - | no geocode, interpolated |
| `sasa_via_r_castillo_street` | Hizon Elem. School | 4 | - | no geocode, interpolated |
| `sasa_via_r_castillo_street` | Junction Caltex/Bajada/R. Castillo | 5 | - | no geocode, interpolated |
| `sasa_via_r_castillo_street` | Cor. Alterado Hospital/R. Castillo | 7 | - | no geocode, interpolated |
| `sasa_via_r_castillo_street` | Overpass Agdao | 8 | - | no geocode, interpolated |
| `sasa_via_r_castillo_street` | ML Leon St./Blvd. | 10 | - | no geocode, interpolated |
| `sasa_via_r_castillo_street` | Rizal Extn. Cor. Quezon Blvd. | 11 | - | no geocode, interpolated |
| `sasa_via_r_castillo_street` | Roxas Avenue/Recto Avenue | 12 | - | no geocode, interpolated |
| `talomo` | Talomo Centro/Cemento (Boundary) | 1 | - | no geocode, interpolated |
| `talomo` | Union St.(Bangkal) | 5 | - | no geocode, interpolated |
| `talomo` | Junction McArthur/Quimpo Blvd. | 7 | - | no geocode, interpolated |
| `talomo` | Shell Station(Matina) | 8 | - | no geocode, interpolated |
| `talomo` | Generoso Bridge II(Flying V) | 10 | - | no geocode, interpolated |
| `talomo` | Grand Menseng Hotel | 11 | - | no geocode, interpolated |
| `talomo` | Palma Gil/Recto Corner | 12 | - | no geocode, interpolated |
| `talomo` | Corner Recto/Roxas | 13 | - | no geocode, interpolated |
| `tibungco_via_buhangin` | Tibungco | 0 | 3358 m | geocode rejected, interpolated |
| `tibungco_via_buhangin` | U.M. College (Ilang) | 1 | - | no geocode, interpolated |
| `tibungco_via_buhangin` | Ilang Basketball Court | 2 | - | no geocode, interpolated |
| `tibungco_via_buhangin` | Bacnotan Cement | 3 | - | no geocode, interpolated |
| `tibungco_via_buhangin` | Mindanao Coco Corp. | 5 | - | no geocode, interpolated |
| `tibungco_via_buhangin` | Landmark III | 6 | 373 m | geocode rejected, interpolated |
| `tibungco_via_buhangin` | Davao Int'l Airport (Div Road) | 7 | - | no geocode, interpolated |
| `tibungco_via_buhangin` | R. Tecson Construction (Div. Road) | 9 | - | no geocode, interpolated |
| `tibungco_via_buhangin` | Caltex Gas Station (Div. Road) | 10 | - | no geocode, interpolated |
| `tibungco_via_buhangin` | Waling-Waling St. (Div. Road) | 11 | - | no geocode, interpolated |
| `tibungco_via_buhangin` | Pag-asa St. (Buhangin Road) | 12 | - | no geocode, interpolated |
| `tibungco_via_buhangin` | Dacudao Fly Over (Entrance) | 13 | - | no geocode, interpolated |
| `tibungco_via_buhangin` | Sulpicio Lines(L. Garcia) | 15 | - | no geocode, interpolated |
| `tibungco_via_buhangin` | Suazo corner Quezon Blvd. | 16 | - | no geocode, interpolated |
| `tibungco_via_buhangin` | Roxas corner Gomez Sts. | 17 | - | no geocode, interpolated |
| `tibungco_via_cabaguio_avenue` | Tibungo | 0 | - | no geocode, interpolated |
| `tibungco_via_cabaguio_avenue` | Tibungco Overpass | 1 | - | no geocode, interpolated |
| `tibungco_via_cabaguio_avenue` | U.M. College (Ilang) | 2 | - | no geocode, interpolated |
| `tibungco_via_cabaguio_avenue` | Bacnotan Cement | 3 | - | no geocode, interpolated |
| `tibungco_via_cabaguio_avenue` | Sagrada Familia St. (Km. 13) | 5 | - | no geocode, interpolated |
| `tibungco_via_cabaguio_avenue` | Going to Babak | 6 | - | no geocode, interpolated |
| `tibungco_via_cabaguio_avenue` | Marginal Wharf | 7 | - | no geocode, interpolated |
| `tibungco_via_cabaguio_avenue` | Old Crossing Airport | 8 | - | no geocode, interpolated |
| `tibungco_via_cabaguio_avenue` | Hizon Elem. School | 9 | - | no geocode, interpolated |
| `tibungco_via_cabaguio_avenue` | Alcantara & Sons | 10 | 853 m | geocode rejected, interpolated |
| `tibungco_via_cabaguio_avenue` | DAMOSA | 11 | 1125 m | geocode rejected, interpolated |
| `tibungco_via_cabaguio_avenue` | Esmeralda Mkt. Garden (Cabaguio) | 13 | - | no geocode, interpolated |
| `tibungco_via_cabaguio_avenue` | Metro Bank (Agdao Fly Over) | 14 | - | no geocode, interpolated |
| `tibungco_via_cabaguio_avenue` | Sulpicio Lines (L. Garcia) | 15 | - | no geocode, interpolated |
| `tibungco_via_cabaguio_avenue` | Suazo/Magsaysay Sts. | 16 | - | no geocode, interpolated |
| `tibungco_via_cabaguio_avenue` | Cor. Aurora/Roxas | 17 | - | no geocode, interpolated |
| `tibungco_via_cabaguio_avenue` | Cor.Roxas/Recto | 18 | - | no geocode, interpolated |
| `tibungco_via_r_castillo_avenue` | Tibungco | 0 | 3358 m | geocode rejected, interpolated |
| `tibungco_via_r_castillo_avenue` | U.M. College (Ilang) | 1 | - | no geocode, interpolated |
| `tibungco_via_r_castillo_avenue` | Brgy. Ilang Basketball Court | 2 | - | no geocode, interpolated |
| `tibungco_via_r_castillo_avenue` | Sagrada Familia St. (Km. 13) | 4 | - | no geocode, interpolated |
| `tibungco_via_r_castillo_avenue` | Going to Babak | 5 | - | no geocode, interpolated |
| `tibungco_via_r_castillo_avenue` | Marginal Wharf | 6 | - | no geocode, interpolated |
| `tibungco_via_r_castillo_avenue` | Old Crossing Airport | 7 | - | no geocode, interpolated |
| `tibungco_via_r_castillo_avenue` | Hizon Elem. School | 8 | - | no geocode, interpolated |
| `tibungco_via_r_castillo_avenue` | Alcantara & Sons | 9 | 788 m | geocode rejected, interpolated |
| `tibungco_via_r_castillo_avenue` | Crossing Ubalde | 10 | - | no geocode, interpolated |
| `tibungco_via_r_castillo_avenue` | Agdao Crossing | 12 | - | no geocode, interpolated |
| `tibungco_via_r_castillo_avenue` | Roxas/Aurora Corner | 15 | - | no geocode, interpolated |
| `tibungco_via_r_castillo_avenue` | Roxas/Recto Avenue | 16 | - | no geocode, interpolated |
| `toril` | Toril | 0 | 8958 m | geocode rejected, interpolated |
| `toril` | Electric Post # 0558071 | 1 | - | no geocode, interpolated |
| `toril` | Electric Post # 0567474 | 2 | - | no geocode, interpolated |
| `toril` | Madre Maria Pia Notari School | 3 | - | no geocode, interpolated |
| `toril` | Electric Post # 0362416 | 4 | - | no geocode, interpolated |
| `toril` | Prk. 9 Baracatan | 5 | - | no geocode, interpolated |
| `toril` | Caltex | 6 | 488 m | geocode rejected, interpolated |
| `toril` | Cargill Headquarters | 7 | - | no geocode, interpolated |
| `toril` | Binugao Brgy. Hall | 8 | - | no geocode, interpolated |
| `toril` | Magnolia Dressing Plant | 9 | - | no geocode, interpolated |
| `toril` | JCT Catigan (TF Davao) | 10 | - | no geocode, interpolated |
| `toril` | Lipadas Bridge | 11 | 1029 m | geocode rejected, interpolated |
| `toril` | Crossing Bayabas | 13 | 348 m | geocode rejected, interpolated |
| `toril` | Vales JCT | 14 | - | no geocode, interpolated |
| `toril` | Better Living | 16 | - | no geocode, interpolated |
| `toril` | Bago Crossing | 17 | - | no geocode, interpolated |
| `toril` | Boundary Matina-Talomo | 21 | - | no geocode, interpolated |
| `toril` | La Suerte Gallera | 23 | - | no geocode, interpolated |
| `toril` | Tulip Drive | 24 | 1390 m | geocode rejected, interpolated |
| `toril` | Ma-a Crossing | 25 | 4446 m | geocode rejected, interpolated |
| `toril` | Sandawa Crossing | 26 | 644 m | geocode rejected, interpolated |
| `toril` | Quirino Avenue | 27 | 424 m | geocode rejected, interpolated |
| `toril` | Bonifacio Street | 28 | 6117 m | geocode rejected, interpolated |
| `ulas` | Caltex(near Bridge) | 1 | - | no geocode, interpolated |
| `ulas` | Flores Subd. | 2 | 438 m | geocode rejected, interpolated |
| `ulas` | Royal Pines(McArthur) | 5 | - | no geocode, interpolated |
| `ulas` | UM Matina | 7 | 401 m | geocode rejected, interpolated |
| `ulas` | Quirino/San Pedro | 8 | - | no geocode, interpolated |
| `ulas` | Suazo/Sta Ana Avenue | 10 | - | no geocode, interpolated |
| `ulas` | Magsaysay | 11 | 35616 m | geocode rejected, interpolated |

## Routes barred from setting fares

The extracted one-way length and the curated `totalKm` disagree by
more than 3 km, so these routes are placed for display but their
stops carry no `distDm`. See `PROVENANCE.md`.

- `ecoland_subdivision_sm_city_of_davao` (oneway - declared = -3.33 km)
- `tibungco_via_cabaguio_avenue` (oneway - declared = -3.76 km)
- `toril` (oneway - declared = -11.46 km)
- `ulas` (oneway - declared = +5.64 km)
