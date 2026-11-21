import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/game_manager.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/rounded_mochi_asset.dart';

class GreetingVariant {
  final String imagePath;
  final String badgeEn;
  final String badgeId;
  final String titleEn;
  final String titleId;
  final String japanese;
  final String romaji;

  const GreetingVariant({
    required this.imagePath,
    required this.badgeEn,
    required this.badgeId,
    required this.titleEn,
    required this.titleId,
    required this.japanese,
    required this.romaji,
  });
}

class GreetingOverlayScreen extends StatefulWidget {
  final Widget nextScreen;

  const GreetingOverlayScreen({super.key, required this.nextScreen});

  @override
  State<GreetingOverlayScreen> createState() => _GreetingOverlayScreenState();

  static Route route(Widget nextScreen) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          GreetingOverlayScreen(nextScreen: nextScreen),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: AppSpacing.animSlow,
    );
  }
}

class _GreetingOverlayScreenState extends State<GreetingOverlayScreen> {
  late final GreetingVariant _selectedVariant;

  static const List<GreetingVariant> _variants = [
    GreetingVariant(
      imagePath: 'assets/images/mochi_menyapa.png',
      badgeEn: 'WELCOME BACK',
      badgeId: 'SELAMAT DATANG KEMBALI',
      titleEn: 'Okaeri! Ready to learn?',
      titleId: 'Okaeri! Siap belajar hari ini?',
      japanese: 'おかえり！',
      romaji: 'Okaeri!',
    ),
    GreetingVariant(
      imagePath: 'assets/images/mochi_semangat.png',
      badgeEn: 'DAILY SPIRIT',
      badgeId: 'SEMANGAT HARI INI',
      titleEn: "Ganbatte! Let's hit today's goal!",
      titleId: 'Ganbatte! Ayo capai target hari ini!',
      japanese: '頑張って！',
      romaji: 'Ganbatte!',
    ),
    GreetingVariant(
      imagePath: 'assets/images/mochi_senang.png',
      badgeEn: "LET'S BEGIN",
      badgeId: 'AYO MULAI',
      titleEn: "Yoshi! Let's keep moving forward!",
      titleId: 'Yoshi! Ayo melangkah maju!',
      japanese: 'よし、行くぞ！',
      romaji: 'Yoshi, ikuzo!',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedVariant = _variants[Random().nextInt(_variants.length)];

    Timer(const Duration(milliseconds: 1800), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                widget.nextScreen,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: AppSpacing.animSlow,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return ValueListenableBuilder<bool>(
      valueListenable: globalDarkMode,
      builder: (context, isDark, _) {
        return ValueListenableBuilder<String>(
          valueListenable: globalLanguage,
          builder: (context, lang, _) {
            final bool isId = lang == 'id';
            final Color bgColor =
                isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
            final Color cardColor =
                isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
            final Color textColor =
                isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
            final Color subTextColor = isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight;
            final Color primaryColor =
                isDark ? AppColors.primaryDark : AppColors.primaryLight;
            final Color primaryContainer = isDark
                ? AppColors.primaryContainerDark
                : AppColors.primaryContainerLight;
            final Color borderColor =
                isDark ? AppColors.borderDark : AppColors.borderLight;

            final String badgeText =
                isId ? _selectedVariant.badgeId : _selectedVariant.badgeEn;
            final String titleText =
                isId ? _selectedVariant.titleId : _selectedVariant.titleEn;

            return Scaffold(
              backgroundColor: bgColor,
              body: SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 360),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(
                          begin: reduceMotion ? 1.0 : 0.92,
                          end: 1.0,
                        ),
                        duration: reduceMotion
                            ? Duration.zero
                            : AppSpacing.animSlow,
                        curve: Curves.easeOutBack,
                        builder: (context, scale, child) {
                          return Transform.scale(
                            scale: scale,
                            child: child,
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                            vertical: AppSpacing.xxl,
                          ),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusXxl,
                            ),
                            border: Border.all(
                              color: borderColor,
                              width: 1.5,
                            ),
                            boxShadow: AppShadows.dialog(isDark),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Top motivational category pill
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.xxs,
                                ),
                                decoration: BoxDecoration(
                                  color: primaryContainer,
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusPill,
                                  ),
                                  border: Border.all(
                                    color: primaryColor.withValues(alpha: 0.25),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.auto_awesome_rounded,
                                      size: 14,
                                      color: primaryColor,
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    Text(
                                      badgeText,
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: primaryColor,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xl),

                              // Mochi mascot with WelcomeScreen-matched stroke & shadow
                              RoundedMochiAsset(
                                assetPath: _selectedVariant.imagePath,
                                size: 176,
                              ),
                              const SizedBox(height: AppSpacing.xl),

                              // Primary motivational greeting message
                              Text(
                                titleText,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.headlineMedium.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: textColor,
                                  height: 1.3,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),

                              // Japanese phrase badge with NotoSansJP typography
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.lg,
                                  vertical: AppSpacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.surfaceVariantDark
                                      : AppColors.surfaceVariantLight,
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusPill,
                                  ),
                                  border: Border.all(
                                    color: borderColor,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _selectedVariant.japanese,
                                      style: AppTextStyles.japaneseBody
                                          .copyWith(
                                        color: primaryColor,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    Text(
                                      '• ${_selectedVariant.romaji}',
                                      style: AppTextStyles.labelMedium.copyWith(
                                        color: subTextColor,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
