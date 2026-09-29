import 'package:davao_jeepney/data/local/database/app_database.dart';
import 'package:davao_jeepney/data/local/seed/route_manifest.dart';
import 'package:davao_jeepney/data/repositories/route_repository.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// The re-seed path, which nothing else covers.
///
/// A real install re-seeds the moment the bundled assets change, and that is
/// the path that deletes every route row and writes them back. It is also the
/// path that carries popularity history across, so a bug here is invisible on
/// a fresh install and shows up as a route list that is suddenly empty.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late RouteRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = RouteRepository(database: database);
  });
  tearDown(() => database.close());

  /// Simulates an install whose database predates the current bundled assets.
  Future<void> markAsStale() => database.setContentVersion('stale-fingerprint');

  test('cascade deletes are armed', () async {
    // The re-seed relies on ON DELETE CASCADE, and SQLite leaves foreign keys
    // off unless something turns them on.
    final pragma =
        await database.customSelect('PRAGMA foreign_keys').getSingle();
    expect(pragma.data['foreign_keys'], 1);

    await database.into(database.jeepneyRoutes).insert(
          JeepneyRoutesCompanion.insert(
            id: const Value(1),
            codeName: 'x',
            displayName: 'X',
            stopCount: 1,
            totalKm: 1,
          ),
        );
    await database.into(database.routeStops).insert(
          RouteStopsCompanion.insert(
            routeId: 1,
            name: 'A',
            kmIndex: 0,
            sequence: 0,
          ),
        );

    await database.delete(database.jeepneyRoutes).go();

    expect(
      await database.select(database.routeStops).get(),
      isEmpty,
      reason: 'deleting a route must take its stops with it',
    );
  });

  test('re-seeds every route when the bundled assets change', () async {
    final first = await repository.seedIfStale();
    expect(first.dataOrNull, kRouteManifest.length);

    await markAsStale();
    final second = await repository.seedIfStale();

    expect(
      second.isSuccess,
      isTrue,
      reason: 'a changed asset must never leave the route list empty: '
          '${second.failureOrNull?.cause ?? second.failureOrNull?.message}',
    );
    expect(second.dataOrNull, kRouteManifest.length);
    expect(
      (await repository.getAllRoutes()).dataOrNull,
      hasLength(kRouteManifest.length),
    );
  });

  test('a re-seed keeps stops, coordinates and geometry', () async {
    await repository.seedIfStale();
    await markAsStale();
    await repository.seedIfStale();

    final route = (await repository.getRouteByCodeName('matina')).dataOrNull;
    expect(route, isNotNull);
    expect(route!.stops, isNotEmpty);
    expect(
      route.stopsInOrder.where((stop) => stop.hasMeasuredDistance),
      isNotEmpty,
      reason: 'map data is written during seeding and must survive a re-seed',
    );

    final geometry = (await repository.getGeometry('matina')).dataOrNull;
    expect(geometry, isNotNull);
    expect(geometry!.onewayDm, greaterThan(0));
  });

  test('a re-seed carries popularity history across', () async {
    await repository.seedIfStale();
    await repository.recordUsage('matina');
    await repository.recordUsage('matina');
    await repository.recordUsage('marilog');

    await markAsStale();
    await repository.seedIfStale();

    final popular = (await repository.getPopularRoutes()).dataOrNull!;
    expect(
      popular.map((route) => route.codeName),
      ['matina', 'marilog'],
      reason: 'usage is keyed by codeName precisely so a re-seed keeps it',
    );
  });

  test('a re-seed drops usage for a route that no longer exists', () async {
    await repository.seedIfStale();
    await repository.recordUsage('matina');

    // Delete the route out from under the preserved history, the way a
    // removed route file would on the next install.
    await (database.delete(
      database.jeepneyRoutes,
    )..where((row) => row.codeName.equals('matina'))).go();

    await markAsStale();
    final seeded = await repository.seedIfStale();

    expect(seeded.isSuccess, isTrue);
    final popular = (await repository.getPopularRoutes()).dataOrNull;
    expect(
      popular?.where((route) => route.codeName == 'matina'),
      isEmpty,
      reason: 'a route that is not in the manifest cannot be popular',
    );
  });

  test('seeding is idempotent when the assets have not changed', () async {
    final first = await repository.seedIfStale();
    final second = await repository.seedIfStale();

    expect(first.dataOrNull, kRouteManifest.length);
    expect(
      second.dataOrNull,
      0,
      reason: 'an unchanged asset must not rebuild the database on every start',
    );
  });

  test('a re-seed leaves a route priced exactly as before', () async {
    await repository.seedIfStale();
    await markAsStale();
    await repository.seedIfStale();

    final route = (await repository.getRouteByCodeName('matina')).dataOrNull!;
    final stops = route.stopsInOrder;

    expect(stops.firstWhere((s) => s.name == 'Bankerohan').kmIndex, 5);
    expect(stops.firstWhere((s) => s.name == 'Agdao').kmIndex, 10);
  });
}
