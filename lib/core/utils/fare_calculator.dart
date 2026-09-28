import '../../data/models/passenger_category.dart';
import 'money.dart';

class FareRules {
  const FareRules({
    this.baseFare = const Money(1400), // Base fare for the first 4 kilometers. 14.00 
    this.includedKilometers = 4,
    this.perKilometer = const Money(200), // +2.00 per kilometer after the first 4 kilometers.
    this.discountedCategoryDeduction = const Money(200), // This is a %. Dont be fooled lol
  });

  final Money baseFare;
  final int includedKilometers;
  final Money perKilometer;
  final Money discountedCategoryDeduction;
}

class FareBreakdown {
  const FareBreakdown({
    required this.distanceKm,
    required this.billableKm,
    required this.baseFare,
    required this.distanceCharge,
    required this.deduction,
    required this.total,
    required this.category,
  });

  final int distanceKm;
  final int billableKm;
  final Money baseFare;
  final Money distanceCharge;
  final Money deduction;
  final Money total;
  final PassengerCategory category;

  bool get hasDeduction => deduction.isNotZero;
}

class FareCalculator {
  const FareCalculator([this.rules = const FareRules()]);

  final FareRules rules;

  FareBreakdown calculate({
    required int startKm,
    required int endKm,
    required PassengerCategory category,
  }) {
    final distanceKm = (startKm - endKm).abs();
    final billableKm =
        distanceKm > rules.includedKilometers ? distanceKm - rules.includedKilometers : 0;

    if (distanceKm == 0) {
      return FareBreakdown(
        distanceKm: 0,
        billableKm: 0,
        baseFare: Money.zero,
        distanceCharge: Money.zero,
        deduction: Money.zero,
        total: Money.zero,
        category: category,
      );
    }

    final baseFare = rules.baseFare;
    final distanceCharge = rules.perKilometer * billableKm;
    final deduction = category.isDiscounted ? rules.discountedCategoryDeduction : Money.zero;

    return FareBreakdown(
      distanceKm: distanceKm,
      billableKm: billableKm,
      baseFare: baseFare,
      distanceCharge: distanceCharge,
      deduction: deduction,
      total: baseFare + distanceCharge - deduction,
      category: category,
    );
  }
}
