import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../models/geo.dart';
import '../../../models/jeepney_route.dart';
import '../../../models/route_stop.dart';
import '../app_database.dart';

class RouteDao {
  RouteDao(this._database);

  final AppDatabase _database;

  Future<bool> hasRoutes() async {
    final rows = await (_database.select(_database.jeepneyRoutes)..limit(1)).get();
    return rows.isNotEmpty;
  }

  Future<List<JeepneyRoute>> getAllRoutes() async {
    final routeRows = await (_database.select(
      _database.jeepneyRoutes,
    )..orderBy([(table) => OrderingTerm.asc(table.displayName)])).get();

    final stopsByRoute = await _loadStops();

    return [
      for (final row in routeRows)
        JeepneyRoute(
          id: row.id,
          codeName: row.codeName,
          displayName: row.displayName,
          viaLabels: _viaLabels(row.displayName),
          stops: stopsByRoute[row.id] ?? const [],
        ),
    ];
  }

  Future<JeepneyRoute?> getRouteByCodeName(String codeName) async {
    final row = await (_database.select(
      _database.jeepneyRoutes,
    )..where((table) => table.codeName.equals(codeName))).getSingleOrNull();

    if (row == null) return null;

    final stops = await (_database.select(
      _database.routeStops,
    )..where((table) => table.routeId.equals(row.id))
        ..orderBy([(table) => OrderingTerm.asc(table.sequence)])).get();

    return JeepneyRoute(
      id: row.id,
      codeName: row.codeName,
      displayName: row.displayName,
      viaLabels: _viaLabels(row.displayName),
      stops: [
        for (final stop in stops) _toStop(stop),
      ],
    );
  }

