import 'package:equatable/equatable.dart';

import 'route_stop.dart';

class JeepneyRoute extends Equatable {
  const JeepneyRoute({
    required this.id,
    required this.codeName,
    required this.displayName,
    required this.landmarks,
    required this.stops,
  });

  final int id;
  final String codeName;
  final String displayName;
  final List<String> landmarks;
  final List<RouteStop> stops;

  int get totalKm => stops.isEmpty ? 0 : stops.last.kmIndex;

  int get stopCount => stops.length;

  List<RouteStop> get stopsInOrder {
    final ordered = [...stops]..sort((a, b) => a.kmIndex.compareTo(b.kmIndex));
    return ordered;
  }

  @override
  List<Object?> get props => [id, codeName, displayName, landmarks, stops];
}
