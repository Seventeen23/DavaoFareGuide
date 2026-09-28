import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/app_tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [JeepneyRoutes, RouteStops, Trips])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        // Popular-route ranking. Existing installs start with no usage history,
        // so the section stays hidden until the user prices a ride.
        await migrator.addColumn(jeepneyRoutes, jeepneyRoutes.usageCount);
        await migrator.addColumn(jeepneyRoutes, jeepneyRoutes.lastUsedAt);
      }
    },
  );

  Future<bool> isSeeded() async {
    final count = await (select(jeepneyRoutes)..limit(1)).get();
    return count.isNotEmpty;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(p.join(directory.path, 'davao_jeepney.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