  /// Records that a ride was priced on [routeId]. Called once per completed
  /// fare calculation, which is the only signal the popularity ranking uses.
  Future<void> recordUsage(String codeName) async {
    final row = await (_database.select(_database.jeepneyRoutes)
          ..where((table) => table.codeName.equals(codeName)))
        .getSingleOrNull();
    if (row == null) return;

    await (_database.update(
      _database.jeepneyRoutes,
    )..where((table) => table.id.equals(row.id))).write(
      JeepneyRoutesCompanion(
        usageCount: Value(row.usageCount + 1),
        lastUsedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Routes ranked by how often the user has actually priced a ride on them.
  ///
  /// Ties break on most recent use, then alphabetically so the order is stable
  /// across rebuilds. Routes never used are excluded — an empty result means
  /// the caller should hide the section rather than show a placeholder.
  Future<List<JeepneyRoute>> getPopularRoutes(int limit) async {
    final rows = await (_database.select(_database.jeepneyRoutes)
          ..where((table) => table.usageCount.isBiggerThanValue(0))
          ..orderBy([
            (table) => OrderingTerm.desc(table.usageCount),
            (table) => OrderingTerm.desc(table.lastUsedAt),
            (table) => OrderingTerm.asc(table.displayName),
          ])
          ..limit(limit))
        .get();

    if (rows.isEmpty) return const [];

    final stopsByRoute = await _loadStopsFor([
      for (final row in rows) row.id,
    ]);

    return [
      for (final row in rows)
        JeepneyRoute(
          id: row.id,
          codeName: row.codeName,
          displayName: row.displayName,
          viaLabels: _viaLabels(row.displayName),
          stops: stopsByRoute[row.id] ?? const [],
        ),
    ];
  }

  Future<void> insertAll(List<JeepneyRoute> routes) async {
    await _database.batch((batch) {
      batch.insertAll(
        _database.jeepneyRoutes,
        [
          for (final route in routes)
            JeepneyRoutesCompanion.insert(
              id: Value(route.id),
              codeName: route.codeName,
              displayName: route.displayName,
              stopCount: route.stopCount,
              totalKm: route.totalKm,
            ),
        ],
      );

      for (final route in routes) {
        batch.insertAll(
          _database.routeStops,
          [
            for (final stop in route.stopsInOrder)
              RouteStopsCompanion.insert(
                routeId: route.id,
                name: stop.name,
                kmIndex: stop.kmIndex,
                sequence: stop.sequence,
                lat: Value(stop.lat),
                lng: Value(stop.lng),
                distDm: Value(stop.distDm),
              ),
          ],
        );
      }
    });
  }

  RouteStop _toStop(RouteStopRow row) => RouteStop(
        name: row.name,
        kmIndex: row.kmIndex,
        sequence: row.sequence,
        lat: row.lat,
        lng: row.lng,
        distDm: row.distDm,
      );

  /// Current usage history keyed by route code name.
  ///
  /// Read before a re-seed so popularity survives the new rows getting new
  /// auto-increment ids. Keying on `codeName` rather than `id` is the whole
  /// point: ids are positional in the generated manifest and will shift
  /// whenever a route is added or renamed.
  Future<Map<String, ({int usageCount, DateTime? lastUsedAt})>> usageByCodeName() async {
    final rows = await _database.select(_database.jeepneyRoutes).get();
    return {
      for (final row in rows)
        row.codeName: (usageCount: row.usageCount, lastUsedAt: row.lastUsedAt),
    };
  }

  /// Removes all bundled route data, leaving the database ready for a re-seed.
  ///
  /// Popularity history is captured by [usageByCodeName] first and written
  /// back by the caller, so this genuinely does lose it.
  Future<void> deleteRouteData() async {
    await _database.transaction(() async {
      await _database.delete(_database.routeLandmarks).go();
      await _database.delete(_database.landmarkEntries).go();
      await _database.delete(_database.routeGeometries).go();
      // Trips cascade from routes, which is intended: a stored fare for a
      // route that no longer exists would be a dangling reference.
      await _database.delete(_database.jeepneyRoutes).go();
    });
  }

  Future<void> insertGeometries(List<RouteGeometry> geometries) async {
    await _database.batch((batch) {
      batch.insertAll(
        _database.routeGeometries,
        [
          for (final geometry in geometries)
            RouteGeometriesCompanion.insert(
              codeName: geometry.codeName,
              siteName: geometry.siteName,
              geometry: jsonEncode([
                for (final point in geometry.loop) [point.lng, point.lat],
              ]),
              onewayDm: geometry.onewayDm,
              loopDm: geometry.loopDm,
              declaredKm: geometry.declaredKm,
            ),
        ],
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<void> insertLandmarks(
    List<MapLandmark> landmarks,
    Map<String, int> routeIdByCodeName,
  ) async {
    await _database.transaction(() async {
      for (final landmark in landmarks) {
        final id = await _database.into(_database.landmarkEntries).insert(
              LandmarkEntriesCompanion.insert(
                name: landmark.name,
                category: landmark.category,
                lat: landmark.lat,
                lng: landmark.lng,
                source: landmark.source,
              ),
            );
        await _database.batch((batch) {
          batch.insertAll(
            _database.routeLandmarks,
            [
              for (final codeName in landmark.routeCodes)
                if (routeIdByCodeName[codeName] != null)
                  RouteLandmarksCompanion.insert(
                    routeId: routeIdByCodeName[codeName]!,
                    landmarkId: id,
                  ),
            ],
            mode: InsertMode.insertOrIgnore,
          );
        });
      }
    });
  }

  /// Route ids keyed by code name, for wiring up landmark links after a seed.
  Future<Map<String, int>> routeIdByCodeName() async {
    final rows = await _database.select(_database.jeepneyRoutes).get();
    return {for (final row in rows) row.codeName: row.id};
  }

  /// Writes a preserved popularity record back onto a re-seeded route.
  Future<void> restoreUsage(
    String codeName, {
    required int usageCount,
    required DateTime? lastUsedAt,
  }) async {
    if (usageCount <= 0 && lastUsedAt == null) return;
    await (_database.update(_database.jeepneyRoutes)
          ..where((table) => table.codeName.equals(codeName)))
        .write(
      JeepneyRoutesCompanion(
        usageCount: Value(usageCount),
        lastUsedAt: Value(lastUsedAt),
      ),
    );
  }

  Future<Map<int, List<RouteStop>>> _loadStops() {
    return _loadStopsFor(null);
  }

  Future<Map<int, List<RouteStop>>> _loadStopsFor(List<int>? routeIds) async {
    final query = _database.select(_database.routeStops)
      ..orderBy([(table) => OrderingTerm.asc(table.sequence)]);
    if (routeIds != null) {
      query.where((table) => table.routeId.isIn(routeIds));
    }

    final rows = await query.get();
    final grouped = <int, List<RouteStop>>{};
    for (final row in rows) {
      grouped.putIfAbsent(row.routeId, () => []).add(_toStop(row));
    }
    return grouped;
  }

  List<String> _viaLabels(String displayName) {
    return displayName
        .split(RegExp(r'\s+via\s+', caseSensitive: false))
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();
  }
}
