import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.onTap,
    this.borderRadius,
    this.shadows,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? shadows;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppSpacing.radiusLg);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: radius,
        boxShadow: shadows ?? AppShadows.card,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
