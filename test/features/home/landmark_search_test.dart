import 'package:davao_jeepney/data/local/database/app_database.dart';
import 'package:davao_jeepney/data/models/geo.dart';
import 'package:davao_jeepney/data/providers/route_providers.dart';
import 'package:davao_jeepney/features/home/presentation/providers/route_search_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Landmark search, and the promise the home screen's hint text makes: typing
/// a place returns the routes that pass it.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late ProviderContainer container;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(overrides: [databaseProvider.overrideWithValue(database)]);
    addTearDown(container.dispose);
  });
  tearDown(() => database.close());

  String query(String value) {
    container.read(routeSearchQueryProvider.notifier).update(value);
    return value;
  }

  /// The landmark list is loaded lazily, so a test has to let it land before
  /// the derived providers have anything to rank.
  Future<List<MapLandmark>> ready() => container.read(landmarkListProvider.future);

  Future<List<String>> landmarkNames() async {
    await ready();
    return [
      for (final landmark in container.read(landmarkMatchesProvider).value!)
        landmark.name,
    ];
  }

  test('the bundle has landmarks, and most sit on a route', () async {
    final landmarks = await container.read(landmarkListProvider.future);

    expect(landmarks, hasLength(98));
    expect(
      landmarks.where((l) => l.isLinked).length,
      74,
      reason: 'the unlinked count is a roadmap item, not an accident',
    );
  });

  test('an empty query matches no landmarks, so the section stays hidden', () async {
    query('');

    expect(await landmarkNames(), isEmpty);
  });

  test('a landmark name finds the landmark', () async {
    query('Abreeza');

    expect(await landmarkNames(), contains('Abreeza Mall'));
  });

  test('ranking puts the best answer first', () async {
    query('abreeza mall');

    // Abreeza Mall matches exactly; Gaisano is only a category hit, if it is
    // one at all.
    expect((await landmarkNames()).first, 'Abreeza Mall');
  });

  test('a category is a usable query', () async {
    query('mall');

    final names = await landmarkNames();
    expect(names, isNotEmpty);
    expect(names, contains('Abreeza Mall'));
  });

  test('a nonsense query matches nothing', () async {
    query('zzzznotaplace');

    expect(await landmarkNames(), isEmpty);
  });

  test('a landmark name resolves to the routes that pass it', () async {
    await container.read(routeListProvider.future);
    final landmarks = await ready();
    final abreeza = landmarks.firstWhere((l) => l.name == 'Abreeza Mall');
    expect(abreeza.routeCodes, hasLength(15));

    query('Abreeza Mall');

    final codes = container.read(landmarkRouteCodesProvider);
    expect(codes, contains('bunawan_via_sasa'));

    final routes = container.read(filteredRoutesProvider).value!;
    expect(
      routes.map((route) => route.codeName),
      containsAll(abreeza.routeCodes),
      reason: 'every route serving the landmark has to survive the filter',
    );
  });

  test('a landmark widens results past routes with the same name', () async {
    await ready();
    final all = await container.read(routeListProvider.future);
    final before = all
        .where((r) => r.displayName.toLowerCase().contains('abreeza'))
        .length;
    expect(before, 0, reason: 'no route is called Abreeza; the match is the place');

    query('Abreeza Mall');
    final filtered = container.read(filteredRoutesProvider).value!;

    expect(filtered, hasLength(15));
  });

  test('a landmark on no route resolves to no routes', () async {
    await ready();
    await container.read(routeListProvider.future);
    final landmarks = await ready();
    final unlinked = landmarks.firstWhere((l) => !l.isLinked);
    expect(unlinked.routeCodes, isEmpty);

    query(unlinked.name);

    expect(container.read(landmarkRouteCodesProvider), isEmpty);
    expect(
      container.read(filteredRoutesProvider).value,
      isEmpty,
      reason: 'an unlinked place is a place the app cannot route to yet',
    );
  });

  test('route-name search still works alongside landmarks', () async {
    await ready();
    await container.read(routeListProvider.future);

    query('matina');

    final filtered = container.read(filteredRoutesProvider).value!;
    expect(filtered, isNotEmpty);
    expect(filtered.map((r) => r.codeName), contains('matina'));
  });
}
