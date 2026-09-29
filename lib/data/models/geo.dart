import 'package:equatable/equatable.dart';

/// A WGS84 coordinate pair, in the order the GeoJSON assets use it.
///
/// Deliberately a plain class rather than a `LatLng` so the data layer has no
/// dependency on Flutter. The map widget converts at the edge.
class GeoPoint extends Equatable {
  const GeoPoint({required this.lat, required this.lng});

  factory GeoPoint.fromLonLat(List<double> pair) =>
      GeoPoint(lat: pair[1], lng: pair[0]);

  final double lat;
  final double lng;

  @override
  List<Object?> get props => [lat, lng];
}

/// The road shape of a route.
class RouteGeometry extends Equatable {
  const RouteGeometry({
    required this.codeName,
    required this.siteName,
    required this.loop,
    required this.turnaroundIndex,
    required this.onewayDm,
    required this.loopDm,
    required this.declaredKm,
  });

  final String codeName;
  final String siteName;

  /// The out-and-back loop as stored, which is the whole shape.
  final List<GeoPoint> loop;

  /// Index of the last point on the outbound leg. Everything after it is the
  /// return trip, which no fare covers.
  final int turnaroundIndex;

  /// Measured length of the one-way leg, in decimetres.
  final int onewayDm;

  /// Measured length of the full out-and-back loop, in decimetres.
  final int loopDm;

  /// The published length from the route manifest, in whole kilometres.
  final int declaredKm;

  /// The outbound half of the loop, which is the part a fare covers.
  List<GeoPoint> get oneway =>
      loop.sublist(0, turnaroundIndex.clamp(1, loop.length) + 1);

  @override
  List<Object?> get props =>
      [codeName, siteName, loop, turnaroundIndex, onewayDm, loopDm, declaredKm];
}

/// A place worth showing on the map.
class MapLandmark extends Equatable {
  const MapLandmark({
    required this.name,
    required this.category,
    required this.lat,
    required this.lng,
    required this.source,
    this.routeCodes = const [],
  });

  final String name;
  final String category;
  final double lat;
  final double lng;

  /// `curated`, `wikidata` or `osm`. See `assets/landmarks_REVIEW.md`.
  final String source;

  final List<String> routeCodes;

  @override
  List<Object?> get props => [name, category, lat, lng, source, routeCodes];
}
