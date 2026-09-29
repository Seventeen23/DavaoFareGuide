import 'dart:convert';
import 'dart:io';

import 'package:davao_jeepney/core/utils/route_file_parser.dart';
import 'package:davao_jeepney/data/local/seed/geo_assets.dart';
import 'package:davao_jeepney/data/local/seed/route_manifest.dart';
import 'package:davao_jeepney/data/models/route_stop.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show CachingAssetBundle;
import 'package:flutter_test/flutter_test.dart';

/// Routes where the extracted geometry and the curated `totalKm` disagree by
/// more than [maxKmDeltaKm]. Listed in `assets/geo/PROVENANCE.md` and barred
/// from publishing a distance, so the list is written out here rather than
/// derived: a test that recomputes the list from the same field it is checking
/// would agree with any value of it, including a wrong one.
const Set<String> kDisputedRoutes = {
  'toril',
  'ulas',
  'tibungco_via_cabaguio_avenue',
  'ecoland_subdivision_sm_city_of_davao',
};

const double maxKmDeltaKm = 3.0;

/// Davao City and its immediate neighbours. A position outside this box is a
/// geocoding failure, and the placement pipeline is supposed to have caught it.
const ({double min, double max}) kDavaoLat = (min: 6.9, max: 7.6);
const ({double min, double max}) kDavaoLng = (min: 125.2, max: 125.9);

