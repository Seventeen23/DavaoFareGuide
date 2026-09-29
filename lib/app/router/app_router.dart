import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/fare_calculator/presentation/screens/fare_calculator_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/home/presentation/screens/landmarks_screen.dart';

abstract final class Routes {
  static const String home = '/';
  static const String landmarks = '/landmarks';
  static const String ride = '/ride/:codeName';

  static String rideFor(String codeName) => '/ride/$codeName';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.home,
    routes: [
      GoRoute(
        path: Routes.home,
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'landmarks',
            builder: (context, state) => const LandmarksScreen(),
          ),
          GoRoute(
            path: 'ride/:codeName',
            builder: (context, state) => FareCalculatorScreen(
              codeName: state.pathParameters['codeName'] ?? '',
            ),
          ),
        ],
      ),
    ],
  );
});
