import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';

/// Reusable animated progress bar for MIRAIku that respects OS reduce-motion settings.
/// Supports Core Drive 2 (Development & Accomplishment) visual feedback.
class AppProgressBar extends StatelessWidget {
  final double progress;
  final double height;
  final Color? color;
  final Color? trackColor;
  final String? semanticLabel;

  const AppProgressBar({
    super.key,
    required this.progress,
    this.height = 8.0,
    this.color,
    this.trackColor,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final clampedProgress = progress.clamp(0.0, 1.0);

    final Color activeColor =
        color ?? (isDark ? AppColors.primaryDark : AppColors.primaryLight);
    final Color bgTrackColor = trackColor ??
        (isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight);

    return Semantics(
      label: semanticLabel ?? 'Progress',
      value: '${(clampedProgress * 100).round()}%',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : MediaQuery.of(context).size.width;
          return Stack(
            children: [
              Container(
                height: height,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: bgTrackColor,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                ),
              ),
              AnimatedContainer(
                duration: reduceMotion ? Duration.zero : AppSpacing.animNormal,
                curve: Curves.easeOutCubic,
                height: height,
                width: maxWidth * clampedProgress,
                decoration: BoxDecoration(
                  color: activeColor,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  boxShadow: AppShadows.accentGlow(activeColor, isDark: isDark),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
