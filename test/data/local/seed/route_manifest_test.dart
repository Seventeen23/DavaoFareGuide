import 'dart:io';

import 'package:davao_jeepney/core/utils/route_file_parser.dart';
import 'package:davao_jeepney/data/local/seed/route_manifest.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const parser = RouteFileParser();

  group('RouteFileParser', () {
    test('parses a well-formed route file', () {
      final result = parser.parse(
        'matina',
        'Matina,0\nMetrobank Matina,1\nBankerohan,5\n',
      );

      expect(result.codeName, 'matina');
      expect(result.stops, hasLength(3));
      expect(result.stops.first.name, 'Matina');
      expect(result.stops.first.kmIndex, 0);
      expect(result.stops.last.name, 'Bankerohan');
      expect(result.stops.last.kmIndex, 5);
    });

    test('preserves stop names that contain slashes and periods', () {
      final result = parser.parse(
        'marilog',
        "Magsaysay Elem. School/Cross. Quimasog,4\nMcDonald's (Ateneo),4\n",
      );

      expect(result.stops.first.name, 'Magsaysay Elem. School/Cross. Quimasog');
      expect(result.stops.last.name, "McDonald's (Ateneo)");
    });

    test('assigns sequence numbers in file order', () {
      final result = parser.parse('demo', 'A,0\nB,3\nC,9\n');

      expect(result.stops.map((stop) => stop.sequence), [0, 1, 2]);
    });

    test('skips blank lines', () {
      final result = parser.parse('demo', 'A,0\n\n\nB,2\n');
      expect(result.stops, hasLength(2));
    });

    test('handles Windows line endings', () {
      final result = parser.parse('demo', 'A,0\r\nB,2\r\n');
      expect(result.stops, hasLength(2));
    });

    test('rejects a stop with a non-numeric km index', () {
      expect(
        () => parser.parse('demo', 'A,0\nB,unknown\n'),
        throwsA(isA<RouteFileParseException>()),
      );
    });

    test('rejects a line without a separator', () {
      expect(
        () => parser.parse('demo', 'A,0\nB\n'),
        throwsA(isA<RouteFileParseException>()),
      );
    });

    test('rejects an empty route', () {
      expect(
        () => parser.parse('demo', '\n\n'),
        throwsA(isA<RouteFileParseException>()),
      );
    });
  });

  group('Route manifest', () {
    test('has a unique code name for every entry', () {
      final codeNames = kRouteManifest.map((entry) => entry.codeName).toList();
      expect(codeNames.toSet().length, codeNames.length);
    });

    test('covers every bundled route asset', () {
      final assetFiles = Directory('assets/routes')
          .listSync()
          .whereType<File>()
          .map((file) => file.uri.pathSegments.last.replaceAll('.txt', ''))
          .toSet();

      final manifest = kRouteManifest.map((entry) => entry.codeName).toSet();

      expect(
        manifest.difference(assetFiles),
        isEmpty,
        reason: 'Manifest references routes with no asset file',
      );
      expect(
        assetFiles.difference(manifest),
        isEmpty,
        reason: 'Bundled route assets missing from the manifest',
      );
    });

    test('resolves each entry to a readable asset path', () {
      for (final entry in kRouteManifest) {
        expect(File(entry.assetPath).existsSync(), isTrue, reason: entry.codeName);
      }
    });

    test('includes routes the legacy app could never load', () {
      final codeNames = kRouteManifest.map((entry) => entry.codeName).toSet();

      expect(
        codeNames,
        containsAll(<String>[
          'ulas',
          'catititpan_via_dacudao_avenue',
          'catititpan_via_jp_laurel_avenue',
          'maa_bankerohan',
          'tibungco_via_cabaguio_avenue',
        ]),
      );
    });

    test('parses every bundled route without error', () {
      for (final entry in kRouteManifest) {
        final contents = File(entry.assetPath).readAsStringSync();
        final parsed = parser.parse(entry.codeName, contents);

        expect(parsed.stops, isNotEmpty, reason: entry.codeName);
        for (var i = 1; i < parsed.stops.length; i++) {
          expect(
            parsed.stops[i].kmIndex,
            greaterThanOrEqualTo(parsed.stops[i - 1].kmIndex),
            reason:
                '${entry.codeName} km indices must not decrease at stop ${parsed.stops[i].name}',
          );
        }
      }
    });
  });
}
