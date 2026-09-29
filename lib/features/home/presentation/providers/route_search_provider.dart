import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/geo.dart';
import '../../../../data/models/jeepney_route.dart';
import '../../../../data/providers/route_providers.dart';

class RouteSearchQuery extends Notifier<String> {
  @override
  String build() => '';

  void update(String value) => state = value;

  void clear() => state = '';
}

final routeSearchQueryProvider = NotifierProvider<RouteSearchQuery, String>(
  RouteSearchQuery.new,
);

/// Landmarks matching the current query, best match first.
///
/// Ordering is by how directly the landmark answers the query rather than by
/// any curated rank: an exact name beats a name prefix, which beats a name
/// that merely contains the term, which beats a category hit. So "Abreeza
/// Mall" puts Abreeza Mall first and "mall" lists the malls alphabetically.
final landmarkMatchesProvider = Provider<AsyncValue<List<MapLandmark>>>((ref) {
  final landmarksAsync = ref.watch(landmarkListProvider);
  final query = ref.watch(routeSearchQueryProvider).trim().toLowerCase();

  return landmarksAsync.whenData((landmarks) {
    if (query.isEmpty) return const <MapLandmark>[];

    final scored = <({MapLandmark landmark, int rank})>[];
    for (final landmark in landmarks) {
      final rank = _rank(landmark, query);
      if (rank != null) scored.add((landmark: landmark, rank: rank));
    }
    scored.sort((a, b) {
      final byRank = a.rank.compareTo(b.rank);
      if (byRank != 0) return byRank;
      return a.landmark.name.toLowerCase().compareTo(
        b.landmark.name.toLowerCase(),
      );
    });
    return [for (final entry in scored) entry.landmark];
  });
});

/// Lower is better, null means no match at all.
int? _rank(MapLandmark landmark, String query) {
  final name = landmark.name.toLowerCase();
  if (name == query) return 0;
  if (name.startsWith(query)) return 1;
  if (name.contains(query)) return 2;
  if (landmark.category.toLowerCase().contains(query)) return 3;
  return null;
}

/// Route code names reached through a matching landmark.
///
/// This is what makes the search box honest: it says "Search a route or
/// landmark", and typing a landmark name has to return the routes that pass
/// it, not just routes whose *own* name happens to contain the word.
final landmarkRouteCodesProvider = Provider<Set<String>>((ref) {
  final landmarks = ref.watch(landmarkMatchesProvider).value;
  if (landmarks == null) return const {};

  return {
    for (final landmark in landmarks)
      for (final codeName in landmark.routeCodes) codeName,
  };
});

final filteredRoutesProvider = Provider<AsyncValue<List<JeepneyRoute>>>((ref) {
  final routesAsync = ref.watch(routeListProvider);
  final query = ref.watch(routeSearchQueryProvider).trim().toLowerCase();
  final landmarkCodes = ref.watch(landmarkRouteCodesProvider);

  return routesAsync.whenData((routes) {
    if (query.isEmpty) return routes;
    return routes
        .where(
          (route) =>
              landmarkCodes.contains(route.codeName) ||
              route.displayName.toLowerCase().contains(query) ||
              route.viaLabels.any(
                (landmark) => landmark.toLowerCase().contains(query),
              ),
        )
        .toList();
  });
});
