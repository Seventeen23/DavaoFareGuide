import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../data/models/jeepney_route.dart';

class RouteTile extends StatelessWidget {
  const RouteTile({super.key, required this.route, required this.onTap});

  final JeepneyRoute route;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.brandLight, AppColors.brand],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: const Icon(
              Icons.directions_bus_filled_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  route.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium,
                ),
                const SizedBox(height: 3),
                Text(
                  '${route.stopCount} stops   ·   ${route.totalKm} km',
                  style: textTheme.bodySmall?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 15,
            color: AppColors.outlineStrong,
          ),
        ],
      ),
    );
  }
}
