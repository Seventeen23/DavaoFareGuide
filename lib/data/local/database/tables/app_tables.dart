import 'package:drift/drift.dart';

@DataClassName('JeepneyRouteRow')
class JeepneyRoutes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get codeName => text().unique()();
  TextColumn get displayName => text()();
  IntColumn get stopCount => integer()();
  IntColumn get totalKm => integer()();

  /// How many times the user has priced a ride on this route. Drives the
  /// "most popular" ranking, so it must reflect real local usage and never a
  /// curated list.
  IntColumn get usageCount =>
      integer().withDefault(const Constant(0))();

  /// Tie-breaker when two routes share the same [usageCount].
  DateTimeColumn get lastUsedAt => dateTime().nullable()();
}

@DataClassName('RouteStopRow')
class RouteStops extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get routeId =>
      integer().references(JeepneyRoutes, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  IntColumn get kmIndex => integer()();
  IntColumn get sequence => integer()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {routeId, sequence},
  ];
}

@DataClassName('TripRow')
class Trips extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get routeId =>
      integer().references(JeepneyRoutes, #id, onDelete: KeyAction.cascade)();
  TextColumn get startStop => text()();
  TextColumn get endStop => text()();
  IntColumn get distanceKm => integer()();
  IntColumn get fareCentavos => integer()();
  TextColumn get category => text()();
  DateTimeColumn get takenAt => dateTime()();
}
