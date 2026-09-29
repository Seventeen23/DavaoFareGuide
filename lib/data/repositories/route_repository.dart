import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import '../../core/error/failure.dart';
import '../../core/result/result.dart';
import '../../core/utils/route_file_parser.dart';
import '../local/database/app_database.dart';
import '../local/database/daos/route_dao.dart';
import '../local/seed/geo_assets.dart';
import '../local/seed/route_manifest.dart';
import '../models/geo.dart';
import '../models/jeepney_route.dart';

class RouteRepository {
  RouteRepository({required AppDatabase database, AssetBundle? bundle})
    : _dao = RouteDao(database),
      _database = database,
      _bundle = bundle ?? rootBundle,
      _parser = const RouteFileParser(),
      _geo = GeoAssets(bundle: bundle);

  final RouteDao _dao;
  final AppDatabase _database;
  final AssetBundle _bundle;
  final RouteFileParser _parser;
  final GeoAssets _geo;

  Future<Result<List<JeepneyRoute>>> getAllRoutes() async {
    try {
      return Result.success(await _dao.getAllRoutes());
    } on Object catch (error) {
      return Result.failure(
        Failure(AppFailure.database, 'Could not load routes.', cause: error),
      );
    }
  }

  Future<Result<JeepneyRoute>> getRouteByCodeName(String codeName) async {
    try {
      final route = await _dao.getRouteByCodeName(codeName);
      if (route == null) {
        return Result.failure(
          Failure(AppFailure.notFound, 'Unknown route "$codeName".'),
        );
      }
      return Result.success(route);
    } on Object catch (error) {
      return Result.failure(
        Failure(AppFailure.database, 'Could not load route.', cause: error),
      );
    }
  }

  /// Loads the bundled route data, re-seeding if the bundled assets changed.
  ///
  /// The fingerprint is what makes this safe to call on every cold start: an
  /// install whose assets have not changed does one cheap comparison and
  /// touches nothing, so the user's popularity history is never disturbed. When
  /// the assets *have* changed the route tables are rebuilt, and usage counts
  /// are carried across by `codeName` rather than by row id, because ids are
  /// positional in the generated manifest and shift whenever a route is added.
  ///
  /// Returns the number of routes re-seeded, for logging and tests.
  Future<Result<int>> seedIfStale() async {
    try {
      final fingerprint = await _geo.contentFingerprint();
      if (await _database.contentVersion == fingerprint && await _dao.hasRoutes()) {
        return Result.success(0);
      }

      final usage = await _dao.usageByCodeName();
      final routes = await _readBundledRoutes();
      final geometries = (await _geo.loadGeometries()).values.toList();
      final landmarks = await _geo.loadLandmarks();

      await _dao.deleteRouteData();
      await _dao.insertAll(routes);

      final idByCodeName = await _dao.routeIdByCodeName();
      await _dao.insertGeometries(geometries);
      await _dao.insertLandmarks(landmarks, idByCodeName);

      // Popularity last, and only for routes that still exist.
      for (final entry in usage.entries) {
        if (idByCodeName[entry.key] == null) continue;
        await _dao.restoreUsage(
          entry.key,
          usageCount: entry.value.usageCount,
          lastUsedAt: entry.value.lastUsedAt,
        );
      }

      await _database.setContentVersion(fingerprint);
      return Result.success(routes.length);
    } on Object catch (error) {
      return Result.failure(
        Failure(AppFailure.database, 'Route seeding failed.', cause: error),
      );
    }
  }

  /// The road shape of a route, or null when it has no verified geometry.
  Future<Result<RouteGeometry?>> getGeometry(String codeName) async {
    try {
      final geometries = await _geo.loadGeometries();
      return Result.success(geometries[codeName]);
    } on Object catch (error) {
      return Result.failure(
        Failure(AppFailure.database, 'Could not load route geometry.', cause: error),
      );
    }
  }

  /// Every landmark in the bundle, linked or not.
  ///
  /// The read path is the asset rather than the seeded `landmark_entries` rows:
  /// the asset is the source of truth for this data and reading it directly
  /// means a landmark search cannot be broken by a database that has not been
  /// re-seeded yet.
  Future<Result<List<MapLandmark>>> getAllLandmarks() async {
    try {
      return Result.success(await _geo.loadLandmarks());
    } on Object catch (error) {
      return Result.failure(
        Failure(AppFailure.database, 'Could not load landmarks.', cause: error),
      );
    }
  }

  /// Landmarks that sit on [codeName]'s corridor.
  Future<Result<List<MapLandmark>>> getLandmarks(String codeName) async {
    try {
      final all = await _geo.loadLandmarks();
      return Result.success(
        all.where((landmark) => landmark.routeCodes.contains(codeName)).toList(),
      );
    } on Object catch (error) {
      return Result.failure(
        Failure(AppFailure.database, 'Could not load landmarks.', cause: error),
      );
    }
  }

  /// Records that a ride was priced on [codeName]. Powers the popularity
  /// ranking, so failures are swallowed: losing a usage count must never
  /// interrupt a fare calculation.
  Future<void> recordUsage(String codeName) async {
    try {
      await _dao.recordUsage(codeName);
    } on Object {
      // Intentionally ignored.
    }
  }

  /// Most-used routes, most-used first. Empty while the user has not priced
  /// any ride yet.
  Future<Result<List<JeepneyRoute>>> getPopularRoutes({int limit = 5}) async {
    try {
      return Result.success(await _dao.getPopularRoutes(limit));
    } on Object catch (error) {
      return Result.failure(
        Failure(
          AppFailure.database,
          'Could not load popular routes.',
          cause: error,
        ),
      );
    }
  }

  Future<List<JeepneyRoute>> _readBundledRoutes() async {
    // Stop coordinates come from the generated map data and are merged onto
    // the parsed stops here, so a route that has no geometry still loads with
    // nothing but names and kilometre marks - which is all it ever had.
    final placements = await _geo.loadStopPlacements();
    final routes = <JeepneyRoute>[];

    for (var index = 0; index < kRouteManifest.length; index++) {
      final entry = kRouteManifest[index];
      final parsed = _parser.parse(entry.codeName, await _bundle.loadString(entry.assetPath));
      final forRoute = placements[entry.codeName] ?? const {};

      routes.add(
        JeepneyRoute(
          id: index + 1,
          codeName: entry.codeName,
          displayName: entry.displayName,
          viaLabels: _viaLabels(entry.displayName),
          stops: [
            for (final stop in parsed.stops)
              (forRoute[stop.name]?.applyTo(stop)) ?? stop,
          ],
        ),
      );
    }

    return routes;
  }
}

/// Splits "Bunawan via Sasa" into the two places it is known by.
///
/// These are name fragments for search and display, not places on a map - the
/// map landmarks come from assets/landmarks.json and carry coordinates.
List<String> _viaLabels(String displayName) {
  return displayName
      .split(RegExp(r'\s+via\s+', caseSensitive: false))
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toList();
}
