import 'package:flutter/material.dart';
import '../core/game_manager.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_shadows.dart';

class RoundedMochiAsset extends StatelessWidget {
  final String assetPath;
  final double size;
  final bool showBorderAndShadow;

  const RoundedMochiAsset({
    super.key,
    required this.assetPath,
    this.size = 180,
    this.showBorderAndShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: globalDarkMode,
      builder: (context, isDark, _) {
        final Color primaryColor =
            isDark ? AppColors.primaryDark : AppColors.primaryLight;
        final Color surfaceColor =
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

        if (!showBorderAndShadow) {
          return SizedBox.square(
            dimension: size,
            child: ClipOval(
              child: _buildImage(primaryColor),
            ),
          );
        }

        return Container(
          width: size,
          height: size,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: surfaceColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: primaryColor.withValues(alpha: isDark ? 0.5 : 0.8),
              width: 4,
            ),
            boxShadow: AppShadows.dialog(isDark),
          ),
          child: ClipOval(
            child: _buildImage(primaryColor),
          ),
        );
      },
    );
  }

  Widget _buildImage(Color fallbackColor) {
    return Image.asset(
      assetPath,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Icon(
        Icons.emoji_emotions_outlined,
        size: size * 0.5,
        color: fallbackColor,
      ),
    );
  }
}
