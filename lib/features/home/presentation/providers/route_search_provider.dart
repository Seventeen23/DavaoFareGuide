import 'package:flutter_riverpod/flutter_riverpod.dart';

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

final filteredRoutesProvider = Provider<AsyncValue<List<JeepneyRoute>>>((ref) {
  final routesAsync = ref.watch(routeListProvider);
  final query = ref.watch(routeSearchQueryProvider).trim().toLowerCase();

  return routesAsync.whenData((routes) {
    if (query.isEmpty) return routes;
    return routes
        .where(
          (route) =>
              route.displayName.toLowerCase().contains(query) ||
              route.landmarks.any(
                (landmark) => landmark.toLowerCase().contains(query),
              ),
        )
        .toList();
  });
});
