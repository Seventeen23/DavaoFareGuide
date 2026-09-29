import 'dart:convert';
import 'dart:io';

import 'package:davao_jeepney/data/local/database/app_database.dart';
import 'package:davao_jeepney/data/local/seed/geo_assets.dart';
import 'package:davao_jeepney/data/local/seed/route_manifest.dart';
import 'package:davao_jeepney/data/repositories/route_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';

/// The 15 numbered Poblacion routes that exist on the source site but have no
/// stop list, no `kmIndex` and no counterpart in `assets/routes/`. They are
/// quarantined in `assets/geo/unverified/` on purpose, and these tests are the
/// thing that keeps them quarantined. See that folder's README.
const String unverifiedAsset = 'assets/geo/unverified/route_1_15.json';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final unverifiedCodes = [
    for (final code in (readJsonAsset(unverifiedAsset)['routes'] as Map<String, dynamic>).keys)
      code,
  ];

  group('Quarantined route data', () {
    test('is documented as unsafe to ship', () {
      final readme = File('assets/geo/unverified/README.md').readAsStringSync();

      expect(
        readme.toLowerCase(),
        contains('do not use'),
        reason: 'the folder is a quarantine, and has to say so',
      );
    });

    test('carries a warning inside the data file itself', () {
      expect(
        (readJsonAsset(unverifiedAsset)['warning'] as String).toLowerCase(),
        contains('unverified'),
      );
    });

    test('is not bundled with the app', () {
      final declaredAssets = File('pubspec.yaml')
          .readAsStringSync()
          .split('assets:')
          .last
          .split('\n')
          // Comments explain the quarantine and say so out loud, so only the
          // declared asset paths are checked.
          .where((line) => !line.trimLeft().startsWith('#'))
          .join('\n');

      expect(
        declaredAssets,
        isNot(contains('unverified')),
        reason: 'bundling it would ship routes with no fare basis',
      );
    });

    test('cannot be loaded at runtime', () async {
      // The strongest form of the guarantee: even if a code path asked for the
      // quarantined file by name, the asset bundle would not have it.
      await expectLater(
        rootBundle.loadString(unverifiedAsset),
        throwsA(anything),
      );
    });

    test('is not one of the assets the data layer reads', () {
      expect(
        <String>{
          GeoAssets.routesAsset,
          GeoAssets.stopsAsset,
          GeoAssets.landmarksAsset,
        },
        {
          'assets/geo/routes.json',
          'assets/geo/stops.json',
          'assets/landmarks.json',
        },
        reason: 'a new generated asset has to be added deliberately',
      );
    });

    test('never reaches the database after a full seed', () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = RouteRepository(database: database);
      await repository.seedIfStale();

      final stored = await database
          .select(database.routeGeometries)
          .map((row) => row.codeName)
          .get();
      final bundled = kRouteManifest.map((entry) => entry.codeName).toSet();

      expect(stored, isNotEmpty, reason: 'the verified geometry did load');
      expect(
        unverifiedCodes.toSet().intersection(stored.toSet()),
        isEmpty,
        reason: 'quarantined geometry must never be seeded',
      );
      expect(
        stored.toSet().difference(bundled),
        isEmpty,
        reason: 'every seeded route must be one the app can price',
      );
    });
  });
}

Map<String, dynamic> readJsonAsset(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
