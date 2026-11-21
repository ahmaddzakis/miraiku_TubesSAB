import 'package:flutter/material.dart';
import '../../core/game_manager.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

class UnitHeaderCard extends StatelessWidget {
  final int unitNumber;
  final String titleEn;
  final String titleId;
  final String subtitleEn;
  final String subtitleId;
  final bool isUnlocked;

  const UnitHeaderCard({
    super.key,
    this.unitNumber = 1,
    this.titleEn = 'GREETINGS & BASICS',
    this.titleId = 'SALAM & DASAR',
    this.subtitleEn = 'Learn basic phrases and greet people in Japanese',
    this.subtitleId =
        'Pelajari ungkapan dasar dan menyapa orang dalam bahasa Jepang',
    this.isUnlocked = true,
  });

  String _t(String en, String id) {
    return globalLanguage.value == 'id' ? id : en;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;

    // Ensure high contrast (white text over deep warm terracotta) in both light & dark modes
    final Color cardBg = isUnlocked
        ? (isDark ? AppColors.bannerPrimaryDark : AppColors.primaryLight)
        : colorScheme.surfaceContainerHighest;

    final Color bottomLipColor = isUnlocked
        ? (isDark ? const Color(0xFF963D16) : const Color(0xFF8C3511))
        : colorScheme.outline;

    final Color titleColor = isUnlocked
        ? AppColors.onBannerPrimary
        : colorScheme.onSurfaceVariant;

    final Color labelColor = isUnlocked
        ? AppColors.onBannerPrimary.withValues(alpha: 0.85)
        : colorScheme.onSurfaceVariant.withValues(alpha: 0.7);

    final Color descColor = isUnlocked
        ? AppColors.onBannerPrimary.withValues(alpha: 0.92)
        : colorScheme.onSurfaceVariant.withValues(alpha: 0.8);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border(
          bottom: BorderSide(color: bottomLipColor, width: 5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'UNIT $unitNumber',
                style: AppTextStyles.labelLarge.copyWith(
                  color: labelColor,
                  fontSize: 13,
                  letterSpacing: 1.5,
                ),
              ),
              if (!isUnlocked) ...[
                const SizedBox(width: AppSpacing.xs),
                Icon(Icons.lock_rounded, size: 15, color: labelColor),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _t(titleEn, titleId),
            style: AppTextStyles.headlineMedium.copyWith(
              color: titleColor,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _t(subtitleEn, subtitleId),
            style: AppTextStyles.bodyMedium.copyWith(
              color: descColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
