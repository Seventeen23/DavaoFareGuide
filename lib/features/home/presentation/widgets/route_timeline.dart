import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../data/models/route_stop.dart';

/// Vertical stop-by-stop timeline used on the route detail screen.
class RouteTimeline extends StatelessWidget {
  const RouteTimeline({
    super.key,
    required this.stops,
    this.highlightFrom,
    this.highlightTo,
  });

  final List<RouteStop> stops;
  final RouteStop? highlightFrom;
  final RouteStop? highlightTo;

  bool _isBetween(int kmIndex) {
    if (highlightFrom == null || highlightTo == null) return false;
    final low = highlightFrom!.kmIndex <= highlightTo!.kmIndex
        ? highlightFrom!.kmIndex
        : highlightTo!.kmIndex;
    final high = highlightFrom!.kmIndex <= highlightTo!.kmIndex
        ? highlightTo!.kmIndex
        : highlightFrom!.kmIndex;
    return kmIndex >= low && kmIndex <= high;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        for (var index = 0; index < stops.length; index++)
          _TimelineRow(
            stop: stops[index],
            isFirst: index == 0,
            isLast: index == stops.length - 1,
            isOrigin: highlightFrom?.sequence == stops[index].sequence,
            isDestination: highlightTo?.sequence == stops[index].sequence,
            isOnTrip: _isBetween(stops[index].kmIndex),
            textTheme: textTheme,
          ),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.stop,
    required this.isFirst,
    required this.isLast,
    required this.isOrigin,
    required this.isDestination,
    required this.isOnTrip,
    required this.textTheme,
  });

  final RouteStop stop;
  final bool isFirst;
  final bool isLast;
  final bool isOrigin;
  final bool isDestination;
  final bool isOnTrip;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final endpoint = isOrigin || isDestination;
    final dotColor = endpoint
        ? AppColors.accent
        : isOnTrip
        ? AppColors.brand
        : AppColors.outlineStrong;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                const SizedBox(height: 4),
                Container(
                  width: endpoint ? 14 : 10,
                  height: endpoint ? 14 : 10,
                  decoration: BoxDecoration(
                    color: endpoint ? AppColors.accent : dotColor,
                    shape: BoxShape.circle,
                    border: endpoint
                        ? Border.all(color: AppColors.accentSurface, width: 3)
                        : null,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      color: isOnTrip ? AppColors.brandLight : AppColors.outline,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: isLast ? 0 : AppSpacing.lg,
                top: 1,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      stop.name,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: endpoint ? FontWeight.w700 : FontWeight.w500,
                        color: endpoint ? AppColors.ink : AppColors.inkMuted,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '${stop.kmIndex} km',
                    style: textTheme.bodySmall?.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                      color: endpoint ? AppColors.brand : AppColors.inkMuted,
                      fontWeight: endpoint ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
