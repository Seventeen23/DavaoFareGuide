import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../data/models/route_stop.dart';

class LocationSelector extends StatelessWidget {
  const LocationSelector({
    super.key,
    required this.origin,
    required this.destination,
    required this.onPickOrigin,
    required this.onPickDestination,
    required this.onSwap,
  });

  final RouteStop? origin;
  final RouteStop? destination;
  final VoidCallback onPickOrigin;
  final VoidCallback onPickDestination;
  final VoidCallback onSwap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      shadows: AppShadows.raised,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.lg, left: 4),
            child: Column(
              children: [
                _EndpointDot(color: AppColors.brand),
                _ConnectorLine(swapEnabled: origin != null && destination != null),
                _EndpointDot(color: AppColors.accent, filled: true),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              children: [
                _LocationField(
                  label: 'GETTING ON',
                  value: origin?.name,
                  placeholder: 'Choose your boarding stop',
                  onTap: onPickOrigin,
                ),
                Divider(color: AppColors.outline, height: AppSpacing.xl),
                _LocationField(
                  label: 'GETTING OFF',
                  value: destination?.name,
                  placeholder: 'Choose your drop-off stop',
                  onTap: onPickDestination,
                ),
              ],
            ),
          ),
          if (origin != null && destination != null)
            _SwapButton(onTap: onSwap)
          else
            const SizedBox(width: 4),
        ],
      ),
    );
  }
}

class _LocationField extends StatelessWidget {
  const _LocationField({
    required this.label,
    required this.value,
    required this.placeholder,
    required this.onTap,
  });

  final String label;
  final String? value;
  final String placeholder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final filled = value != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: textTheme.labelSmall?.copyWith(
                color: filled ? AppColors.brand : AppColors.inkMuted,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.9,
                fontSize: 10.5,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value ?? placeholder,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: filled
                  ? textTheme.titleSmall
                  : textTheme.bodyLarge?.copyWith(color: AppColors.inkMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _EndpointDot extends StatelessWidget {
  const _EndpointDot({required this.color, this.filled = false});

  final Color color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: filled ? Colors.transparent : color,
        shape: BoxShape.circle,
        border: filled ? Border.all(color: color, width: 3) : null,
      ),
    );
  }
}

class _ConnectorLine extends StatelessWidget {
  const _ConnectorLine({required this.swapEnabled});

  final bool swapEnabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 2,
      height: 26,
      color: swapEnabled ? AppColors.brandLight : AppColors.outline,
    );
  }
}

class _SwapButton extends StatelessWidget {
  const _SwapButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Material(
        color: AppColors.brandSurface,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: const Padding(
            padding: EdgeInsets.all(9),
            child: Icon(
              Icons.swap_vert_rounded,
              size: 20,
              color: AppColors.brand,
            ),
          ),
        ),
      ),
    );
  }
}
