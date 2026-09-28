import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';

class AppEmptyView extends StatelessWidget {
  const AppEmptyView({super.key, required this.title, this.message, this.icon});

  final String title;
  final String? message;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.search_off_rounded,
              size: 56,
              color: AppColors.inkMuted,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                message!,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.inkMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
