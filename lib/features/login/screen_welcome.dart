import 'package:flutter/material.dart';
import 'package:miraiku/core/game_manager.dart';
import 'package:miraiku/core/notification_service.dart';
import 'package:miraiku/core/settings_controller.dart';
import 'package:miraiku/core/theme/app_colors.dart';
import 'package:miraiku/core/theme/app_shadows.dart';
import 'package:miraiku/core/theme/app_spacing.dart';
import 'package:miraiku/core/theme/app_text_styles.dart';
import 'package:miraiku/core/widgets/app_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screen_auth.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _t(String en, String id) {
    return globalLanguage.value == 'id' ? id : en;
  }

  final List<Map<String, String>> _onboardingData = [
    {
      "title_en": "Learn Japanese",
      "title_id": "Belajar Bahasa Jepang",
      "subtitle_en":
          "Master Hiragana, Katakana, and Kanji with interactive and fun learning modules.",
      "subtitle_id":
          "Kuasai Hiragana, Katakana, dan Kanji dengan modul pembelajaran yang interaktif dan menyenangkan.",
      "image": "assets/images/belajar.png",
    },
    {
      "title_en": "Interactive Simulation",
      "title_id": "Simulasi Interaktif",
      "subtitle_en":
          "Test your skills with JLPT N5 exam simulations designed according to official standards.",
      "subtitle_id":
          "Uji kemampuan Anda dengan simulasi ujian JLPT N5 yang dirancang sesuai standar resmi.",
      "image": "assets/images/simulasi.png",
    },
    {
      "title_en": "Track Your Progress",
      "title_id": "Pantau Progresmu",
      "subtitle_en":
          "See your achievements and learning history in real-time to keep motivating yourself.",
      "subtitle_id":
          "Lihat pencapaian dan riwayat belajar Anda secara real-time untuk terus memotivasi diri.",
      "image": "assets/images/progres.png",
    },
  ];

  Future<void> _completeOnboarding() async {
    if (mounted) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const AuthScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: globalDarkMode,
      builder: (context, isDark, _) {
        return ValueListenableBuilder<String>(
          valueListenable: globalLanguage,
          builder: (context, lang, _) {
            final Color bgColor =
                isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
            final Color textColor =
                isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
            final Color primaryColor =
                isDark ? AppColors.primaryDark : AppColors.primaryLight;

            return Scaffold(
              backgroundColor: bgColor,
              body: SafeArea(
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Expanded(
                          flex: 3,
                          child: PageView.builder(
                            controller: _pageController,
                            onPageChanged: (value) =>
                                setState(() => _currentPage = value),
                            itemCount: _onboardingData.length,
                            itemBuilder: (context, index) => _buildPageContent(
                              title: _t(
                                _onboardingData[index]["title_en"]!,
                                _onboardingData[index]["title_id"]!,
                              ),
                              subtitle: _t(
                                _onboardingData[index]["subtitle_en"]!,
                                _onboardingData[index]["subtitle_id"]!,
                              ),
                              image: _onboardingData[index]["image"]!,
                              textColor: textColor,
                              isDark: isDark,
                              primaryColor: primaryColor,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xl,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    _onboardingData.length,
                                    (index) => _buildDotIndicator(
                                      index,
                                      isDark,
                                      primaryColor,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                _currentPage == _onboardingData.length - 1
                                    ? _buildGetStartedButton()
                                    : _buildNavigationButtons(),
                                const SizedBox(height: AppSpacing.xxxl),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Theme and Language Toggle
                    Positioned(
                      top: AppSpacing.lg,
                      right: AppSpacing.lg,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.black.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusPill,
                          ),
                          border: Border.all(
                            color: isDark
                                ? AppColors.outlineDark
                                : AppColors.outlineLight,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                await SettingsController.instance
                                    .toggleLanguage();
                                final prefs =
                                    await SharedPreferences.getInstance();
                                if (prefs.getBool('is_daily_reminder_on') ??
                                    false) {
                                  NotificationService()
                                      .scheduleDailyStudyReminder(
                                        globalLanguage.value,
                                      );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: AppSpacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusLg,
                                  ),
                                ),
                                child: Text(
                                  lang.toUpperCase(),
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: primaryColor,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Container(
                              width: 1,
                              height: 16,
                              color: isDark
                                  ? AppColors.outlineDark
                                  : AppColors.outlineLight,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            GestureDetector(
                              onTap: () async {
                                await SettingsController.instance.toggleTheme();
                              },
                              child: Icon(
                                isDark
                                    ? Icons.light_mode_rounded
                                    : Icons.dark_mode_rounded,
                                color: isDark
                                    ? AppColors.accentDark
                                    : AppColors.secondaryLight,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPageContent({
    required String title,
    required String subtitle,
    required String image,
    required Color textColor,
    required bool isDark,
    required Color primaryColor,
  }) {
    final subColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              shape: BoxShape.circle,
              border: Border.all(
                color: primaryColor.withValues(alpha: isDark ? 0.5 : 0.8),
                width: 4,
              ),
              boxShadow: AppShadows.dialog(isDark),
            ),
            child: ClipOval(
              child: Image.asset(
                image,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.image_not_supported_rounded,
                  size: 100,
                  color: subColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.headlineLarge.copyWith(color: textColor),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              color: subColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDotIndicator(int index, bool isDark, Color primaryColor) {
    final inactiveColor = isDark
        ? AppColors.outlineDark
        : AppColors.outlineLight;
    return AnimatedContainer(
      duration: AppSpacing.animNormal,
      margin: const EdgeInsets.only(right: AppSpacing.sm),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? primaryColor : inactiveColor,
        borderRadius: BorderRadius.circular(AppSpacing.xs),
      ),
    );
  }

  Widget _buildGetStartedButton() {
    return AppButton(
      label: _t("GET STARTED", "MULAI SEKARANG"),
      height: 58,
      onPressed: _completeOnboarding,
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppButton(
          label: _t("SKIP", "LEWATI"),
          variant: AppButtonVariant.text,
          expand: false,
          height: 50,
          onPressed: _completeOnboarding,
        ),
        AppButton(
          label: _t("NEXT", "LANJUT"),
          trailingIcon: Icons.arrow_forward_rounded,
          expand: false,
          height: 50,
          borderRadius: AppSpacing.radiusMd,
          onPressed: () {
            _pageController.nextPage(
              duration: AppSpacing.animNormal,
              curve: Curves.easeInOut,
            );
          },
        ),
      ],
    );
  }
}
