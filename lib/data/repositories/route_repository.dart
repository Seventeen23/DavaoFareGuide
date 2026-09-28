import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import '../../core/error/failure.dart';
import '../../core/result/result.dart';
import '../../core/utils/route_file_parser.dart';
import '../local/database/app_database.dart';
import '../local/database/daos/route_dao.dart';
import '../local/seed/route_manifest.dart';
import '../models/jeepney_route.dart';

class RouteRepository {
  RouteRepository({required AppDatabase database, AssetBundle? bundle})
    : _dao = RouteDao(database),
      _bundle = bundle ?? rootBundle,
      _parser = const RouteFileParser();

  final RouteDao _dao;
  final AssetBundle _bundle;
  final RouteFileParser _parser;

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

  Future<Result<int>> seedIfEmpty() async {
    try {
      if (await _dao.hasRoutes()) return Result.success(0);
      await _dao.insertAll(await _readBundledRoutes());
      return Result.success(kRouteManifest.length);
    } on Object catch (error) {
      return Result.failure(
        Failure(AppFailure.database, 'Route seeding failed.', cause: error),
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
    final routes = <JeepneyRoute>[];

    for (var index = 0; index < kRouteManifest.length; index++) {
      final entry = kRouteManifest[index];
      final parsed = _parser.parse(entry.codeName, await _bundle.loadString(entry.assetPath));

      routes.add(
        JeepneyRoute(
          id: index + 1,
          codeName: entry.codeName,
          displayName: entry.displayName,
          landmarks: deriveLandmarks(entry.displayName),
          stops: parsed.stops,
        ),
      );
    }

    return routes;
  }
}

List<String> deriveLandmarks(String displayName) {
  return displayName
      .split(RegExp(r'\s+via\s+', caseSensitive: false))
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toList();
}
