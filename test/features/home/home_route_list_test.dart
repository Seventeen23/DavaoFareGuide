import 'package:davao_jeepney/core/error/failure.dart';
import 'package:davao_jeepney/core/result/result.dart';
import 'package:davao_jeepney/data/local/database/app_database.dart';
import 'package:davao_jeepney/data/local/seed/route_manifest.dart';
import 'package:davao_jeepney/data/models/jeepney_route.dart';
import 'package:davao_jeepney/data/providers/route_providers.dart';
import 'package:davao_jeepney/data/repositories/route_repository.dart';
import 'package:davao_jeepney/features/home/presentation/providers/route_search_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// What `routeListProvider` hands the home screen on a cold start.
///
/// The user's bug was an empty list rendered under "No matching routes" with
/// an untouched search box, which is only reachable if seeding failed and the
/// failure was swallowed.
void main() {
  // Seeding reads the bundled route and geo assets through rootBundle, which
  // never completes without the test binding.
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late ProviderContainer container;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(database),
      ],
    );
  });
  tearDown(() {
    container.dispose();
    database.close();
  });

  test('a cold start lists every bundled route with an empty query', () async {
    final routes = await container.read(routeListProvider.future);

    expect(routes, hasLength(kRouteManifest.length));
    expect(routes, isNotEmpty);

    final filtered = container.read(filteredRoutesProvider).value;
    expect(
      filtered,
      hasLength(kRouteManifest.length),
      reason: 'an empty query must not filter anything out',
    );
  });

  test('a query narrows the list', () async {
    final all = await container.read(routeListProvider.future);

    container.read(routeSearchQueryProvider.notifier).update('matina');
    final filtered = container.read(filteredRoutesProvider).value!;

    expect(filtered.length, lessThan(all.length));
    expect(filtered.length, greaterThan(0));
    expect(
      filtered.every(
        (route) =>
            route.displayName.toLowerCase().contains('matina') ||
            route.viaLabels.any((l) => l.toLowerCase().contains('matina')),
      ),
      isTrue,
    );
  });

  test('a nonsense query yields an empty list, not an error', () async {
    await container.read(routeListProvider.future);

    container.read(routeSearchQueryProvider.notifier).update('zzzznotaroute');

    final state = container.read(filteredRoutesProvider);
    expect(state.hasError, isFalse);
    expect(state.value, isEmpty);
  });

  test('a failed seed surfaces as an error rather than an empty list', () async {
    // A repository whose seeding fails is the shape of the original bug: the
    // route tables end up empty, and the only question is what the home screen
    // is handed. Swallowing the failure is what produced "no matching routes".
    final failing = ProviderContainer(
      overrides: [
        routeRepositoryProvider.overrideWithValue(_FailingSeedRepository()),
      ],
    );
    addTearDown(failing.dispose);

    // The error has to reach the widget tree, so assert on the state the
    // home screen actually listens to rather than on the future.
    final subscription = failing.listen(
      routeListProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);
    await pumpEventQueue();

    expect(
      failing.read(routeListProvider).error,
      isA<Failure>().having((f) => f.code, 'code', AppFailure.database),
      reason: 'a failed seed must not reach the screen as an empty list',
    );
  });
}

/// Seeding that always fails, standing in for a corrupt or unwritable database.
class _FailingSeedRepository extends RouteRepository {
  _FailingSeedRepository()
    : super(
        database: AppDatabase.forTesting(NativeDatabase.memory()),
      );

  @override
  Future<Result<int>> seedIfStale() async => Result.failure(
    Failure(AppFailure.database, 'Route seeding failed.'),
  );

  @override
  Future<Result<List<JeepneyRoute>>> getAllRoutes() async =>
      Result.success(const <JeepneyRoute>[]);
}
