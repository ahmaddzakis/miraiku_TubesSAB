import 'package:flutter/material.dart';
import '../core/game_manager.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_shadows.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  String _t(String en, String id) {
    return globalLanguage.value == 'id' ? id : en;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;
    final bool reduceMotion = MediaQuery.disableAnimationsOf(context);

    final Color navBgColor = colorScheme.surface;
    final Color borderColor = colorScheme.outline;
    final Color inactiveColor = colorScheme.onSurfaceVariant;
    final double bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return ValueListenableBuilder<String>(
      valueListenable: globalLanguage,
      builder: (context, _, _) {
        return Container(
          padding: EdgeInsets.only(
            top: AppSpacing.xs,
            bottom: AppSpacing.md + bottomInset,
            left: AppSpacing.xs,
            right: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: navBgColor,
            border: Border(
              top: BorderSide(color: borderColor, width: 1),
            ),
            boxShadow: AppShadows.navBar(isDark),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context: context,
                index: 0,
                label: _t("LEARN", "BELAJAR"),
                inactiveColor: inactiveColor,
                isDark: isDark,
                reduceMotion: reduceMotion,
                iconData: Icons.menu_book_rounded,
              ),
              _buildNavItem(
                context: context,
                index: 1,
                label: _t("SIMULATION", "SIMULASI"),
                inactiveColor: inactiveColor,
                isDark: isDark,
                reduceMotion: reduceMotion,
                iconData: Icons.edit_note_rounded,
              ),
              _buildNavItem(
                context: context,
                index: 2,
                label: _t("ALPHABET", "ALFABET"),
                inactiveColor: inactiveColor,
                isDark: isDark,
                reduceMotion: reduceMotion,
                textIcon: "あ",
              ),
              _buildNavItem(
                context: context,
                index: 3,
                label: _t("PROFILE", "PROFIL"),
                inactiveColor: inactiveColor,
                isDark: isDark,
                reduceMotion: reduceMotion,
                iconData: Icons.account_circle_outlined,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required String label,
    required Color inactiveColor,
    required bool isDark,
    required bool reduceMotion,
    IconData? iconData,
    String? textIcon,
  }) {
    final bool isActive = selectedIndex == index;
    final Color activePillBg = isDark
        ? AppColors.bannerPrimaryDark
        : AppColors.primaryLight;
    final Color itemColor = isActive ? Colors.white : inactiveColor;
    final double iconSize = isActive ? 24.0 : 26.0;

    Widget iconWidget;
    if (textIcon != null) {
      iconWidget = Text(
        textIcon,
        style: AppTextStyles.japaneseTitle.copyWith(
          color: itemColor,
          fontSize: iconSize,
          height: 1.0,
        ),
      );
    } else {
      iconWidget = Icon(iconData, color: itemColor, size: iconSize);
    }

    return Semantics(
      button: true,
      selected: isActive,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(index),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          splashColor: activePillBg.withValues(alpha: 0.2),
          highlightColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 68,
              minHeight: AppSpacing.minTapTarget,
            ),
            child: AnimatedContainer(
              duration: reduceMotion
                  ? Duration.zero
                  : const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: isActive ? activePillBg : Colors.transparent,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  iconWidget,
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    label,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: itemColor,
                      fontSize: 10,
                      fontWeight: isActive ? FontWeight.w900 : FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
