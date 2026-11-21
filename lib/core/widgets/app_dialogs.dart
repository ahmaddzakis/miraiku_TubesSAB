import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../game_manager.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_button.dart';

class AppDialogs {
  static String _t(String en, String id) {
    return globalLanguage.value == 'id' ? id : en;
  }

  static void showAboutApp(BuildContext context) async {
    final info = await PackageInfo.fromPlatform();
    final String version = 'v${info.version}';

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return ValueListenableBuilder<bool>(
          valueListenable: globalDarkMode,
          builder: (context, isDark, _) {
            return ValueListenableBuilder<String>(
              valueListenable: globalLanguage,
              builder: (context, lang, _) {
                final Color bgColor =
                    isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
                final Color textColor = isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight;
                final Color subTextColor = isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight;
                final Color primaryColor =
                    isDark ? AppColors.primaryDark : AppColors.primaryLight;

                return Dialog(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  insetPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.xl,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
                      boxShadow: AppShadows.dialog(isDark),
                    ),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: AppSpacing.xxl,
                          top: AppSpacing.xxl,
                          right: AppSpacing.xxl,
                          bottom: MediaQuery.of(context).padding.bottom +
                              AppSpacing.xxl,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Header Row
                            Row(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.surfaceVariantDark
                                        : AppColors.surfaceVariantLight,
                                    borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusXl,
                                    ),
                                    boxShadow: AppShadows.card(isDark),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusXl,
                                    ),
                                    child: Image.asset(
                                      'assets/images/iconUtama.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.lg),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "MIRAIku",
                                        style: AppTextStyles.headlineMedium
                                            .copyWith(
                                              color: textColor,
                                              letterSpacing: -0.5,
                                            ),
                                      ),
                                      Text(
                                        version,
                                        style:
                                            AppTextStyles.titleMedium.copyWith(
                                              color: subTextColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            // Description
                            Text(
                              _t(
                                "MIRAIku is an interactive Japanese language learning platform designed to help users efficiently master Hiragana, Katakana, and essential vocabulary. Built with engaging gamification elements, MIRAIku makes the journey to Japanese fluency enjoyable, structured, and effective.",
                                "MIRAIku adalah platform pembelajaran bahasa Jepang interaktif yang dirancang untuk membantu pengguna menguasai Hiragana, Katakana, dan kosakata penting secara efisien. Dibangun dengan elemen gamifikasi yang menarik, MIRAIku membuat perjalanan menuju kemahiran bahasa Jepang menjadi menyenangkan, terstruktur, dan efektif.",
                              ),
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontSize: 15,
                                color: subTextColor,
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xxl),
                            // Developed By Badge
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                                vertical: AppSpacing.lg,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    primaryColor.withValues(alpha: 0.12),
                                    primaryColor.withValues(alpha: 0.05),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusLg,
                                ),
                                border: Border.all(
                                  color: primaryColor.withValues(alpha: 0.15),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: primaryColor.withValues(
                                        alpha: 0.1,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.auto_awesome_rounded,
                                      size: 20,
                                      color: primaryColor,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _t(
                                            "Developed by",
                                            "Dikembangkan oleh",
                                          ),
                                          style: AppTextStyles.labelSmall
                                              .copyWith(
                                                color: primaryColor.withValues(
                                                  alpha: 0.8,
                                                ),
                                              ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          "Michibon Lab",
                                          style: AppTextStyles.titleMedium
                                              .copyWith(color: primaryColor),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xxl),
                            // Actions
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                AppButton(
                                  label: _t("VIEW LICENSES", "LIHAT LISENSI"),
                                  variant: AppButtonVariant.text,
                                  expand: false,
                                  height: 48,
                                  onPressed: () {
                                    showLicensePage(
                                      context: context,
                                      applicationName: "MIRAIku",
                                      applicationVersion: version,
                                      applicationIcon: Padding(
                                        padding: const EdgeInsets.all(
                                          AppSpacing.md,
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            AppSpacing.radiusMd,
                                          ),
                                          child: Image.asset(
                                            'assets/images/iconUtama.png',
                                            width: 64,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                AppButton(
                                  label: _t("CLOSE", "TUTUP"),
                                  expand: false,
                                  height: 48,
                                  borderRadius: AppSpacing.radiusMd,
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
