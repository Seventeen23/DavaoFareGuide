import '../../data/models/route_stop.dart';

class ParsedRouteFile {
  const ParsedRouteFile({required this.codeName, required this.stops});

  final String codeName;
  final List<RouteStop> stops;
}

class RouteFileParseException implements Exception {
  const RouteFileParseException(this.codeName, this.line, this.reason);

  final String codeName;
  final int line;
  final String reason;

  @override
  String toString() => 'RouteFileParseException($codeName line $line: $reason)';
}

class RouteFileParser {
  const RouteFileParser();

  ParsedRouteFile parse(String codeName, String contents) {
    final stops = <RouteStop>[];
    final lines = const LineSplitter().convert(contents);

    for (var i = 0; i < lines.length; i++) {
      final raw = lines[i].trim();
      if (raw.isEmpty) continue;

      final separator = raw.lastIndexOf(',');
      if (separator < 0) {
        throw RouteFileParseException(codeName, i + 1, 'missing comma separator');
      }

      final name = raw.substring(0, separator).trim();
      final kmIndexRaw = raw.substring(separator + 1).trim();
      if (name.isEmpty) {
        throw RouteFileParseException(codeName, i + 1, 'empty stop name');
      }

      final kmIndex = int.tryParse(kmIndexRaw);
      if (kmIndex == null) {
        throw RouteFileParseException(codeName, i + 1, 'invalid km index "$kmIndexRaw"');
      }

      stops.add(RouteStop(name: name, kmIndex: kmIndex, sequence: stops.length));
    }

    if (stops.isEmpty) {
      throw RouteFileParseException(codeName, 0, 'route contains no stops');
    }

    return ParsedRouteFile(codeName: codeName, stops: stops);
  }
}

class LineSplitter {
  const LineSplitter();

  List<String> convert(String input) => input.replaceAll('\r\n', '\n').split('\n');
}
