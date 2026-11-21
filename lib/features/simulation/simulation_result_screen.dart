import 'package:flutter/material.dart';
import '../../core/game_manager.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_progress_bar.dart';
import '../../data/simulation_data.dart';
import 'simulation_review_screen.dart';

class SimulationResultScreen extends StatefulWidget {
  final int languageScore;
  final int languageTotal;
  final int readingScore;
  final int readingTotal;
  final int timeSpentSeconds;
  final double totalPoints;
  final bool isPassed;
  final List<int?> userAnswers;
  final List<SimulationQuestion>? questions;

  const SimulationResultScreen({
    super.key,
    required this.languageScore,
    required this.languageTotal,
    required this.readingScore,
    required this.readingTotal,
    required this.timeSpentSeconds,
    required this.totalPoints,
    required this.isPassed,
    required this.userAnswers,
    this.questions,
  });

  @override
  State<SimulationResultScreen> createState() => _SimulationResultScreenState();
}

class _SimulationResultScreenState extends State<SimulationResultScreen> {
  String _formatDuration(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes}m ${remainingSeconds}s';
  }

  String _getMotivation(bool passed) {
    if (passed) {
      return _t(
        "Outstanding! You've proved your proficiency in JLPT N5. This is a huge milestone in your Japanese journey. The road ahead looks bright!",
        "Luar biasa! Kamu telah membuktikan kemampuanmu di level JLPT N5. Ini adalah pencapaian besar dalam perjalanan bahasa Jepangmu. Masa depan menantimu!",
      );
    } else {
      return _t(
        "Every master was once a beginner who didn't give up. Use this result as a map for your next study session. You're closer than you think!",
        "Setiap master dulunya adalah pemula yang tidak menyerah. Jadikan hasil ini sebagai peta untuk sesi belajarmu berikutnya. Kamu sudah lebih dekat dari yang kamu bayangkan!",
      );
    }
  }

  String _t(String en, String id) {
    return globalLanguage.value == 'id' ? id : en;
  }

  String _getGrade(double score) {
    final double percent = (score / 180) * 100;
    if (percent >= 90) return "S";
    if (percent >= 80) return "A";
    if (percent >= 70) return "B";
    if (percent >= 44.5) return "C"; // JLPT N5 Pass mark is roughly 80/180
    return "D";
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: globalDarkMode,
      builder: (context, isDark, _) {
        final Color bgColor =
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
        final Color cardColor =
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
        final Color accentColor =
            isDark ? AppColors.primaryDark : AppColors.primaryLight;
        final Color statusColor = widget.isPassed
            ? (isDark ? AppColors.successDark : AppColors.successLight)
            : (isDark ? AppColors.errorDark : AppColors.errorLight);

        final double langPoints = (widget.languageScore /
                (widget.languageTotal == 0 ? 1 : widget.languageTotal)) *
            60;
        final double readingPoints = (widget.readingScore /
                (widget.readingTotal == 0 ? 1 : widget.readingTotal)) *
            120;
        final String grade = _getGrade(widget.totalPoints);
        final int totalQuestions = widget.languageTotal + widget.readingTotal;
        final int totalCorrect = widget.languageScore + widget.readingScore;
        final int accuracy = totalQuestions > 0
            ? ((totalCorrect / totalQuestions) * 100).round()
            : 0;

        return Scaffold(
          backgroundColor: bgColor,
          body: Stack(
            children: [
              Positioned(
                top: -50,
                right: -50,
                child: Opacity(
                  opacity: 0.08,
                  child: Icon(Icons.star_rounded, size: 250, color: statusColor),
                ),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.xl,
                    ),
                    child: Column(
                      children: [
                        // Grade Badge & Status
                        Center(
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 160,
                                    height: 160,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: statusColor.withValues(alpha: 0.2),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 130,
                                    height: 130,
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.12),
                                      shape: BoxShape.circle,
                                      boxShadow: AppShadows.accentGlow(
                                        statusColor,
                                        isDark: isDark,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        grade,
                                        style: AppTextStyles.displayLarge
                                            .copyWith(
                                          fontSize: 72,
                                          color: statusColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.md,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusColor,
                                        borderRadius: BorderRadius.circular(
                                          AppSpacing.radiusPill,
                                        ),
                                        boxShadow: AppShadows.accentGlow(
                                          statusColor,
                                          isDark: isDark,
                                        ),
                                      ),
                                      child: Text(
                                        widget.isPassed ? "PASSED" : "FAILED",
                                        style: AppTextStyles.labelLarge.copyWith(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.xxl),
                              Text(
                                widget.isPassed
                                    ? "Omedetou Gozaimasu!"
                                    : "Ganbatte Kudasai!",
                                style: AppTextStyles.headlineLarge.copyWith(
                                  color: textColor(isDark),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.lg,
                                ),
                                child: Text(
                                  _getMotivation(widget.isPassed),
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: subTextColor(isDark),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xxxl),

                        // Score Card
                        AppCard(
                          padding: EdgeInsets.zero,
                          borderRadius: AppSpacing.radiusXxl,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(AppSpacing.xxl),
                                child: Column(
                                  children: [
                                    Text(
                                      _t(
                                        "OVERALL PERFORMANCE",
                                        "PERFORMA KESELURUHAN",
                                      ),
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: subTextColor(isDark),
                                        letterSpacing: 2,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.lg),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        Text(
                                          "${widget.totalPoints.toInt()}",
                                          style: AppTextStyles.displayLarge
                                              .copyWith(
                                            fontSize: 84,
                                            color: accentColor,
                                            height: 1,
                                          ),
                                        ),
                                        Text(
                                          "/180",
                                          style: AppTextStyles.headlineMedium
                                              .copyWith(
                                            color: subTextColor(isDark)
                                                .withValues(alpha: 0.4),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.xxl,
                                ),
                                child: AppProgressBar(
                                  progress: widget.totalPoints / 180,
                                  height: 12,
                                  color: statusColor,
                                ),
                              ),

                              const SizedBox(height: AppSpacing.xxxl),

                              // Sectional Breakdown
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.xl,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.surfaceVariantDark
                                          .withValues(alpha: 0.5)
                                      : AppColors.surfaceVariantLight
                                          .withValues(alpha: 0.5),
                                  borderRadius: const BorderRadius.vertical(
                                    bottom: Radius.circular(
                                      AppSpacing.radiusXxl,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildDetailedScore(
                                      _t("Language", "Bahasa"),
                                      _t(
                                        "(Vocabulary & Grammar)",
                                        "(Kosakata & Tata Bahasa)",
                                      ),
                                      "${langPoints.toInt()}",
                                      "/60",
                                      Icons.translate_rounded,
                                      accentColor,
                                      isDark,
                                      _t(
                                        "JLPT standard: Language max score is 60 points.",
                                        "Standar JLPT: Skor maksimal Bahasa adalah 60 poin.",
                                      ),
                                    ),
                                    Container(
                                      width: 1,
                                      height: 40,
                                      color: isDark
                                          ? AppColors.borderDark
                                          : AppColors.borderLight,
                                    ),
                                    _buildDetailedScore(
                                      _t("Reading", "Membaca"),
                                      _t(
                                        "(Reading & Comprehension)",
                                        "(Membaca & Pemahaman)",
                                      ),
                                      "${readingPoints.toInt()}",
                                      "/120",
                                      Icons.menu_book_rounded,
                                      accentColor,
                                      isDark,
                                      _t(
                                        "JLPT standard: Reading max score is 120 points.",
                                        "Standar JLPT: Skor maksimal Membaca adalah 120 poin.",
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        // Stats Grid
                        Row(
                          children: [
                            Expanded(
                              child: _buildSmallStatCard(
                                _t("Time", "Waktu"),
                                _formatDuration(widget.timeSpentSeconds),
                                Icons.timer_rounded,
                                isDark,
                                cardColor,
                                accentColor,
                                subtitle: _t("Total duration", "Durasi total"),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: _buildSmallStatCard(
                                _t("Accuracy", "Akurasi"),
                                "$accuracy%",
                                Icons.ads_click_rounded,
                                isDark,
                                cardColor,
                                accentColor,
                                subtitle: _t(
                                  "Correct answer rate",
                                  "Tingkat jawaban benar",
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.huge),

                        // Action Buttons
                        Column(
                          children: [
                            AppButton(
                              label: _t("REVIEW EXAM", "TINJAU UJIAN"),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SimulationReviewScreen(
                                      userAnswers: widget.userAnswers,
                                      questions: widget.questions,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            AppButton(
                              label: _t("BACK", "KEMBALI"),
                              variant: AppButtonVariant.ghost,
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xxxl),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color textColor(bool isDark) =>
      isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
  Color subTextColor(bool isDark) =>
      isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

  Widget _buildDetailedScore(
    String label,
    String subtitle,
    String value,
    String total,
    IconData icon,
    Color color,
    bool isDark,
    String tooltipMsg,
  ) {
    return Column(
      children: [
        Tooltip(
          message: tooltipMsg,
          triggerMode: TooltipTriggerMode.tap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: subTextColor(isDark),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.info_outline_rounded,
                color: subTextColor(isDark).withValues(alpha: 0.5),
                size: 14,
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: AppTextStyles.labelSmall.copyWith(
            fontSize: 10,
            color: subTextColor(isDark).withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: AppTextStyles.headlineMedium.copyWith(
                color: textColor(isDark),
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              total,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: subTextColor(isDark).withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallStatCard(
    String label,
    String value,
    IconData icon,
    bool isDark,
    Color cardColor,
    Color accentColor, {
    String? subtitle,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accentColor, size: 20),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTextStyles.titleLarge.copyWith(
              color: textColor(isDark),
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: subTextColor(isDark),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: 10,
                color: subTextColor(isDark).withValues(alpha: 0.6),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
