import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../data/models/route_stop.dart';

/// Schematic transit-style diagram of a route.
///
/// The route files carry stop names and kilometre indices but no coordinates,
/// so this draws the route as a map-like line with one node per stop rather
/// than plotting real geography. Selected stops highlight the travelled
/// segment.
class RouteDiagram extends StatelessWidget {
  const RouteDiagram({
    super.key,
    required this.stops,
    this.origin,
    this.destination,
    this.onStopTap,
  });

  final List<RouteStop> stops;
  final RouteStop? origin;
  final RouteStop? destination;
  final ValueChanged<RouteStop>? onStopTap;

  static const _verticalPadding = 34.0;
  static const _nodeSpacing = 30.0;
  static const _minHeight = 260.0;
  static const _maxHeight = 420.0;
  static const _amplitude = 30.0;

  double get _height {
    if (stops.length < 2) return _minHeight;
    final natural = (stops.length - 1) * _nodeSpacing + _verticalPadding * 2;
    return natural.clamp(_minHeight, _maxHeight);
  }

  void _handleTap(Offset localPosition, Size size) {
    if (onStopTap == null || stops.length < 2) return;

    final usable = size.height - _verticalPadding * 2;
    final step = usable / (stops.length - 1);
    final raw = (localPosition.dy - _verticalPadding) / step;
    final index = raw.round().clamp(0, stops.length - 1);
    onStopTap!(stops[index]);
  }

  @override
  Widget build(BuildContext context) {
    if (stops.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(child: Text('No stops to plot.')),
      );
    }

    final diagram = CustomPaint(
      painter: _RouteDiagramPainter(
        stops: stops,
        origin: origin,
        destination: destination,
        amplitude: _amplitude,
        verticalPadding: _verticalPadding,
      ),
      size: Size.infinite,
    );

    if (stops.length < 2) {
      return SizedBox(height: _minHeight, child: diagram);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final height = _height;
        final content = SizedBox(
          height: height,
          width: constraints.maxWidth,
          child: onStopTap == null
              ? diagram
              : GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapUp: (details) => _handleTap(details.localPosition, Size(constraints.maxWidth, height)),
                  child: diagram,
                ),
        );

        if (height >= _maxHeight) {
          return SingleChildScrollView(child: content);
        }
        return content;
      },
    );
  }
}

class _RouteDiagramPainter extends CustomPainter {
  _RouteDiagramPainter({
    required this.stops,
    required this.origin,
    required this.destination,
    required this.amplitude,
    required this.verticalPadding,
  });

  final List<RouteStop> stops;
  final RouteStop? origin;
  final RouteStop? destination;
  final double amplitude;
  final double verticalPadding;

  @override
  void paint(Canvas canvas, Size size) {
    if (stops.isEmpty) return;

    final points = _layout(size);
    final basePaint = _stroke(AppColors.outline, 5);
    final segmentPaint = _stroke(AppColors.brand, 5);

    _drawSmoothPath(canvas, points, basePaint);
    final segment = _highlightPoints(points);
    if (segment.length > 1) {
      _drawSmoothPath(canvas, segment, segmentPaint);
    }

    for (var i = 0; i < points.length; i++) {
      _drawNode(canvas, points[i], i);
    }

    _drawLabels(canvas, points, size);
  }

  Paint _stroke(Color color, double width) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  List<Offset> _layout(Size size) {
    final centerX = size.width / 2;
    final usable = size.height - verticalPadding * 2;
    final step = stops.length > 1 ? usable / (stops.length - 1) : 0.0;

    return [
      for (var i = 0; i < stops.length; i++)
        Offset(
          centerX + math.sin(i * 0.85) * amplitude,
          verticalPadding + step * i,
        ),
    ];
  }

  /// Points between origin and destination inclusive, in travel order.
  List<Offset> _highlightPoints(List<Offset> points) {
    final originIndex = _indexOf(origin);
    final destinationIndex = _indexOf(destination);
    if (originIndex == null || destinationIndex == null) return const [];

    final low = math.min(originIndex, destinationIndex);
    final high = math.max(originIndex, destinationIndex);
    return points.sublist(low, high + 1);
  }

