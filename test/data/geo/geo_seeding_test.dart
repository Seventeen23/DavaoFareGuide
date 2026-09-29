import 'package:davao_jeepney/core/utils/fare_calculator.dart';
import 'package:davao_jeepney/core/utils/money.dart';
import 'package:davao_jeepney/core/utils/trip_distance.dart';
import 'package:davao_jeepney/data/local/database/app_database.dart';
import 'package:davao_jeepney/data/models/passenger_category.dart';
import 'package:davao_jeepney/data/repositories/route_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// What the generated map data is allowed to do to the database.
///
/// The invariant these tests protect is the one that keeps the app honest: map
/// data is display-only, and the fare stays a function of the published
/// kilometre marks. A route can therefore have a fully measured trip and still
/// bill the tariff in whole kilometres, and a route can have no geometry at all
/// and still price a ride.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late RouteRepository repository;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = RouteRepository(database: database);
    final seeded = await repository.seedIfStale();
    expect(seeded.isSuccess, isTrue, reason: 'seeding must succeed');
  });
  tearDown(() => database.close());

  group('Stop coordinates', () {
    test('are stored on the stops of a route that has geometry', () async {
      final route = (await repository.getRouteByCodeName('matina')).dataOrNull!;

      expect(
        route.stopsInOrder.where((stop) => stop.hasMeasuredDistance),
        isNotEmpty,
        reason: 'matina is one of the 31 routes the pipeline could place',
      );
    });

    test('leave a route with no geometry priced entirely on kmIndex', () async {
      final route = (await repository.getRouteByCodeName('marilog')).dataOrNull!;

      expect(
        route.stopsInOrder.where((stop) => stop.hasPosition),
        isEmpty,
        reason: 'no geometry was extracted for marilog, so there is no map data',
      );
      expect(
        route.stopsInOrder.every((stop) => stop.kmIndex >= 0),
        isTrue,
        reason: 'the kilometre marks are the fare basis and must survive',
      );
    });

    test('are never invented for a stop the pipeline could not place', () async {
      final route = (await repository.getRouteByCodeName('matina')).dataOrNull!;
      final unplaced = route.stopsInOrder
          .where((stop) => !stop.hasMeasuredDistance)
          .toList();

      expect(unplaced, isNotEmpty);
      for (final stop in unplaced) {
        expect(stop.distDm, isNull, reason: stop.name);
        expect(
          resolveTripDistance(
            startDecimetres: stop.distDm,
            endDecimetres: unplaced.first.distDm,
            startKmIndex: stop.kmIndex,
            endKmIndex: unplaced.first.kmIndex,
          ).isEstimated,
          isTrue,
          reason: '${stop.name}: one unplaced end sends the whole trip back to '
              'the published marks',
        );
      }
    });
  });

  group('A measured distance never changes the fare', () {
    test('a trip priced on kmIndex ignores the road measurement', () async {
      final route = (await repository.getRouteByCodeName('matina')).dataOrNull!;
      final matina = route.stopsInOrder.firstWhere(
        (stop) => stop.name == 'Matina',
      );
      final agdao = route.stopsInOrder.firstWhere(
        (stop) => stop.name == 'Agdao',
      );

      expect(
        matina.hasMeasuredDistance,
        isTrue,
        reason: 'this test needs a route where both ends were placed',
      );
      expect(agdao.hasMeasuredDistance, isTrue);

      // The published marks say 10 km; the measured leg says about 5.8.
      final byKmIndex = TripDistance.estimatedKilometers(10);
      final measured = resolveTripDistance(
        startDecimetres: matina.distDm,
        endDecimetres: agdao.distDm,
        startKmIndex: matina.kmIndex,
        endKmIndex: agdao.kmIndex,
      );

      expect(measured.isPrecise, isTrue);
      expect(
        measured.wholeKilometers,
        lessThan(byKmIndex.wholeKilometers),
        reason: 'the measurement is the tighter number, which is the point',
      );
      expect(
        FareCalculator().calculate(
          distance: byKmIndex,
          category: PassengerCategory.regular,
        ).total,
        const Money(2600),
        reason: 'the fare is the published tariff, whatever the road says',
      );
    });

    test('a trip with only one end placed falls back to the marks', () async {
      final route = (await repository.getRouteByCodeName('matina')).dataOrNull!;
      final bankerohan = route.stopsInOrder.firstWhere(
        (stop) => stop.name == 'Bankerohan',
      );
      final agdao = route.stopsInOrder.firstWhere(
        (stop) => stop.name == 'Agdao',
      );

      expect(bankerohan.hasMeasuredDistance, isFalse);

      final trip = resolveTripDistance(
        startDecimetres: bankerohan.distDm,
        endDecimetres: agdao.distDm,
        startKmIndex: bankerohan.kmIndex,
        endKmIndex: agdao.kmIndex,
      );

      expect(trip.isEstimated, isTrue);
      expect(trip.decimetres, 5 * TripDistance.decimetresPerKilometer);
      expect(
        FareCalculator().calculate(
          distance: trip,
          category: PassengerCategory.regular,
        ).total,
        const Money(1600),
        reason: 'this is the fare the app has always quoted for this trip',
      );
    });
  });

  group('Geometry rows', () {
    test('store the measured and published lengths side by side', () async {
      final rows = await database.select(database.routeGeometries).get();

      expect(rows, isNotEmpty);
      for (final row in rows) {
        expect(row.onewayDm, greaterThan(0), reason: row.codeName);
        expect(row.loopDm, greaterThanOrEqualTo(row.onewayDm), reason: row.codeName);
        expect(row.declaredKm, greaterThan(0), reason: row.codeName);
        expect(row.geometry, startsWith('[['), reason: row.codeName);
      }
    });
  });
}
