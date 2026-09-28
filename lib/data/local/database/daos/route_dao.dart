import 'package:drift/drift.dart';

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
          landmarks: _landmarksFor(row.displayName),
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
      landmarks: _landmarksFor(row.displayName),
      stops: [
        for (final stop in stops)
          RouteStop(
            name: stop.name,
            kmIndex: stop.kmIndex,
            sequence: stop.sequence,
          ),
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
          landmarks: _landmarksFor(row.displayName),
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
              ),
          ],
        );
      }
    });
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
      grouped.putIfAbsent(row.routeId, () => []).add(
        RouteStop(name: row.name, kmIndex: row.kmIndex, sequence: row.sequence),
      );
    }
    return grouped;
  }

  List<String> _landmarksFor(String displayName) {
    return displayName
        .split(RegExp(r'\s+via\s+', caseSensitive: false))
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();
  }
}
