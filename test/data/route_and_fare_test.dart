import 'package:davao_jeepney/core/utils/fare_calculator.dart';
import 'package:davao_jeepney/core/utils/money.dart';
import 'package:davao_jeepney/data/local/database/app_database.dart';
import 'package:davao_jeepney/data/local/seed/route_manifest.dart';
import 'package:davao_jeepney/data/models/passenger_category.dart';
import 'package:davao_jeepney/data/providers/route_providers.dart';
import 'package:davao_jeepney/data/repositories/route_repository.dart';
import 'package:davao_jeepney/features/fare_calculator/presentation/providers/fare_estimate_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;

  setUp(() => database = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => database.close());

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(database)],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('Route seeding', () {
    test('imports every bundled route into the database once', () async {
      final repository = RouteRepository(database: database);

      final first = await repository.seedIfEmpty();
      expect(first.isSuccess, isTrue);
      expect(
        first.dataOrNull,
        kRouteManifest.length,
        reason: 'first run should import every manifest entry',
      );

      final second = await repository.seedIfEmpty();
      expect(second.dataOrNull, 0, reason: 'second run should be a no-op');

      final routes = await repository.getAllRoutes();
      expect(routes.dataOrNull, hasLength(kRouteManifest.length));
    });

    test('stores stops and totals for a known route', () async {
      final repository = RouteRepository(database: database);
      await repository.seedIfEmpty();

      final route = (await repository.getRouteByCodeName('marilog')).dataOrNull;

      expect(route, isNotNull);
      expect(route!.displayName, 'Marilog');
      expect(route.stops, isNotEmpty);
      expect(route.stopsInOrder.first.kmIndex, 0);
      expect(route.totalKm, 59);
    });

    test('returns a not-found failure for an unknown route', () async {
      final repository = RouteRepository(database: database);
      await repository.seedIfEmpty();

      final result = await repository.getRouteByCodeName('does_not_exist');

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull?.code.name, 'notFound');
    });

    test('splits "via" display names into landmarks', () async {
      final repository = RouteRepository(database: database);
      await repository.seedIfEmpty();

      final route =
          (await repository.getRouteByCodeName('tibungco_via_buhangin')).dataOrNull!;

      expect(route.landmarks, ['Tibungco', 'Buhangin']);
    });
  });

  group('Fare estimate', () {
    Future<void> loadRoute(ProviderContainer container) async {
      await container.read(routeListProvider.future);
      await container.read(routeDetailProvider('matina').future);
    }

    test('is null until both stops are chosen', () async {
      final container = makeContainer();
      await loadRoute(container);

      expect(container.read(fareEstimateProvider('matina')), isNull);

      final matina = (await container.read(routeDetailProvider('matina').future));
      container
          .read(fareSelectionProvider('matina').notifier)
          .setOrigin(matina.stopsInOrder.first);

      expect(container.read(fareEstimateProvider('matina')), isNull);
    });

    test('quotes both a regular and a discounted fare', () async {
      final container = makeContainer();
      await loadRoute(container);

      final route = await container.read(routeDetailProvider('matina').future);
      final stops = route.stopsInOrder;
      final bankerohan = stops.firstWhere((stop) => stop.name == 'Bankerohan');
      final agdao = stops.firstWhere((stop) => stop.name == 'Agdao');

      final notifier = container.read(fareSelectionProvider('matina').notifier)
        ..setOrigin(bankerohan)
        ..setDestination(agdao);

      final estimate = container.read(fareEstimateProvider('matina'));

      expect(estimate, isNotNull);
      expect(estimate!.distanceKm, 5);
      expect(estimate.regular.total, const Money(1450));
      expect(estimate.discounted.total, const Money(1250));
      expect(estimate.saving, const Money(200));
      expect(notifier.state.isComplete, isTrue);
    });

    test('swapping origin and destination preserves the fare', () async {
      final container = makeContainer();
      await loadRoute(container);

      final route = await container.read(routeDetailProvider('matina').future);
      final stops = route.stopsInOrder;
      final notifier = container.read(fareSelectionProvider('matina').notifier);

      notifier
        ..setOrigin(stops.first)
        ..setDestination(stops.last);

      final before = container.read(fareEstimateProvider('matina'))!.regular.total;
      notifier.swap();
      final after = container.read(fareEstimateProvider('matina'))!.regular.total;

      expect(after, before);
      expect(
        container.read(fareSelectionProvider('matina')).origin?.name,
        stops.last.name,
      );
    });

    test('flags an identical origin and destination as a zero fare', () async {
      final container = makeContainer();
      await loadRoute(container);

      final route = await container.read(routeDetailProvider('matina').future);
      final stop = route.stopsInOrder.first;

      container.read(fareSelectionProvider('matina').notifier)
        ..setOrigin(stop)
        ..setDestination(stop);

      final estimate = container.read(fareEstimateProvider('matina'));

      expect(estimate!.isIdenticalStops, isTrue);
      expect(estimate.regular.total, Money.zero);
      expect(estimate.discounted.total, Money.zero);
    });
  });

  group('Popular routes', () {
    test('is empty before any ride is recorded', () async {
      final repository = RouteRepository(database: database);
      await repository.seedIfEmpty();

      final popular = await repository.getPopularRoutes();

      expect(
        popular.dataOrNull,
        isEmpty,
        reason: 'the section must stay hidden until real usage exists',
      );
    });

    test('counts each recorded ride against its route', () async {
      final repository = RouteRepository(database: database);
      await repository.seedIfEmpty();

      await repository.recordUsage('matina');
      await repository.recordUsage('matina');
      await repository.recordUsage('marilog');

      final popular = (await repository.getPopularRoutes()).dataOrNull!;

      expect(popular.map((route) => route.codeName), ['matina', 'marilog']);
      expect(popular.first.stops, isNotEmpty, reason: 'stops must still load');
    });

    test('ranks by usage rather than a curated list', () async {
      final repository = RouteRepository(database: database);
      await repository.seedIfEmpty();

      for (var i = 0; i < 5; i++) {
        await repository.recordUsage('tugbok');
      }
      await repository.recordUsage('matina');

      final popular = (await repository.getPopularRoutes()).dataOrNull!;

      expect(popular.first.codeName, 'tugbok');
      expect(popular.map((route) => route.codeName), isNot(contains('toril')));
    });

    test('excludes routes the user has never ridden', () async {
      final repository = RouteRepository(database: database);
      await repository.seedIfEmpty();

      await repository.recordUsage('matina');

      final popular = (await repository.getPopularRoutes()).dataOrNull!;

      expect(popular, hasLength(1));
      expect(popular.single.codeName, 'matina');
    });

    test('breaks ties on most recent use', () async {
      final repository = RouteRepository(database: database);
      await repository.seedIfEmpty();

      await repository.recordUsage('matina');
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await repository.recordUsage('marilog');

      final popular = (await repository.getPopularRoutes()).dataOrNull!;

      expect(
        popular.map((route) => route.codeName),
        ['marilog', 'matina'],
        reason: 'equal counts should put the more recent route first',
      );
    });

    test('honours the requested limit', () async {
      final repository = RouteRepository(database: database);
      await repository.seedIfEmpty();

      for (final codeName in ['matina', 'marilog', 'tugbok']) {
        await repository.recordUsage(codeName);
      }

      final popular = (await repository.getPopularRoutes(limit: 2)).dataOrNull!;

      expect(popular, hasLength(2));
    });

    test('a failed usage write does not break fare calculation', () async {
      final repository = RouteRepository(database: database);
      await repository.seedIfEmpty();

      await repository.recordUsage('does_not_exist');

      final popular = (await repository.getPopularRoutes()).dataOrNull!;
      expect(popular, isEmpty, reason: 'an unknown route records nothing');
    });
  });

  group('End-to-end fare estimate over real route data', () {
    test('prices a real Matina trip for every category', () async {
      final repository = RouteRepository(database: database);
      await repository.seedIfEmpty();

      final route = (await repository.getRouteByCodeName('matina')).dataOrNull!;
      const calculator = FareCalculator();

      final bankerohan = route.stopsInOrder.firstWhere(
        (stop) => stop.name == 'Bankerohan',
      );
      final agdao = route.stopsInOrder.firstWhere(
        (stop) => stop.name == 'Agdao',
      );

      for (final category in PassengerCategory.values) {
        final result = calculator.calculate(
          startKm: bankerohan.kmIndex,
          endKm: agdao.kmIndex,
          category: category,
        );

        expect(result.distanceKm, 5, reason: category.label);
        expect(
          result.total.pesos,
          closeTo(category.isDiscounted ? 12.5 : 14.5, 0.001),
          reason: category.label,
        );
      }
    });
  });
}
