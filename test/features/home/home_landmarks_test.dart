import 'package:davao_jeepney/app/theme/app_theme.dart';
import 'package:davao_jeepney/data/local/database/app_database.dart';
import 'package:davao_jeepney/data/local/seed/geo_assets.dart';
import 'package:davao_jeepney/data/models/geo.dart';
import 'package:davao_jeepney/data/models/jeepney_route.dart';
import 'package:davao_jeepney/data/providers/route_providers.dart';
import 'package:davao_jeepney/data/repositories/route_repository.dart';
import 'package:davao_jeepney/features/home/presentation/screens/home_screen.dart';
import 'package:davao_jeepney/features/home/presentation/widgets/landmark_tile.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// The home screen's promise, end to end: the search box says it finds routes
/// *or landmarks*, and a landmark has to turn into the routes that pass it.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late List<MapLandmark> landmarks;
  late List<JeepneyRoute> routes;

  MapLandmark linked() =>
      landmarks.firstWhere((landmark) => landmark.routeCodes.length > 3);

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    landmarks = await GeoAssets().loadLandmarks();
    final repository = RouteRepository(database: database);
    await repository.seedIfStale();
    routes = (await repository.getAllRoutes()).dataOrNull!;
  });
  tearDown(() => database.close());

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          landmarkListProvider.overrideWith((ref) async => landmarks),
          routeListProvider.overrideWith((ref) async => routes),
          popularRoutesProvider.overrideWith((ref) async => const []),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const HomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> search(WidgetTester tester, String value) async {
    await tester.enterText(find.byType(TextField).first, value);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('offers the landmark browser before anything is typed',
      (tester) async {
    await pump(tester);

    expect(find.text('Browse landmarks'), findsOneWidget);
    expect(find.byType(LandmarkTile), findsNothing);
  });

  testWidgets('a landmark query surfaces a landmark, not just routes',
      (tester) async {
    final landmark = linked();
    await pump(tester);
    await search(tester, landmark.name);

    expect(find.text('Landmarks'), findsOneWidget);
    expect(find.byType(LandmarkTile), findsWidgets);

    final tile = find.descendant(
      of: find.byType(LandmarkTile),
      matching: find.text(landmark.name),
    );
    expect(tile, findsOneWidget);
  });

  testWidgets('the route list narrows to the routes passing the landmark',
      (tester) async {
    final landmark = linked();
    await pump(tester);
    await search(tester, landmark.name);

    // The sliver only builds the tiles it is showing, so assert on the count
    // header the list renders rather than on the laid-out widgets.
    expect(
      find.text('${landmark.routeCodes.length} of ${routes.length} routes'),
      findsOneWidget,
      reason: 'typing a landmark answers "which routes pass here?"',
    );
  });

  testWidgets('a nonsense query falls back to the empty search state',
      (tester) async {
    await pump(tester);
    await search(tester, 'zzzznotaplace');

    expect(find.byType(LandmarkTile), findsNothing);
    expect(find.text('No matching routes'), findsOneWidget);
  });

  testWidgets('tapping a landmark completes the query with its full name',
      (tester) async {
    final landmark = linked();
    await pump(tester);
    await search(tester, landmark.name.substring(0, 4));

    final tile = find.descendant(
      of: find.byType(LandmarkTile),
      matching: find.text(landmark.name),
    );
    expect(tile, findsOneWidget);

    await tester.tap(tile);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      find.widgetWithText(TextField, landmark.name),
      findsOneWidget,
      reason: 'the search box has to agree with the list it just filtered',
    );
    expect(
      find.text('${landmark.routeCodes.length} of ${routes.length} routes'),
      findsOneWidget,
    );
  });
}
