import 'package:davao_jeepney/core/utils/fare_calculator.dart';
import 'package:davao_jeepney/core/utils/money.dart';
import 'package:davao_jeepney/data/models/passenger_category.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const calculator = FareCalculator();

  group('FareCalculator base fares', () {
    test('charges nothing when start and end are the same stop', () {
      final result = calculator.calculateByKmIndex(
        startKmIndex: 12,
        endKmIndex: 12,
        category: PassengerCategory.regular,
      );

      expect(result.total, Money.zero);
      expect(result.distanceKm, 0);
      expect(result.billableKm, 0);
    });

    test('charges the flat base fare within the included 4 km', () {
      for (final km in [1, 2, 3, 4]) {
        final result = calculator.calculateByKmIndex(
          startKmIndex: 0,
          endKmIndex: km,
          category: PassengerCategory.regular,
        );

        expect(result.baseFare, const Money(1400), reason: '$km km');
        expect(result.distanceCharge, Money.zero, reason: '$km km');
        expect(result.total, const Money(1400), reason: '$km km');
      }
    });

    test('adds 2.00 per km beyond the included 4 km', () {
      final result = calculator.calculateByKmIndex(
        startKmIndex: 0,
        endKmIndex: 10,
        category: PassengerCategory.regular,
      );

      expect(result.billableKm, 6);
      expect(result.distanceCharge, const Money(1200));
      expect(result.total, const Money(2600));
    });

    test('is direction independent', () {
      final forward = calculator.calculateByKmIndex(
        startKmIndex: 5,
        endKmIndex: 25,
        category: PassengerCategory.regular,
      );
      final backward = calculator.calculateByKmIndex(
        startKmIndex: 25,
        endKmIndex: 5,
        category: PassengerCategory.regular,
      );

      expect(forward.total, backward.total);
    });
  });

  group('FareCalculator discounts', () {
    test('applies a 20% discount to every non-regular category', () {
      for (final category in [
        PassengerCategory.student,
        PassengerCategory.senior,
        PassengerCategory.pwd,
      ]) {
        final result = calculator.calculateByKmIndex(
          startKmIndex: 0,
          endKmIndex: 10,
          category: category,
        );

        expect(result.hasDeduction, isTrue, reason: category.label);
        expect(result.deduction, const Money(520), reason: category.label);
        expect(result.total, const Money(2080), reason: category.label);
      }
    });

    test('discounts the flat base fare within the included 4 km', () {
      final result = calculator.calculateByKmIndex(
        startKmIndex: 0,
        endKmIndex: 4,
        category: PassengerCategory.senior,
      );

      expect(result.deduction, const Money(280));
      expect(result.total, const Money(1120));
    });

    test('does not discount regular riders', () {
      final result = calculator.calculateByKmIndex(
        startKmIndex: 0,
        endKmIndex: 10,
        category: PassengerCategory.regular,
      );

      expect(result.hasDeduction, isFalse);
      expect(result.total, const Money(2600));
    });

    test('never applies a discount on a zero-distance trip', () {
      final result = calculator.calculateByKmIndex(
        startKmIndex: 7,
        endKmIndex: 7,
        category: PassengerCategory.pwd,
      );

      expect(result.total, Money.zero);
      expect(result.hasDeduction, isFalse);
    });

    test('produces a non-negative total for every category', () {
      for (final category in PassengerCategory.values) {
        for (var km = 0; km <= 40; km++) {
          final total = calculator
              .calculateByKmIndex(
                startKmIndex: 0,
                endKmIndex: km,
                category: category,
              )
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
      expect(
        PassengerCategory.fromLabel('nonsense'),
        PassengerCategory.regular,
      );
    });

    test('matches the four categories offered by the legacy login screen', () {
      expect(PassengerCategory.values.map((category) => category.label), [
        'Regular',
        'Student',
        'Senior',
        'PWD',
      ]);
    });
  });
}
