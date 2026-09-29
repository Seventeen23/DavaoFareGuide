import 'package:equatable/equatable.dart';

import '../../../../core/utils/fare_calculator.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/utils/trip_distance.dart';
import '../../../../data/models/passenger_category.dart';

class FareEstimate extends Equatable {
  const FareEstimate({
    required this.regular,
    required this.discounted,
    required this.fareRules,
    this.roadDistance,
  });

  final FareBreakdown regular;
  final FareBreakdown discounted;
  final FareRules fareRules;

  /// The real road distance between the two stops, when both were placed on
  /// the route polyline. Null when the trip had to fall back to the published
  /// kilometre marks.
  ///
  /// This is displayed, never charged. The fare is always [regular]'s total,
  /// which is priced from `kmIndex`.
  final TripDistance? roadDistance;

  /// Kilometres the fare was priced on.
  int get distanceKm => regular.distanceKm;

  /// Whether the road measurement is worth showing next to the fare.
  ///
  /// Requires both ends placed, and at least half a kilometre of separation,
  /// so a short hop does not display "0 km by road" beside a ₱14 fare.
  bool get hasRoadDistance {
    final road = roadDistance;
    if (road == null || !road.isPrecise) return false;
    return road.decimetres >= 5;
  }

  bool get isIdenticalStops => regular.total.isZero;
  Money get saving => regular.total - discounted.total;

  @override
  List<Object?> get props => [
        regular.total,
        discounted.total,
        regular.distanceKm,
        roadDistance,
      ];

  /// Categories that qualify for the discounted fare.
  static const List<PassengerCategory> discountedCategories = [
    PassengerCategory.student,
    PassengerCategory.senior,
    PassengerCategory.pwd,
  ];
}
