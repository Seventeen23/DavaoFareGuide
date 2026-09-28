import 'package:equatable/equatable.dart';

import '../../../../core/utils/fare_calculator.dart';
import '../../../../core/utils/money.dart';
import '../../../../data/models/passenger_category.dart';

class FareEstimate extends Equatable {
  const FareEstimate({
    required this.regular,
    required this.discounted,
    required this.fareRules,
  });

  final FareBreakdown regular;
  final FareBreakdown discounted;
  final FareRules fareRules;

  int get distanceKm => regular.distanceKm;
  bool get isIdenticalStops => regular.total.isZero;
  Money get saving => regular.total - discounted.total;

  @override
  List<Object?> get props => [regular.total, discounted.total, regular.distanceKm];

  /// Categories that qualify for the discounted fare.
  static const List<PassengerCategory> discountedCategories = [
    PassengerCategory.student,
    PassengerCategory.senior,
    PassengerCategory.pwd,
  ];
}
