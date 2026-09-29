import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../data/models/geo.dart';

/// A place in the map data, shown in the home search and the landmark browser.
class LandmarkTile extends StatelessWidget {
  const LandmarkTile({
    super.key,
    required this.landmark,
    required this.onTap,
    this.routeLabel,
  });

  final MapLandmark landmark;
  final VoidCallback onTap;

  /// Overrides the trailing route count, e.g. "via Matina" when a parent
  /// already knows which route the user is looking at.
  final String? routeLabel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final routeCount = landmark.routeCodes.length;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.brandSurface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(
              landmarkCategoryIcon(landmark.category),
              color: AppColors.brand,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  landmark.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  routeLabel ?? _subtitle(routeCount),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Icon(
            landmark.isLinked
                ? Icons.arrow_forward_ios_rounded
                : Icons.help_outline_rounded,
            size: 14,
            color: landmark.isLinked
                ? AppColors.outlineStrong
                : AppColors.inkMuted,
          ),
        ],
      ),
    );
  }

  /// Unlinked landmarks say so rather than showing "0 routes", which reads like
  /// a bug: they are places the app knows about but cannot yet route to.
  String _subtitle(int routeCount) {
    final category = landmarkCategoryLabel(landmark.category);
    if (routeCount == 0) return '$category  ·  no route serves this yet';
    final routes = routeCount == 1 ? '1 route' : '$routeCount routes';
    return '$category  ·  $routes';
  }
}

const Map<String, IconData> _landmarkIcons = {
  'attraction': Icons.local_activity_rounded,
  'church': Icons.church_rounded,
  'civic': Icons.account_balance_rounded,
  'hospital': Icons.local_hospital_rounded,
  'hotel': Icons.hotel_rounded,
  'mall': Icons.shopping_bag_rounded,
  'market': Icons.storefront_rounded,
  'office': Icons.business_rounded,
  'school': Icons.school_rounded,
  'terminal': Icons.directions_bus_filled_rounded,
  'university': Icons.school_outlined,
  'waterfront': Icons.water_rounded,
};

const Map<String, String> _landmarkLabels = {
  'attraction': 'Attraction',
  'church': 'Church',
  'civic': 'Civic',
  'hospital': 'Hospital',
  'hotel': 'Hotel',
  'mall': 'Mall',
  'market': 'Market',
  'office': 'Office',
  'school': 'School',
  'terminal': 'Terminal',
  'university': 'University',
  'waterfront': 'Waterfront',
};

IconData landmarkCategoryIcon(String category) =>
    _landmarkIcons[category] ?? Icons.place_rounded;

String landmarkCategoryLabel(String category) =>
    _landmarkLabels[category] ??
    '${category[0].toUpperCase()}${category.substring(1)}';
