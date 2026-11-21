import 'package:flutter/material.dart';
import '../../core/game_manager.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../main.dart';

class LoginSuccessScreen extends StatefulWidget {
  const LoginSuccessScreen({super.key});

  @override
  State<LoginSuccessScreen> createState() => _LoginSuccessScreenState();
}

class _LoginSuccessScreenState extends State<LoginSuccessScreen> {
  @override
  void initState() {
    super.initState();
    _startNavigationTimer();
  }

  void _startNavigationTimer() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MainNavigationScreen(),
          ),
        );
      }
    });
  }

  String _t(String en, String id) {
    return globalLanguage.value == 'id' ? id : en;
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return ValueListenableBuilder<bool>(
      valueListenable: globalDarkMode,
      builder: (context, isDark, _) {
        final Color bgColor =
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
        final Color textColor =
            isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
        final Color subTextColor =
            isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
        final Color primaryColor =
            isDark ? AppColors.primaryDark : AppColors.primaryLight;

        return Scaffold(
          backgroundColor: bgColor,
          body: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: reduceMotion ? 1.0 : 0.0, end: 1.0),
              duration: reduceMotion ? Duration.zero : AppSpacing.animSlow,
              builder: (context, opacity, child) {
                return Opacity(
                  opacity: opacity,
                  child: child,
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 170,
                    height: 170,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceDark
                          : AppColors.surfaceLight,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: primaryColor.withValues(
                          alpha: isDark ? 0.5 : 0.8,
                        ),
                        width: 4,
                      ),
                      boxShadow: AppShadows.dialog(isDark),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/iconUtama.png',
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Text(
                    _t("Welcome to MIRAIku", "Selamat Datang di MIRAIku"),
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: textColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _t(
                      "Preparing your journey...",
                      "Menyiapkan perjalananmu...",
                    ),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: subTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
