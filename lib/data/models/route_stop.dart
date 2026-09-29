import 'package:equatable/equatable.dart';

class RouteStop extends Equatable {
  const RouteStop({
    required this.name,
    required this.kmIndex,
    required this.sequence,
    this.lat,
    this.lng,
    this.distDm,
  });

  final String name;
  final int kmIndex;
  final int sequence;

  /// WGS84 position on the route polyline, when known. Null for the large
  /// majority of stops - see `assets/geo/stops_REVIEW.md`.
  final double? lat;
  final double? lng;

  /// Distance along the one-way leg in integer decimetres. Null when the
  /// position is unknown, and null on routes whose geometry is disputed.
  ///
  /// This is display information. Fares are priced from [kmIndex] so that a
  /// passenger always pays the tariff in the published kilometre marks.
  final int? distDm;

  bool get hasPosition => lat != null && lng != null;

  /// Whether the measured road distance is trustworthy enough to show.
  ///
  /// Requires both a position and a distance, and at least a tenth of a
  /// kilometre of separation, so two stops on the same metre do not display
  /// "0.0 km by road" beside a non-zero fare.
  bool get hasMeasuredDistance => hasPosition && distDm != null;

  RouteStop copyWith({
    double? lat,
    double? lng,
    int? distDm,
  }) =>
      RouteStop(
        name: name,
        kmIndex: kmIndex,
        sequence: sequence,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        distDm: distDm ?? this.distDm,
      );

  @override
  List<Object?> get props => [name, kmIndex, sequence, lat, lng, distDm];
}
