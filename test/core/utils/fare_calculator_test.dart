import 'package:davao_jeepney/core/utils/fare_calculator.dart';
import 'package:davao_jeepney/core/utils/money.dart';
import 'package:davao_jeepney/data/models/passenger_category.dart';
import 'package:flutter_test/flutter_test.dart';

/// Faithful transcription of `AlgoHandler.calculate()` from the legacy Java
/// project, used to prove the Dart port has not drifted from the original.
class LegacyAlgo {
  static double calculate({
    required int kmStart,
    required int kmEnd,
    required bool isRegular,
  }) {
    double km = 0;
    double fare = 0;

    if (kmStart < kmEnd) {
      km = (kmEnd - kmStart).toDouble();
    } else if (kmStart > kmEnd) {
      km = (kmStart - kmEnd).toDouble();
    }

    var temp = km;

    if (temp == 0) {
      fare = 0;
    } else {
      while (true) {
        if (temp > 4) {
          fare += 1.50;
          temp--;
        } else if (temp <= 4 && temp > 0) {
          fare += 13;
          break;
        } else {
          break;
        }
      }
      if (!isRegular) {
        fare -= 2;
      }
    }

    return fare;
  }
}

void main() {
  const calculator = FareCalculator();

  group('FareCalculator parity with legacy AlgoHandler', () {
    test('matches the legacy algorithm across the full distance range', () {
      for (var start = 0; start <= 60; start++) {
        for (var end = 0; end <= 60; end++) {
          for (final category in PassengerCategory.values) {
            final actual = calculator
                .calculate(
                  startKm: start,
                  endKm: end,
                  category: category,
                )
                .total
                .pesos;

            final expected = LegacyAlgo.calculate(
              kmStart: start,
              kmEnd: end,
              isRegular: !category.isDiscounted,
            );

            expect(
              actual,
              closeTo(expected, 0.0001),
              reason:
                  'Mismatch for $category from km $start to $end: '
                  'got $actual, legacy expected $expected',
            );
          }
        }
      }
    });
  });

  group('FareCalculator base fares', () {
    test('charges nothing when start and end are the same stop', () {
      final result = calculator.calculate(
        startKm: 12,
        endKm: 12,
        category: PassengerCategory.regular,
      );

      expect(result.total, Money.zero);
      expect(result.distanceKm, 0);
      expect(result.billableKm, 0);
    });

    test('charges the flat base fare within the included 4 km', () {
      for (final km in [1, 2, 3, 4]) {
        final result = calculator.calculate(
          startKm: 0,
          endKm: km,
          category: PassengerCategory.regular,
        );

        expect(result.baseFare, const Money(1300), reason: '$km km');
        expect(result.distanceCharge, Money.zero, reason: '$km km');
        expect(result.total, const Money(1300), reason: '$km km');
      }
    });

    test('adds 1.50 per km beyond the included 4 km', () {
      final result = calculator.calculate(
        startKm: 0,
        endKm: 10,
        category: PassengerCategory.regular,
      );

      expect(result.billableKm, 6);
      expect(result.distanceCharge, const Money(900));
      expect(result.total, const Money(2200));
    });

    test('is direction independent', () {
      final forward = calculator.calculate(
        startKm: 5,
        endKm: 25,
        category: PassengerCategory.regular,
      );
      final backward = calculator.calculate(
        startKm: 25,
        endKm: 5,
        category: PassengerCategory.regular,
      );

      expect(forward.total, backward.total);
    });
  });

  group('FareCalculator discounts', () {
    test('applies the 2.00 deduction to every non-regular category', () {
      for (final category in [
        PassengerCategory.student,
        PassengerCategory.senior,
        PassengerCategory.pwd,
      ]) {
        final result = calculator.calculate(
          startKm: 0,
          endKm: 10,
          category: category,
        );

        expect(result.hasDeduction, isTrue, reason: category.label);
        expect(result.deduction, const Money(200), reason: category.label);
        expect(result.total, const Money(2000), reason: category.label);
      }
    });

    test('does not discount regular riders', () {
      final result = calculator.calculate(
        startKm: 0,
        endKm: 10,
        category: PassengerCategory.regular,
      );

      expect(result.hasDeduction, isFalse);
      expect(result.total, const Money(2200));
    });

    test('never applies a discount on a zero-distance trip', () {
      final result = calculator.calculate(
        startKm: 7,
        endKm: 7,
        category: PassengerCategory.pwd,
      );

      expect(result.total, Money.zero);
      expect(result.hasDeduction, isFalse);
    });

    test('produces a non-negative total for every category', () {
      for (final category in PassengerCategory.values) {
        for (var km = 0; km <= 40; km++) {
          final total = calculator
              .calculate(startKm: 0, endKm: km, category: category)
              .total;
          expect(total.centavos, greaterThanOrEqualTo(0));
        }
      }
    });
  });

  group('PassengerCategory', () {
    test('parses legacy labels case-insensitively', () {
      expect(PassengerCategory.fromLabel('Regular'), PassengerCategory.regular);
      expect(PassengerCategory.fromLabel('student'), PassengerCategory.student);
      expect(PassengerCategory.fromLabel('SENIOR'), PassengerCategory.senior);
      expect(PassengerCategory.fromLabel('pwd'), PassengerCategory.pwd);
    });

    test('falls back to regular for unknown labels', () {
      expect(PassengerCategory.fromLabel('nonsense'), PassengerCategory.regular);
    });

    test('matches the four categories offered by the legacy login screen', () {
      expect(
        PassengerCategory.values.map((category) => category.label),
        ['Regular', 'Student', 'Senior', 'PWD'],
      );
    });
  });
}
