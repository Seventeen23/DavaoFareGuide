import 'package:davao_jeepney/app/theme/app_theme.dart';
import 'package:davao_jeepney/data/local/database/app_database.dart';
import 'package:davao_jeepney/data/local/seed/geo_assets.dart';
import 'package:davao_jeepney/data/models/geo.dart';
import 'package:davao_jeepney/data/models/jeepney_route.dart';
import 'package:davao_jeepney/data/providers/route_providers.dart';
import 'package:davao_jeepney/data/repositories/route_repository.dart';
import 'package:davao_jeepney/features/home/presentation/screens/landmarks_screen.dart';
import 'package:davao_jeepney/features/home/presentation/widgets/landmark_tile.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// The landmark browser is the first screen that reads `assets/landmarks.json`,
/// so these tests are mostly about it refusing to lie: how many places are on a
/// route, and what happens when a user taps one with no route serving it.
///
/// The data is loaded in `setUp` and injected, because asset reads do not
/// reliably complete inside the fake-async zone a widget test runs in. The
/// parsing itself is covered by `landmark_search_test.dart`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late List<MapLandmark> landmarks;
  late List<JeepneyRoute> routes;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    landmarks = await GeoAssets().loadLandmarks();
    final repository = RouteRepository(database: database);
    await repository.seedIfStale();
    routes = (await repository.getAllRoutes()).dataOrNull!;
  });
  tearDown(() => database.close());

  MapLandmark linked() =>
      landmarks.firstWhere((landmark) => landmark.routeCodes.length > 3);

  MapLandmark unlinked() =>
      landmarks.firstWhere((landmark) => landmark.routeCodes.isEmpty);

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          landmarkListProvider.overrideWith((ref) async => landmarks),
          routeListProvider.overrideWith((ref) async => routes),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const LandmarksScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Scoped to the tile, because the search field holds the same text.
  Finder tileNamed(String name) => find.descendant(
    of: find.byType(LandmarkTile),
    matching: find.text(name),
  );

  Future<void> search(WidgetTester tester, String value) async {
    await tester.enterText(find.byType(TextField), value);
    // Not pumpAndSettle: a focused TextField blinks its cursor forever, so
    // settling never terminates once the field has text in it.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('lists the bundled landmarks and how many are on a route',
      (tester) async {
    await pump(tester);

    expect(find.textContaining('of ${landmarks.length} on a route'),
        findsOneWidget);
    expect(tileNamed(linked().name), findsOneWidget);
  });

  testWidgets('a linked landmark says how many routes serve it',
      (tester) async {
    final landmark = linked();
    await pump(tester);
    await search(tester, landmark.name);

    expect(
      find.textContaining('${landmark.routeCodes.length} routes'),
      findsOneWidget,
    );
  });

  testWidgets('an unlinked landmark says so instead of showing zero',
      (tester) async {
    final landmark = unlinked();
    await pump(tester);
    await search(tester, landmark.name);

    expect(
      find.textContaining('no route serves this yet'),
      findsOneWidget,
      reason: '"0 routes" would read like a bug rather than missing data',
    );
  });

  testWidgets('tapping an unlinked landmark explains itself', (tester) async {
    final landmark = unlinked();
    await pump(tester);
    await search(tester, landmark.name);

    await tester.tap(tileNamed(landmark.name));
    await tester.pumpAndSettle();

    expect(
      find.text('No jeepney route serves ${landmark.name} yet.'),
      findsOneWidget,
    );
  });

  testWidgets('tapping a linked landmark lists the routes passing it',
      (tester) async {
    final landmark = linked();
    await pump(tester);
    await search(tester, landmark.name);

    await tester.tap(tileNamed(landmark.name));
    await tester.pumpAndSettle();

    expect(
      find.text('${landmark.routeCodes.length} routes pass through here'),
      findsOneWidget,
    );
  });

  testWidgets('a category chip narrows the list', (tester) async {
    await pump(tester);
    // A category that is visible without scrolling the chip strip.
    final attractions = landmarks
        .where((landmark) => landmark.category == 'attraction')
        .length;

    await tester.tap(find.widgetWithText(ChoiceChip, 'Attraction'));
    await tester.pumpAndSettle();

    expect(find.textContaining('of $attractions on a route'), findsOneWidget);
  });

  testWidgets('a nonsense query says so', (tester) async {
    await pump(tester);
    await search(tester, 'zzzznotaplace');

    expect(find.text('No matching landmarks'), findsOneWidget);
  });
}