  int? _indexOf(RouteStop? stop) {
    if (stop == null) return null;
    for (var i = 0; i < stops.length; i++) {
      if (stops[i].sequence == stop.sequence) return i;
    }
    return null;
  }

  void _drawSmoothPath(Canvas canvas, List<Offset> points, Paint paint) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];
      final controlY = (current.dy + next.dy) / 2;
      path.cubicTo(
        current.dx,
        controlY,
        next.dx,
        controlY,
        next.dx,
        next.dy,
      );
    }
    canvas.drawPath(path, paint);
  }

  void _drawNode(Canvas canvas, Offset point, int index) {
    final stop = stops[index];
    final isOrigin = origin?.sequence == stop.sequence;
    final isDestination = destination?.sequence == stop.sequence;
    final inSegment = _isInSegment(stop);

    if (isOrigin) {
      canvas.drawCircle(point, 9, Paint()..color = AppColors.brand);
      canvas.drawCircle(
        point,
        9,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
      return;
    }

    if (isDestination) {
      canvas.drawCircle(point, 9, Paint()..color = Colors.white);
      canvas.drawCircle(
        point,
        9,
        Paint()
          ..color = AppColors.accent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5,
      );
      return;
    }

    final radius = inSegment ? 5.0 : 4.0;
    canvas.drawCircle(
      point,
      radius,
      Paint()..color = inSegment ? AppColors.brand : Colors.white,
    );
    canvas.drawCircle(
      point,
      radius,
      Paint()
        ..color = inSegment ? AppColors.brand : AppColors.outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = inSegment ? 0 : 2,
    );
  }

  bool _isInSegment(RouteStop stop) {
    final originIndex = _indexOf(origin);
    final destinationIndex = _indexOf(destination);
    if (originIndex == null || destinationIndex == null) return false;
    final low = math.min(originIndex, destinationIndex);
    final high = math.max(originIndex, destinationIndex);
    final index = stops.indexWhere((candidate) => candidate.sequence == stop.sequence);
    return index >= low && index <= high;
  }

  void _drawLabels(Canvas canvas, List<Offset> points, Size size) {
    final originIndex = _indexOf(origin);
    final destinationIndex = _indexOf(destination);
    final maxLabelWidth = size.width / 2 - 34;

    if (originIndex != null) {
      _drawLabel(
        canvas,
        points[originIndex],
        stops[originIndex],
        'GET ON',
        alignEnd: true,
        maxWidth: maxLabelWidth,
        color: AppColors.brand,
      );
    }

    if (destinationIndex != null) {
      _drawLabel(
        canvas,
        points[destinationIndex],
        stops[destinationIndex],
        'GET OFF',
        alignEnd: false,
        maxWidth: maxLabelWidth,
        color: AppColors.accent,
      );
    }
  }

  void _drawLabel(
    Canvas canvas,
    Offset point,
    RouteStop stop,
    String caption, {
    required bool alignEnd,
    required double maxWidth,
    required Color color,
  }) {
    final namePainter = TextPainter(
      text: TextSpan(
        text: stop.name,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: maxWidth);

    final kmPainter = TextPainter(
      text: TextSpan(
        text: '$caption · ${stop.kmIndex} km',
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: maxWidth);

    final offset = alignEnd
        ? point.dx - 16 - namePainter.width
        : point.dx + 16;

    namePainter.paint(canvas, Offset(offset, point.dy - namePainter.height / 2 - 5));
    kmPainter.paint(canvas, Offset(offset, point.dy + kmPainter.height / 2 + 2));
  }

  @override
  bool shouldRepaint(covariant _RouteDiagramPainter oldDelegate) {
    return oldDelegate.stops != stops ||
        oldDelegate.origin != origin ||
        oldDelegate.destination != destination;
  }
}
