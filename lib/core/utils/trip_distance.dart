/// The length of a trip, in integer decimetres along the route.
///
/// Two kinds of trip length exist in this app and they are not equally
/// trustworthy, so this type records which one produced a number.
///
///  - **Precise** distance comes from the route polyline. It is measured to
///    about 0.1 km, and it follows the real road, so it can differ from the
///    published kilometre marks by a few hundred metres.
///  - **Estimated** distance is a fallback: the whole-kilometre `kmIndex`
///    difference from the original route files, scaled by ten. It only applies
///    when one or both stops could not be placed on the polyline. The fare it
///    produces is exactly the fare this app has always produced.
///
/// Keeping the distinction matters because a fare is a legal-ish number in the
/// Philippines. Silently mixing a measured 4.3 km with an estimated 5 km
/// across one route would make the published tariff wrong in a way nobody could
/// audit afterwards. A trip carries its provenance so the UI can be honest
/// about it, and so tests can assert the fallback is actually being taken.
class TripDistance {
  const TripDistance({required this.decimetres, required this.precision});

  /// Builds a distance from a polyline measurement.
  const TripDistance.precise(int decimetres)
      : this(decimetres: decimetres, precision: DistancePrecision.precise);

  /// Builds a distance from whole-kilometre stop marks. [kilometers] is a
  /// whole number of kilometres and is scaled to decimetres.
  factory TripDistance.estimatedKilometers(int kilometers) => TripDistance(
        decimetres: kilometers.abs() * decimetresPerKilometer,
        precision: DistancePrecision.estimated,
      );

  static const int decimetresPerKilometer = 10;

  final int decimetres;
  final DistancePrecision precision;

  bool get isPrecise => precision == DistancePrecision.precise;
  bool get isEstimated => precision == DistancePrecision.estimated;

  /// Distance in whole kilometres, rounded up.
  ///
  /// Rounding up is the whole point of measuring on the polyline. The
  /// published tariff is quoted per kilometre, so 4.1 km is billed as 5 km.
  /// Rounding up rather than to nearest means a passenger is never charged for
  /// less distance than they actually travelled, and it means a rounding
  /// change can never make a fare cheaper.
  int get wholeKilometers => (decimetres + decimetresPerKilometer - 1) ~/ decimetresPerKilometer;

  /// Distance in kilometres to one decimal place, for display only.
  ///
  /// The fare is quoted in whole kilometres, so this is never used to price
  /// anything. It exists so the measured distance can be shown next to the fare
  /// as the number the passenger actually rides: a 5.8 km road trip billed on
  /// 6 km of published marks.
  double get kilometers => decimetres / decimetresPerKilometer;

  @override
  bool operator ==(Object other) =>
      other is TripDistance &&
      other.decimetres == decimetres &&
      other.precision == precision;

  @override
  int get hashCode => Object.hash(decimetres, precision);

  @override
  String toString() =>
      '${wholeKilometers}km (${isPrecise ? 'measured' : 'estimated'} $decimetres dm)';
}

/// How a [TripDistance] was obtained. See [TripDistance].
enum DistancePrecision { precise, estimated }

/// Resolves how long a trip is, preferring measured geometry.
///
/// A trip is measured only when *both* ends are placed on the polyline. If
/// either end is missing, interpolating a partial measured distance would be
/// worse than the published kilometre marks: one end precise and one end
/// estimated is not a distance anyone can defend, so the whole trip falls back.
TripDistance resolveTripDistance({
  required int? startDecimetres,
  required int? endDecimetres,
  required int startKmIndex,
  required int endKmIndex,
}) {
  if (startDecimetres != null && endDecimetres != null) {
    final travelled = (startDecimetres - endDecimetres).abs();
    // Two stops that snapped to the same metre are a zero trip, not a
    // fallback, so it stays precise and the calculator's zero case applies.
    return TripDistance.precise(travelled);
  }
  return TripDistance.estimatedKilometers(startKmIndex - endKmIndex);
}