Map<String, dynamic> readJsonAsset(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

/// Raw `stops.json` rows keyed by route, because the raw rows carry the stop
/// name and test failures have to name the stop that broke.
Map<String, List<Map<String, dynamic>>> readPlacements() {
  final decoded = readJsonAsset(GeoAssets.stopsAsset);
  return {
    for (final entry in (decoded['routes'] as Map<String, dynamic>).entries)
      entry.key: [
        for (final row in entry.value as List<dynamic>) row as Map<String, dynamic>,
      ],
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const parser = RouteFileParser();
  final geo = GeoAssets();

  // Read the generated files directly, so a test can assert on fields the
  // app's model deliberately does not carry, such as `kmDelta`.
  final rawGeometry = {
    for (final route in readJsonAsset(GeoAssets.routesAsset)['routes']
        as List<dynamic>)
      (route as Map<String, dynamic>)['codeName'] as String: route,
  };
  final rawPlacements = readPlacements();

  group('Bundled route geometry', () {
    test('describes only routes this app can price', () {
      final bundled = kRouteManifest.map((entry) => entry.codeName).toSet();

      expect(
        rawGeometry.keys.toSet().difference(bundled),
        isEmpty,
        reason: 'geometry for a route with no stops, kmIndex or fare basis',
      );
    });

    test('splits every loop into an outbound leg and a return leg', () {
      for (final entry in rawGeometry.entries) {
        final loop = entry.value['loop'] as List<dynamic>;
        final turnaround = entry.value['turnaroundIndex'] as int;

        expect(turnaround, greaterThan(0), reason: entry.key);
        expect(turnaround, lessThan(loop.length), reason: entry.key);
        expect(entry.value['loopKm'] as num, greaterThan(0), reason: entry.key);
        expect(
          entry.value['onewayKm'] as num,
          lessThanOrEqualTo(entry.value['loopKm'] as num),
          reason: '${entry.key}: the outbound leg is only part of the loop',
        );
      }
    });

    test('converts measured kilometres into decimetres within one decimetre',
        () async {
      final geometries = await geo.loadGeometries();

      expect(geometries.keys.toSet(), rawGeometry.keys.toSet());
      for (final entry in geometries.entries) {
        expect(entry.value.onewayDm, greaterThan(0), reason: entry.key);
        expect(
          (entry.value.onewayDm - rawGeometry[entry.key]!['onewayKm'] * 10)
              .abs(),
          lessThanOrEqualTo(1),
          reason: '${entry.key}: decimetres must not drift from the measurement',
        );
      }
    });

    test('exposes the outbound leg, not the whole loop', () async {
      final geometries = await geo.loadGeometries();

      for (final entry in geometries.entries) {
        final geometry = entry.value;
        expect(
          geometry.oneway.length,
          geometry.turnaroundIndex + 1,
          reason: entry.key,
        );
        expect(geometry.oneway, isNot(geometry.loop), reason: entry.key);
      }
    });

    test('keeps the published length beside the measurement', () async {
      final geometries = await geo.loadGeometries();

      // Derived from stored columns rather than trusted from the source, so a
      // disagreement is visible in the app and assertable here.
      for (final entry in geometries.entries) {
        final kmDelta = entry.value.onewayDm / 10 - entry.value.declaredKm;

        expect(
          kmDelta.abs() > maxKmDeltaKm,
          kDisputedRoutes.contains(entry.key),
          reason: entry.key,
        );
      }
    });
  });

  group('Stop placements', () {
    test('exist only for routes that have geometry', () {
      expect(rawPlacements.keys.toSet(), rawGeometry.keys.toSet());
    });

    test('have a row per stop, in the same order as the route file', () {
      for (final entry in rawPlacements.entries) {
        final parsed = parser.parse(
          entry.key,
          File('assets/routes/${entry.key}.txt').readAsStringSync(),
        );

        expect(
          entry.value.map((row) => row['name']),
          parsed.stops.map((stop) => stop.name),
          reason: '${entry.key}: placements must not reorder or rename stops',
        );
        expect(
          entry.value.map((row) => row['kmIndex']),
          parsed.stops.map((stop) => stop.kmIndex),
          reason: '${entry.key}: placements must not renumber the marks',
        );
      }
    });

    test('publish a distance only for a stop that was actually placed', () {
      var placed = 0;
      var guessed = 0;

      for (final entry in rawPlacements.entries) {
        for (final row in entry.value) {
          final where = '${entry.key} / ${row['name']}';
          if (row['source'] == 'geocoded') {
            placed++;
            expect(row['distDm'], isNotNull, reason: where);
            expect(row['lat'], isNotNull, reason: where);
            expect(row['lng'], isNotNull, reason: where);
          } else {
            guessed++;
            expect(
              row['distDm'],
              isNull,
              reason: '$where: only a stop snapped onto the polyline may '
                  'carry a distance',
            );
          }
        }
      }

      expect(placed, greaterThan(0), reason: 'the pipeline placed nothing');
      expect(guessed, greaterThan(placed), reason: 'most stops are guesses');
    });

    test('publish no distance for a route whose length is disputed', () async {
      final placements = await geo.loadStopPlacements();

      for (final codeName in kDisputedRoutes) {
        final stops = placements[codeName];
        expect(
          stops,
          isNotNull,
          reason: '$codeName has geometry, so its stops are placed for display',
        );
        for (final stop in stops!.values) {
          expect(
            stop.distDm,
            isNull,
            reason: '$codeName: the measured leg contradicts the published '
                'totalKm, so no stop on it may set a distance',
          );
        }
      }

      // The same ban, asserted on the generated rows so a failure names the stop.
      for (final codeName in kDisputedRoutes) {
        for (final row in rawPlacements[codeName] ?? const []) {
          expect(
            row['distDm'],
            isNull,
            reason: '$codeName / ${row['name']}',
          );
        }
      }
    });

    test('never place a stop beyond the end of the leg', () async {
      final geometries = await geo.loadGeometries();
      final placements = await geo.loadStopPlacements();

      for (final route in placements.entries) {
        final leg = geometries[route.key]!.onewayDm;
        for (final stop in route.value.values) {
          final distance = stop.distDm;
          if (distance == null) continue;
          expect(distance, greaterThanOrEqualTo(0), reason: route.key);
          expect(
            distance,
            lessThanOrEqualTo(leg + 1),
            reason: '${route.key}: a stop cannot sit past the terminus',
          );
        }
      }
    });

    test('keep every position inside the Davao area', () {
      for (final entry in rawPlacements.entries) {
        for (final row in entry.value) {
          final where = '${entry.key} / ${row['name']}';
          expect(row['lat'], inInclusiveRange(kDavaoLat.min, kDavaoLat.max), reason: where);
          expect(row['lng'], inInclusiveRange(kDavaoLng.min, kDavaoLng.max), reason: where);
        }
      }
    });
  });

  group('Landmarks', () {
    test('carry provenance a human can audit', () async {
      final landmarks = await geo.loadLandmarks();

      expect(landmarks, isNotEmpty);
      for (final landmark in landmarks) {
        expect(
          const {'curated', 'wikidata', 'osm'},
          contains(landmark.source),
          reason: '${landmark.name} has no documented provenance',
        );
        expect(landmark.lat, inInclusiveRange(kDavaoLat.min, kDavaoLat.max),
            reason: landmark.name);
        expect(landmark.lng, inInclusiveRange(kDavaoLng.min, kDavaoLng.max),
            reason: landmark.name);
      }
    });

    test('link only to routes the app ships', () async {
      final landmarks = await geo.loadLandmarks();
      final bundled = kRouteManifest.map((entry) => entry.codeName).toSet();

      for (final landmark in landmarks) {
        expect(
          landmark.routeCodes.toSet().difference(bundled),
          isEmpty,
          reason: '${landmark.name} points at a route that cannot be drawn',
        );
      }
    });

    test('keep the hand-picked landmarks the stop pipeline seeds from',
        () async {
      final landmarks = await geo.loadLandmarks();

      expect(
        landmarks.where((landmark) => landmark.source == 'curated'),
        isNotEmpty,
        reason: 'tool/place_stops.py seeds stop coordinates from these',
      );
    });
  });

  group('Content fingerprint', () {
    test('is stable for one set of assets', () async {
      final fingerprint = await geo.contentFingerprint();

      expect(fingerprint, await geo.contentFingerprint());
      expect(fingerprint, matches(r'^\d+-\d+-\d+$'));
    });

    test('changes when an asset changes', () async {
      final fingerprint = await geo.contentFingerprint();
      final bundle = _StubBundle({
        GeoAssets.routesAsset: '{"routes":[]}',
        GeoAssets.stopsAsset: '{"routes":{}}',
        GeoAssets.landmarksAsset: '{"landmarks":[]}',
      });

      expect(
        await GeoAssets(bundle: bundle).contentFingerprint(),
        isNot(fingerprint),
        reason: 'a re-seed depends on this noticing the new data',
      );
    });
  });

  group('Degrading gracefully', () {
    test('keeps a stop that has no coordinate or distance', () async {
      final bundle = _StubBundle({
        GeoAssets.stopsAsset: jsonEncode({
          'routes': {
            'matina': [
              {'name': 'Matina', 'kmIndex': 0, 'lat': null, 'lng': null},
              {'name': 'Agdao', 'kmIndex': 10},
            ],
          },
        }),
      });

      final stops =
          (await GeoAssets(bundle: bundle).loadStopPlacements())['matina']!;

      expect(stops['Matina']!.distDm, isNull);
      expect(stops['Matina']!.lat, isNull);
      expect(stops['Agdao']!.distDm, isNull, reason: 'missing must not become 0');
      expect(stops['Agdao']!.source, 'unknown');
      expect(stops['Agdao']!.isMeasured, isFalse);
    });

    test('leaves a parsed stop alone when no placement matches it', () async {
      const parsed = RouteStop(name: 'Matina', kmIndex: 0, sequence: 0);
      const missing = StopPlacement(
        lat: null,
        lng: null,
        distDm: null,
        source: 'unknown',
      );

      expect(missing.applyTo(parsed), parsed);
    });

    test('accepts an asset with nothing in it', () async {
      final empty = GeoAssets(
        bundle: _StubBundle({
          GeoAssets.routesAsset: '{}',
          GeoAssets.stopsAsset: '{}',
          GeoAssets.landmarksAsset: '{}',
        }),
      );

      expect(await empty.loadGeometries(), isEmpty);
      expect(await empty.loadStopPlacements(), isEmpty);
      expect(await empty.loadLandmarks(), isEmpty);
    });
  });
}

/// An [AssetBundle] over a fixed set of strings, for the paths that would
/// otherwise read the real asset bundle.
class _StubBundle extends CachingAssetBundle {
  _StubBundle(this.contents);

  final Map<String, String> contents;

  @override
  Future<ByteData> load(String key) async {
    final value = contents[key];
    if (value == null) {
      throw FlutterError('Asset not found: $key');
    }
    final bytes = Uint8List.fromList(utf8.encode(value));
    return ByteData.view(bytes.buffer);
  }
}
