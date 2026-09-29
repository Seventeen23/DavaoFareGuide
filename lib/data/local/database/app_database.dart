import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/app_tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    JeepneyRoutes,
    RouteStops,
    RouteGeometries,
    LandmarkEntries,
    RouteLandmarks,
    Trips,
    AppMeta,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      // SQLite ships with foreign keys off and never turns them on by itself.
      // Every ON DELETE CASCADE in app_tables.dart is silently a no-op without
      // this, which makes a re-seed hit UNIQUE(route_id, sequence) on the
      // orphaned stops and leave the user with an empty route list.
      await customStatement('PRAGMA foreign_keys = ON');
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        // Popular-route ranking. Existing installs start with no usage history,
        // so the section stays hidden until the user prices a ride.
        await migrator.addColumn(jeepneyRoutes, jeepneyRoutes.usageCount);
        await migrator.addColumn(jeepneyRoutes, jeepneyRoutes.lastUsedAt);
      }
      if (from < 3) {
        // Stop coordinates and the map tables. The columns stay null until
        // route data is re-seeded; see RouteRepository.reseedIfStale, which
        // matches existing routes by codeName so usage history survives.
        await migrator.addColumn(routeStops, routeStops.lat);
        await migrator.addColumn(routeStops, routeStops.lng);
        await migrator.addColumn(routeStops, routeStops.distDm);
        await migrator.createTable(routeGeometries);
        await migrator.createTable(landmarkEntries);
        await migrator.createTable(routeLandmarks);
        await migrator.createTable(appMeta);
      }
    },
  );

  Future<bool> isSeeded() async {
    final count = await (select(jeepneyRoutes)..limit(1)).get();
    return count.isNotEmpty;
  }

  /// The version of the bundled route data currently in the database.
  Future<String?> get contentVersion async {
    final row = await (select(appMeta)..where((t) => t.key.equals('contentVersion')))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> setContentVersion(String value) =>
      into(appMeta).insertOnConflictUpdate(AppMetaCompanion.insert(
        key: 'contentVersion',
        value: value,
      ));
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(p.join(directory.path, 'davao_jeepney.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
