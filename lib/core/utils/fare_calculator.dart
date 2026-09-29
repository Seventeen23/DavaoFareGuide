import '../../data/models/passenger_category.dart';
import 'money.dart';
import 'trip_distance.dart';

class FareRules {
  const FareRules({
    this.baseFare = const Money(1400), // Base fare for the first 4 kilometers. 14.00
    this.includedKilometers = 4,
    this.perKilometer = const Money(200), // +2.00 per kilometer after the first 4 kilometers.
    this.discountPercent = 20,
  });

  final Money baseFare;
  final int includedKilometers;
  final Money perKilometer;
  final int discountPercent;
}

class FareBreakdown {
  const FareBreakdown({
    required this.distance,
    required this.billableKm,
    required this.baseFare,
    required this.distanceCharge,
    required this.deduction,
    required this.total,
    required this.category,
  });

  /// The distance the fare was derived from, carrying whether it was measured
  /// on the polyline or estimated from the published kilometre marks.
  final TripDistance distance;

  /// Whole kilometres travelled, rounded up. This is the number the fare is
  /// quoted against and the number the tariff is published in.
  int get distanceKm => distance.wholeKilometers;

  /// Kilometres past the included distance that are actually charged for.
  final int billableKm;
  final Money baseFare;
  final Money distanceCharge;

  /// The amount saved, not the amount paid. Shown as `-20% discount`.
  final Money deduction;
  final Money total;
  final PassengerCategory category;

  bool get hasDeduction => deduction.isNotZero;
}

class FareCalculator {
  const FareCalculator([this.rules = const FareRules()]);

  final FareRules rules;

  /// Fares a trip of known [distance].
  FareBreakdown calculate({
    required TripDistance distance,
    required PassengerCategory category,
  }) {
    // A zero trip is free and gets no discount. A bug in stop selection can
    // produce one, and charging a discounted base fare for staying put would
    // be worse than the bug.
    if (distance.decimetres == 0) {
      return FareBreakdown(
        distance: distance,
        billableKm: 0,
        baseFare: Money.zero,
        distanceCharge: Money.zero,
        deduction: Money.zero,
        total: Money.zero,
        category: category,
      );
    }

    // The tariff is per whole kilometre, so a measured 4.1 km is billed as
    // 5 km. See TripDistance.wholeKilometers.
    final distanceKm = distance.wholeKilometers;
    final billableKm =
        distanceKm > rules.includedKilometers ? distanceKm - rules.includedKilometers : 0;

    final baseFare = rules.baseFare;
    final distanceCharge = rules.perKilometer * billableKm;
    final total = baseFare + distanceCharge;
    final deduction = category.isDiscounted ? total.percentOff(rules.discountPercent) : Money.zero;

    return FareBreakdown(
      distance: distance,
      billableKm: billableKm,
      baseFare: baseFare,
      distanceCharge: distanceCharge,
      deduction: deduction,
      total: total - deduction, // Deduction is the % value of the total so we just sub it.
      category: category,
    );
  }

  /// Fares a trip described only by the published kilometre marks.
  ///
  /// Kept so the many call sites that do not have geometry stay honest about
  /// what they are using. Anything that *can* resolve a [TripDistance] should
  /// prefer [calculate].
  FareBreakdown calculateByKmIndex({
    required int startKmIndex,
    required int endKmIndex,
    required PassengerCategory category,
  }) =>
      calculate(
        distance: TripDistance.estimatedKilometers(startKmIndex - endKmIndex),
        category: category,
      );
}
