import 'package:davao_jeepney/app/theme/app_theme.dart';
import 'package:davao_jeepney/core/utils/fare_calculator.dart';
import 'package:davao_jeepney/core/utils/trip_distance.dart';
import 'package:davao_jeepney/data/models/passenger_category.dart';
import 'package:davao_jeepney/features/fare_calculator/presentation/models/fare_estimate.dart';
import 'package:davao_jeepney/features/fare_calculator/presentation/widgets/fare_estimate_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The fare card is the only place the app shows a distance, so these tests
/// pin down the thing that is easy to get wrong: the priced kilometre mark and
/// the measured road distance are different numbers, and only the first one is
/// ever charged.
void main() {
  const calculator = FareCalculator();

  FareBreakdown priced(int km) => calculator.calculateByKmIndex(
    startKmIndex: 0,
    endKmIndex: km,
    category: PassengerCategory.regular,
  );

  FareEstimate estimateWith({TripDistance? road, int km = 9}) => FareEstimate(
    regular: priced(km),
    discounted: calculator.calculateByKmIndex(
      startKmIndex: 0,
      endKmIndex: km,
      category: PassengerCategory.student,
    ),
    fareRules: calculator.rules,
    roadDistance: road,
  );

  Future<void> pump(WidgetTester tester, FareEstimate estimate) {
    return tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: FareEstimateCard(estimate: estimate)),
      ),
    );
  }

  testWidgets('shows both the priced km and the measured road distance',
      (tester) async {
    await pump(tester, estimateWith(road: const TripDistance.precise(52)));

    expect(find.text('9 km'), findsOneWidget);
    expect(find.text('5.2 km by road'), findsOneWidget);
    expect(
      find.textContaining('5.2 km by road'),
      findsOneWidget,
      reason: 'the tariff line should say which number is which',
    );
  });

  testWidgets('hides the road distance when it is only estimated',
      (tester) async {
    await pump(tester, estimateWith(road: TripDistance.estimatedKilometers(9)));

    expect(find.text('9 km'), findsOneWidget);
    expect(
      find.textContaining('by road'),
      findsNothing,
      reason: 'an estimated distance must not be presented as measured',
    );
  });

  testWidgets('hides the road distance for a sub-half-kilometre hop',
      (tester) async {
    await pump(tester, estimateWith(road: const TripDistance.precise(4)));

    expect(
      find.textContaining('by road'),
      findsNothing,
      reason: 'two stops on nearly the same metre say nothing useful',
    );
  });

  testWidgets('says the fare follows the published km, not the road',
      (tester) async {
    await pump(tester, estimateWith(road: const TripDistance.precise(52)));

    expect(
      find.textContaining('charged on the published km, not the road distance'),
      findsOneWidget,
      reason: 'a measured distance is information, not a charge',
    );
  });

  testWidgets('still names the published km when nothing was measured',
      (tester) async {
    await pump(tester, estimateWith(km: 5));

    expect(find.text('5 km'), findsOneWidget);
    expect(
      find.textContaining('charged on the route’s published km'),
      findsOneWidget,
    );
  });

  testWidgets('prompts for two different stops when they are identical',
      (tester) async {
    await pump(
      tester,
      FareEstimate(
        regular: calculator.calculate(
          distance: TripDistance.precise(0),
          category: PassengerCategory.regular,
        ),
        discounted: calculator.calculate(
          distance: TripDistance.precise(0),
          category: PassengerCategory.student,
        ),
        fareRules: calculator.rules,
      ),
    );

    expect(find.text('Same stop selected'), findsOneWidget);
    expect(find.textContaining('by road'), findsNothing);
  });
}
