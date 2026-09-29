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

  /// WGS84 position of the stop, when it could be placed on the route
  /// polyline. Null means "unknown", and null is normal: most jeepney stop
  /// names are local to a barangay and OpenStreetMap has never heard of them.
  ///
  /// These are for drawing the map. They are deliberately not the fare basis -
  /// see [TripDistance] for why the published kilometre marks still price a
  /// ride.
  RealColumn get lat => real().nullable()();
  RealColumn get lng => real().nullable()();

  /// How far along the one-way leg this stop sits, in integer decimetres.
  ///
  /// Null when [lat] is null, and null on the four routes whose extracted
  /// geometry disagrees with the published [JeepneyRoutes.totalKm] by more
  /// than 3 km. Used only to show a distance, never to price a fare.
  IntColumn get distDm => integer().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {routeId, sequence},
  ];
}

/// The road shape of a route, as a GeoJSON LineString.
///
/// One row per route that has verified geometry. The 38 routes without
/// geometry, and the 15 quarantined in assets/geo/unverified, are simply
/// absent - there is no row to draw and no fare distance to read.
@DataClassName('RouteGeometryRow')
class RouteGeometries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get codeName => text().unique()();
  TextColumn get siteName => text()();
  TextColumn get geometry => text()();

  /// Measured length of the one-way leg, and of the whole out-and-back loop.
  /// Decimetres, to match [RouteStops.distDm].
  IntColumn get onewayDm => integer()();
  IntColumn get loopDm => integer()();

  /// The published length from the route manifest, in whole km. Kept beside
  /// the measurement so a divergence is visible rather than silent.
  IntColumn get declaredKm => integer()();
}

/// A place worth putting on the map: a mall, a terminal, a hospital.
@DataClassName('LandmarkEntryRow')
class LandmarkEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get category => text()();
  RealColumn get lat => real()();
  RealColumn get lng => real()();

  /// `curated` (hand-picked), `wikidata` (has a Wikipedia article) or `osm`
  /// (matched tags inside a route corridor). The provenance is kept because
  /// the `osm` ones are the only ones a human has not confirmed - see
  /// assets/landmarks_REVIEW.md.
  TextColumn get source => text()();
}

@DataClassName('RouteLandmarkRow')
class RouteLandmarks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get routeId =>
      integer().references(JeepneyRoutes, #id, onDelete: KeyAction.cascade)();
  IntColumn get landmarkId =>
      integer().references(LandmarkEntries, #id, onDelete: KeyAction.cascade)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {routeId, landmarkId},
  ];
}

/// Small key/value store, used to remember which version of the bundled route
/// data is currently seeded.
@DataClassName('AppMetaRow')
class AppMeta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
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
