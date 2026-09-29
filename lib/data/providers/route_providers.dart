import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/result/result.dart';
import '../local/database/app_database.dart';
import '../models/geo.dart';
import '../models/jeepney_route.dart';
import '../repositories/route_repository.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final routeRepositoryProvider = Provider<RouteRepository>((ref) {
  return RouteRepository(database: ref.watch(databaseProvider));
});

final routeListProvider = FutureProvider<List<JeepneyRoute>>((ref) async {
  final repository = ref.watch(routeRepositoryProvider);
  // A failed seed leaves the route tables empty. Surfacing that as an error
  // matters: ignoring it makes the home screen claim the user searched for
  // something that does not exist.
  final seedResult = await repository.seedIfStale();
  final seedFailure = seedResult.failureOrNull;
  if (seedFailure != null) {
    throw seedFailure;
  }
  final Result<List<JeepneyRoute>> result = await repository.getAllRoutes();
  return result.fold((routes) => routes, (failure) => throw failure);
});

final routeDetailProvider = FutureProvider.autoDispose.family<JeepneyRoute, String>((
  ref,
  codeName,
) async {
  final repository = ref.watch(routeRepositoryProvider);
  final Result<JeepneyRoute> result = await repository.getRouteByCodeName(codeName);
  return result.fold((route) => route, (failure) => throw failure);
});

/// Routes the user has priced most often, most-used first.
///
/// Empty until the first fare is calculated. Callers should hide their section
/// rather than render an empty list, and [recordRouteUsage] invalidates this
/// whenever a new count lands.
final popularRoutesProvider = FutureProvider<List<JeepneyRoute>>((ref) async {
  final repository = ref.watch(routeRepositoryProvider);
  final Result<List<JeepneyRoute>> result = await repository.getPopularRoutes();
  return result.fold((routes) => routes, (failure) => throw failure);
});

/// Every landmark in the bundle, whether or not a route serves it.
final landmarkListProvider = FutureProvider<List<MapLandmark>>((ref) async {
  final repository = ref.watch(routeRepositoryProvider);
  final Result<List<MapLandmark>> result = await repository.getAllLandmarks();
  return result.fold((landmarks) => landmarks, (failure) => throw failure);
});

/// Registers a ride against [codeName] and refreshes [popularRoutesProvider].
Future<void> recordRouteUsage(WidgetRef ref, String codeName) async {
  await ref.read(routeRepositoryProvider).recordUsage(codeName);
  ref.invalidate(popularRoutesProvider);
}
