import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/game_manager.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_badge.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_progress_bar.dart';

class JLPTTrackerScreen extends StatefulWidget {
  const JLPTTrackerScreen({super.key});

  @override
  State<JLPTTrackerScreen> createState() => _JLPTTrackerScreenState();
}

class _JLPTTrackerScreenState extends State<JLPTTrackerScreen> {
  static const int targetHira = 104;
  static const int targetKata = 104;
  static const int targetKanji = 68;
  static const int totalUnits = 4;

  int _unitProgress = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUnitProgress();
  }

  Future<void> _loadUnitProgress() async {
    final prefs = await SharedPreferences.getInstance();
    int completed = 0;
    if ((prefs.getInt('u1_test_stars') ?? 0) >= 1) completed++;
    if ((prefs.getInt('u2_test_stars') ?? 0) >= 1) completed++;
    if ((prefs.getInt('u3_test_stars') ?? 0) >= 1) completed++;
    if ((prefs.getInt('u4_test_stars') ?? 0) >= 1) completed++;

    if (mounted) {
      setState(() {
        _unitProgress = completed;
        _isLoading = false;
      });
    }
  }

  String _t(String en, String id) {
    return globalLanguage.value == 'id' ? id : en;
  }

  double _calculateOverallReadiness(
    int hira,
    int kata,
    int kanji,
    int units,
  ) {
    final double hiraProgress = (hira / targetHira).clamp(0.0, 1.0);
    final double kataProgress = (kata / targetKata).clamp(0.0, 1.0);
    final double kanjiProgress = (kanji / targetKanji).clamp(0.0, 1.0);
    final double unitProgress = (units / totalUnits).clamp(0.0, 1.0);

    return (hiraProgress * 0.2) +
        (kataProgress * 0.2) +
        (kanjiProgress * 0.3) +
        (unitProgress * 0.3);
  }

  String _getMotivationalText(double readiness) {
    if (readiness >= 1.0) {
      return _t(
        "Omedetou! You are ready for N5! 🎓",
        "Omedetou! Kamu siap untuk ujian N5! 🎓",
      );
    }
    if (readiness >= 0.8) {
      return _t(
        "Almost there! Just a little more push! 🚀",
        "Sedikit lagi! Ayo semangat belajarnya! 🚀",
      );
    }
    if (readiness >= 0.5) {
      return _t(
        "Halfway through! Keep up the great work! ✨",
        "Sudah setengah jalan! Teruslah berjuang! ✨",
      );
    }
    if (readiness >= 0.2) {
      return _t(
        "You're making progress! Step by step. 🌱",
        "Kamu mulai berkembang! Langkah demi langkah. 🌱",
      );
    }
    return _t(
      "Your journey has begun. Ganbatte! 🍡",
      "Perjalananmu baru dimulai. Ganbatte! 🍡",
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryLight),
        ),
      );
    }

    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return ValueListenableBuilder<bool>(
      valueListenable: globalDarkMode,
      builder: (context, isDark, _) {
        return PopScope(
          canPop: true,
          child: ValueListenableBuilder<List<String>>(
            valueListenable: globalLearnedHiragana,
            builder: (context, learnedHira, _) {
              return ValueListenableBuilder<List<String>>(
                valueListenable: globalLearnedKatakana,
                builder: (context, learnedKata, _) {
                  return ValueListenableBuilder<List<String>>(
                    valueListenable: globalLearnedKanji,
                    builder: (context, learnedKanji, _) {
                      final int hCount = learnedHira.length;
                      final int kCount = learnedKata.length;
                      final int knCount = learnedKanji.length;
                      final double readiness = _calculateOverallReadiness(
                        hCount,
                        kCount,
                        knCount,
                        _unitProgress,
                      );

                      final Color bgColor = isDark
                          ? AppColors.backgroundDark
                          : AppColors.backgroundLight;
                      final Color textColor = isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight;
                      final Color subTextColor = isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight;
                      final Color accentColor = isDark
                          ? AppColors.primaryDark
                          : AppColors.primaryLight;
                      final Color secondaryColor = isDark
                          ? AppColors.secondaryDark
                          : AppColors.secondaryLight;
                      final Color successColor = isDark
                          ? AppColors.successDark
                          : AppColors.successLight;

                      return Scaffold(
                        backgroundColor: bgColor,
                        appBar: AppBar(
                          backgroundColor: bgColor,
                          elevation: 0,
                          centerTitle: true,
                          leading: IconButton(
                            icon: Icon(
                              Icons.arrow_back_ios_rounded,
                              color: textColor,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                          title: Text(
                            _t("JLPT Readiness", "Kesiapan JLPT"),
                            style: AppTextStyles.titleLarge.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        body: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Column(
                            children: [
                              AppBadge(
                                label: "JLPT N5 LEVEL",
                                color: accentColor,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.xs,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xxxl),

                              // Overall Readiness Gauge with Animation
                              TweenAnimationBuilder<double>(
                                tween: Tween<double>(
                                  begin: reduceMotion ? readiness : 0.0,
                                  end: readiness,
                                ),
                                duration: reduceMotion
                                    ? Duration.zero
                                    : AppSpacing.animSlow,
                                curve: Curves.easeOutCubic,
                                builder: (context, value, _) {
                                  return Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SizedBox(
                                        width: 220,
                                        height: 220,
                                        child: CircularProgressIndicator(
                                          value: value,
                                          strokeWidth: 20,
                                          backgroundColor: isDark
                                              ? AppColors.surfaceVariantDark
                                              : AppColors.surfaceVariantLight,
                                          color: accentColor,
                                          strokeCap: StrokeCap.round,
                                        ),
                                      ),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "${(value * 100).toInt()}%",
                                            style: AppTextStyles.displayLarge
                                                .copyWith(
                                              color: textColor,
                                            ),
                                          ),
                                          Text(
                                            _t("READY", "SIAP"),
                                            style: AppTextStyles.labelLarge
                                                .copyWith(
                                              color: subTextColor,
                                              letterSpacing: 2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: AppSpacing.huge),

                              Text(
                                _getMotivationalText(readiness),
                                textAlign: TextAlign.center,
                                style: AppTextStyles.titleLarge.copyWith(
                                  color: textColor,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.huge),

                              _buildProgressCard(
                                title: "Hiragana",
                                current: hCount,
                                target: targetHira,
                                textColor: textColor,
                                subTextColor: subTextColor,
                                accentColor: accentColor,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              _buildProgressCard(
                                title: "Katakana",
                                current: kCount,
                                target: targetKata,
                                textColor: textColor,
                                subTextColor: subTextColor,
                                accentColor: secondaryColor,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              _buildProgressCard(
                                title: "Kanji N5",
                                current: knCount,
                                target: targetKanji,
                                textColor: textColor,
                                subTextColor: subTextColor,
                                accentColor: AppColors.kanjiPurple,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              _buildProgressCard(
                                title: _t(
                                  "Learning Materials (Unit 1-4)",
                                  "Materi Belajar (Unit 1-4)",
                                ),
                                current: _unitProgress,
                                target: totalUnits,
                                textColor: textColor,
                                subTextColor: subTextColor,
                                accentColor: successColor,
                              ),
                              const SizedBox(height: AppSpacing.xxxl),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildProgressCard({
    required String title,
    required int current,
    required int target,
    required Color textColor,
    required Color subTextColor,
    required Color accentColor,
  }) {
    final double targetProgress = (current / target).clamp(0.0, 1.0);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w900,
                    color: textColor,
                  ),
                ),
              ),
              Text(
                "$current / $target",
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: subTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppProgressBar(
            progress: targetProgress,
            height: 12,
            color: accentColor,
            semanticLabel: title,
          ),
        ],
      ),
    );
  }
}
