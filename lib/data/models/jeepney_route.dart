import 'package:equatable/equatable.dart';

import 'route_stop.dart';

class JeepneyRoute extends Equatable {
  const JeepneyRoute({
    required this.id,
    required this.codeName,
    required this.displayName,
    required this.viaLabels,
    required this.stops,
  });

  final int id;
  final String codeName;
  final String displayName;

  /// Name fragments from the display name, e.g. "Bunawan via Sasa" becomes
  /// ["Bunawan", "Sasa"]. Search and display only.
  ///
  /// Not to be confused with the map landmarks in `assets/landmarks.json`,
  /// which are real places with coordinates.
  final List<String> viaLabels;

  final List<RouteStop> stops;

  /// Published length in whole kilometres, from the bundled manifest.
  int get totalKm => stops.isEmpty ? 0 : stopsInOrder.last.kmIndex;

  int get stopCount => stops.length;

  List<RouteStop> get stopsInOrder {
    final ordered = [...stops]..sort((a, b) => a.kmIndex.compareTo(b.kmIndex));
    return ordered;
  }

  /// Whether any stop was placed on a verified polyline, which is what makes
  /// the map worth showing for this route.
  bool get hasMeasuredStops => stops.any((stop) => stop.hasMeasuredDistance);

  /// Stops that can be drawn at a real position. Most routes have gaps; the
  /// map falls back to interpolating between measured stops so it never shows
  /// a marker in the wrong place.
  List<RouteStop> get positionedStops =>
      stops.where((stop) => stop.hasPosition).toList(growable: false);

  @override
  List<Object?> get props => [id, codeName, displayName, viaLabels, stops];
}
