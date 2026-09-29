import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/fare_calculator.dart';
import '../../../../core/utils/trip_distance.dart';
import '../../../../data/models/passenger_category.dart';
import '../../../../data/models/route_stop.dart';
import '../../../../data/providers/route_providers.dart';
import '../models/fare_estimate.dart';

class FareSelectionState {
  const FareSelectionState({this.origin, this.destination});

  final RouteStop? origin;
  final RouteStop? destination;

  bool get isComplete => origin != null && destination != null;

  FareSelectionState withOrigin(RouteStop stop) =>
      FareSelectionState(origin: stop, destination: destination);

  FareSelectionState withDestination(RouteStop stop) =>
      FareSelectionState(origin: origin, destination: stop);

  FareSelectionState swap() => FareSelectionState(origin: destination, destination: origin);
}

class FareSelectionNotifier extends Notifier<FareSelectionState> {
  FareSelectionNotifier(this.codeName);

  final String codeName;

  @override
  FareSelectionState build() => const FareSelectionState();

  void setOrigin(RouteStop stop) => state = state.withOrigin(stop);

  void setDestination(RouteStop stop) => state = state.withDestination(stop);

  void clearDestination() =>
      state = FareSelectionState(origin: state.origin, destination: null);

  void swap() => state = state.swap();
}

final fareSelectionProvider =
    NotifierProvider.family<FareSelectionNotifier, FareSelectionState, String>(
      FareSelectionNotifier.new,
      isAutoDispose: true,
    );

final fareEstimateProvider =
    Provider.autoDispose.family<FareEstimate?, String>((ref, codeName) {
      final selection = ref.watch(fareSelectionProvider(codeName));
      if (!selection.isComplete) return null;

      final route = ref.watch(routeDetailProvider(codeName)).value;
      if (route == null) return null;

      const calculator = FareCalculator();
      final origin = selection.origin!;
      final destination = selection.destination!;

      // The fare is priced from the published kilometre marks. Measured road
      // geometry is carried alongside as information only - see
      // `assets/geo/stops_REVIEW.md` for why it is not authoritative.
      FareBreakdown priceFor(PassengerCategory category) => calculator.calculateByKmIndex(
        startKmIndex: origin.kmIndex,
        endKmIndex: destination.kmIndex,
        category: category,
      );

      return FareEstimate(
        regular: priceFor(PassengerCategory.regular),
        discounted: priceFor(PassengerCategory.student),
        fareRules: calculator.rules,
        roadDistance: resolveTripDistance(
          startDecimetres: origin.distDm,
          endDecimetres: destination.distDm,
          startKmIndex: origin.kmIndex,
          endKmIndex: destination.kmIndex,
        ),
      );
    });
