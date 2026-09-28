import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/fare_calculator.dart';
import '../../../../core/utils/money.dart';
import '../../../../data/models/passenger_category.dart';
import '../models/fare_estimate.dart';

class FareEstimateCard extends StatelessWidget {
  const FareEstimateCard({super.key, required this.estimate});

  final FareEstimate estimate;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final rules = estimate.fareRules;

    if (estimate.isIdenticalStops) {
      return _NoticeCard(
        icon: Icons.info_outline_rounded,
        title: 'Same stop selected',
        message: 'Pick two different stops to see a fare estimate.',
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.brandDark,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppShadows.raised,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.md,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.receipt_long_rounded,
                  color: AppColors.accent,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'FARE ESTIMATE',
                  style: textTheme.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                _DistanceChip(distanceKm: estimate.distanceKm),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _PricePane(
                    label: 'REGULAR',
                    caption: 'Standard fare',
                    amount: estimate.regular.total,
                    accent: Colors.white,
                    emphasized: false,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _PricePane(
                    label: 'DISCOUNTED',
                    caption: 'Student · Senior · PWD',
                    amount: estimate.discounted.total,
                    accent: AppColors.accent,
                    emphasized: true,
                    badge: 'SAVE ${estimate.saving.pesos.toStringAsFixed(2)}',
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.md,
            ),
            decoration: const BoxDecoration(
              color: Color(0x14000000),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(AppSpacing.radiusLg),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${rules.baseFare.pesos.toStringAsFixed(2)} base '
                    '(first ${rules.includedKilometers} km)  ·  '
                    '+${rules.perKilometer.pesos.toStringAsFixed(2)}/km  ·  '
                    '−${rules.discountPercent}% discount',
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 11.5,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                const Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                  color: Colors.white38,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PricePane extends StatelessWidget {
  const _PricePane({
    required this.label,
    required this.caption,
    required this.amount,
    required this.accent,
    required this.emphasized,
    this.badge,
  });

  final String label;
  final String caption;
  final Money amount;
  final Color accent;
  final bool emphasized;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: emphasized ? AppColors.accent.withValues(alpha: 0.14) : Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: emphasized
              ? AppColors.accent.withValues(alpha: 0.55)
              : Colors.white.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.9,
                    fontSize: 10.5,
                  ),
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      color: AppColors.brandDark,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '₱',
                  style: textTheme.titleMedium?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 1),
                Text(
                  amount.pesos.toStringAsFixed(2),
                  style: textTheme.displaySmall?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w800,
                    fontSize: 30,
                    height: 1,
                    letterSpacing: -1,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _DistanceChip extends StatelessWidget {
  const _DistanceChip({required this.distanceKm});

  final int distanceKm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Text(
        '$distanceKm km',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.accentSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accent, size: 24),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: textTheme.bodySmall?.copyWith(color: AppColors.ink),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension PassengerCategoryLabels on PassengerCategory {
  String get displayLabel => switch (this) {
    PassengerCategory.regular => 'Regular',
    PassengerCategory.student => 'Student',
    PassengerCategory.senior => 'Senior',
    PassengerCategory.pwd => 'PWD',
  };
}

String describeFareRules(FareRules rules) {
  return '${rules.baseFare.pesos.toStringAsFixed(2)} base fare for the first '
      '${rules.includedKilometers} km, then '
      '${rules.perKilometer.pesos.toStringAsFixed(2)} per km.';
}
