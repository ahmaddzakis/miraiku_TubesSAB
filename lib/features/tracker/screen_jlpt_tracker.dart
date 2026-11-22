import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/game_manager.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
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
  static const int totalScripts = targetHira + targetKata + targetKanji;

  static const int weightHira = 20;
  static const int weightKata = 20;
  static const int weightKanji = 30;
  static const int weightUnits = 30;

  static const double _gaugeOuterSize = 188.0;
  static const double _gaugeInnerSize = 152.0;
  static const double _gaugeStrokeWidth = AppSpacing.md;
  static const double _skillBadgeSize = AppSpacing.huge;

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

  String _getReadinessTierLabel(double readiness) {
    if (readiness >= 1.0) {
      return _t("Ready to Pass N5", "Siap Lulus N5");
    }
    if (readiness >= 0.8) {
      return _t("Exam Ready", "Siap Tempur");
    }
    if (readiness >= 0.4) {
      return _t("Developing", "Berkembang");
    }
    return _t("Beginner", "Pemula");
  }

  IconData _getReadinessTierIcon(double readiness) {
    if (readiness >= 1.0) return Icons.workspace_premium_rounded;
    if (readiness >= 0.8) return Icons.rocket_launch_rounded;
    if (readiness >= 0.4) return Icons.trending_up_rounded;
    return Icons.spa_rounded;
  }

  Color _getReadinessTierColor({
    required double readiness,
    required Color primaryColor,
    required Color secondaryColor,
    required Color accentGoldColor,
    required Color successColor,
  }) {
    if (readiness >= 0.8) return successColor;
    if (readiness >= 0.5) return accentGoldColor;
    if (readiness >= 0.2) return secondaryColor;
    return primaryColor;
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

  _RecommendationInfo _buildNextRecommendation({
    required int hCount,
    required int kCount,
    required int knCount,
    required int uCount,
    required Color primaryColor,
    required Color secondaryColor,
    required Color successColor,
  }) {
    final double hiraProgress = (hCount / targetHira).clamp(0.0, 1.0);
    final double kataProgress = (kCount / targetKata).clamp(0.0, 1.0);
    final double kanjiProgress = (knCount / targetKanji).clamp(0.0, 1.0);
    final double unitProgress = (uCount / totalUnits).clamp(0.0, 1.0);

    final List<_SkillCandidate> candidates = [
      _SkillCandidate(
        title: "Hiragana",
        progress: hiraProgress,
        remainingCount: (targetHira - hCount).clamp(0, targetHira),
        remainingWeightPct: ((1.0 - hiraProgress) * weightHira).round(),
        weightPct: weightHira,
        color: primaryColor,
        icon: Icons.translate_rounded,
        description: _t(
          "Master the remaining ${(targetHira - hCount).clamp(0, targetHira)} Hiragana characters to unlock up to +${((1.0 - hiraProgress) * weightHira).round()}% readiness.",
          "Kuasai ${(targetHira - hCount).clamp(0, targetHira)} aksara Hiragana tersisa untuk menambah hingga +${((1.0 - hiraProgress) * weightHira).round()}% kesiapan N5.",
        ),
      ),
      _SkillCandidate(
        title: "Katakana",
        progress: kataProgress,
        remainingCount: (targetKata - kCount).clamp(0, targetKata),
        remainingWeightPct: ((1.0 - kataProgress) * weightKata).round(),
        weightPct: weightKata,
        color: secondaryColor,
        icon: Icons.language_rounded,
        description: _t(
          "Complete ${(targetKata - kCount).clamp(0, targetKata)} more Katakana characters to boost your readiness by +${((1.0 - kataProgress) * weightKata).round()}%.",
          "Selesaikan ${(targetKata - kCount).clamp(0, targetKata)} aksara Katakana lagi untuk meningkatkan kesiapan sebesar +${((1.0 - kataProgress) * weightKata).round()}%.",
        ),
      ),
      _SkillCandidate(
        title: "Kanji N5",
        progress: kanjiProgress,
        remainingCount: (targetKanji - knCount).clamp(0, targetKanji),
        remainingWeightPct: ((1.0 - kanjiProgress) * weightKanji).round(),
        weightPct: weightKanji,
        color: AppColors.kanjiPurple,
        icon: Icons.auto_stories_rounded,
        description: _t(
          "Learn ${(targetKanji - knCount).clamp(0, targetKanji)} more N5 Kanji characters to gain up to +${((1.0 - kanjiProgress) * weightKanji).round()}% overall readiness.",
          "Pelajari ${(targetKanji - knCount).clamp(0, targetKanji)} karakter Kanji N5 tersisa untuk meraih tambahan hingga +${((1.0 - kanjiProgress) * weightKanji).round()}% kesiapan.",
        ),
      ),
      _SkillCandidate(
        title: _t("Learning Materials (Unit 1-4)", "Materi Belajar (Unit 1-4)"),
        progress: unitProgress,
        remainingCount: (totalUnits - uCount).clamp(0, totalUnits),
        remainingWeightPct: ((1.0 - unitProgress) * weightUnits).round(),
        weightPct: weightUnits,
        color: successColor,
        icon: Icons.menu_book_rounded,
        description: _t(
          "Pass ${(totalUnits - uCount).clamp(0, totalUnits)} more Unit Final Exams (Units 1-4) to earn up to +${((1.0 - unitProgress) * weightUnits).round()}% JLPT N5 readiness.",
          "Taklukkan ${(totalUnits - uCount).clamp(0, totalUnits)} Ujian Akhir Unit (Unit 1-4) lagi untuk meraih tambahan hingga +${((1.0 - unitProgress) * weightUnits).round()}% kesiapan JLPT N5.",
        ),
      ),
    ];

    final incomplete = candidates.where((c) => c.progress < 1.0).toList();
    if (incomplete.isEmpty) {
      return _RecommendationInfo(
        badgeLabel: _t("ALL MASTERED", "SEMUA TUNTAS"),
        headline: _t(
          "100% JLPT N5 Curriculum Completed!",
          "100% Kurikulum JLPT N5 Telah Dikuasai!",
        ),
        body: _t(
          "You have mastered all scripts and passed all 4 unit exams. Test your skills in the JLPT N5 Simulation!",
          "Seluruh aksara dan 4 ujian unit telah tuntas. Uji kemampuanmu di Simulasi Ujian JLPT N5 sekarang!",
        ),
        color: successColor,
        icon: Icons.emoji_events_rounded,
      );
    }

    incomplete.sort((a, b) {
      final int progressCmp = a.progress.compareTo(b.progress);
      if (progressCmp != 0) return progressCmp;
      return b.remainingWeightPct.compareTo(a.remainingWeightPct);
    });

    final best = incomplete.first;
    final int gainPct = best.remainingWeightPct > 0
        ? best.remainingWeightPct
        : best.weightPct;

    return _RecommendationInfo(
      badgeLabel: _t("+$gainPct% POTENTIAL", "POTENSI +$gainPct%"),
      headline: best.title,
      body: best.description,
      color: best.color,
      icon: best.icon,
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

    return ValueListenableBuilder<String>(
      valueListenable: globalLanguage,
      builder: (context, _, _) {
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
                          final Color surfaceColor = isDark
                              ? AppColors.surfaceDark
                              : AppColors.surfaceLight;
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
                          final Color accentGoldColor = isDark
                              ? AppColors.accentDark
                              : AppColors.accentLight;
                          final Color successColor = isDark
                              ? AppColors.successDark
                              : AppColors.successLight;
                          final Color borderColor = isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight;

                          final Color tierColor = _getReadinessTierColor(
                            readiness: readiness,
                            primaryColor: accentColor,
                            secondaryColor: secondaryColor,
                            accentGoldColor: accentGoldColor,
                            successColor: successColor,
                          );

                          final int totalLearnedScripts =
                              (hCount.clamp(0, targetHira) +
                                  kCount.clamp(0, targetKata) +
                                  knCount.clamp(0, targetKanji));
                          final int readinessPct = (readiness * 100).toInt();
                          final int remainingPct =
                              (100 - readinessPct).clamp(0, 100);

                          final recommendation = _buildNextRecommendation(
                            hCount: hCount,
                            kCount: kCount,
                            knCount: knCount,
                            uCount: _unitProgress,
                            primaryColor: accentColor,
                            secondaryColor: secondaryColor,
                            successColor: successColor,
                          );

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
                            body: SafeArea(
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.lg,
                                  vertical: AppSpacing.md,
                                ),
                                child: Center(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: AppSpacing.maxContentWidth,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        // 1. Hero Readiness Card
                                        _buildHeroReadinessCard(
                                          isDark: isDark,
                                          reduceMotion: reduceMotion,
                                          readiness: readiness,
                                          surfaceColor: surfaceColor,
                                          textColor: textColor,
                                          subTextColor: subTextColor,
                                          accentColor: accentColor,
                                          secondaryColor: secondaryColor,
                                          tierColor: tierColor,
                                          borderColor: borderColor,
                                        ),
                                        const SizedBox(height: AppSpacing.md),

                                        // 2. Quick Summary Strip
                                        _buildQuickSummaryStrip(
                                          isDark: isDark,
                                          totalLearnedScripts:
                                              totalLearnedScripts,
                                          unitProgress: _unitProgress,
                                          readiness: readiness,
                                          remainingPct: remainingPct,
                                          textColor: textColor,
                                          subTextColor: subTextColor,
                                          accentColor: accentColor,
                                          secondaryColor: secondaryColor,
                                          successColor: successColor,
                                          accentGoldColor: accentGoldColor,
                                        ),
                                        const SizedBox(height: AppSpacing.xl),

                                        // 3. Skill Breakdown Header & Cards
                                        _buildSectionHeader(
                                          title: _t(
                                            "Competency Breakdown",
                                            "Rincian Kompetensi N5",
                                          ),
                                          badgeLabel: _t(
                                            "4 WEIGHTED AREAS",
                                            "4 KOMPONEN BOBOT",
                                          ),
                                          textColor: textColor,
                                          accentColor: secondaryColor,
                                        ),
                                        const SizedBox(height: AppSpacing.sm),

                                        _buildProgressCard(
                                          isDark: isDark,
                                          title: "Hiragana",
                                          subtitle: _t(
                                            "Basic Japanese phonetic script",
                                            "Aksara fonetik dasar Jepang",
                                          ),
                                          scriptBadge: "あ",
                                          weightPct: weightHira,
                                          current: hCount,
                                          target: targetHira,
                                          unitLabel: _t("chars", "aksara"),
                                          textColor: textColor,
                                          subTextColor: subTextColor,
                                          accentColor: accentColor,
                                          successColor: successColor,
                                        ),
                                        const SizedBox(height: AppSpacing.sm),

                                        _buildProgressCard(
                                          isDark: isDark,
                                          title: "Katakana",
                                          subtitle: _t(
                                            "Loanwords & foreign terms script",
                                            "Aksara kata serapan & istilah asing",
                                          ),
                                          scriptBadge: "ア",
                                          weightPct: weightKata,
                                          current: kCount,
                                          target: targetKata,
                                          unitLabel: _t("chars", "aksara"),
                                          textColor: textColor,
                                          subTextColor: subTextColor,
                                          accentColor: secondaryColor,
                                          successColor: successColor,
                                        ),
                                        const SizedBox(height: AppSpacing.sm),

                                        _buildProgressCard(
                                          isDark: isDark,
                                          title: "Kanji N5",
                                          subtitle: _t(
                                            "Essential N5 ideograms & meanings",
                                            "Karakter Kanji esensial standar N5",
                                          ),
                                          scriptBadge: "漢",
                                          weightPct: weightKanji,
                                          current: knCount,
                                          target: targetKanji,
                                          unitLabel: _t("kanji", "kanji"),
                                          textColor: textColor,
                                          subTextColor: subTextColor,
                                          accentColor: AppColors.kanjiPurple,
                                          successColor: successColor,
                                        ),
                                        const SizedBox(height: AppSpacing.sm),

                                        _buildProgressCard(
                                          isDark: isDark,
                                          title: _t(
                                            "Learning Materials (Unit 1-4)",
                                            "Materi Belajar (Unit 1-4)",
                                          ),
                                          subtitle: _t(
                                            "Vocabulary, grammar & unit exams",
                                            "Kosakata, tata bahasa & ujian unit",
                                          ),
                                          iconBadge: Icons.menu_book_rounded,
                                          weightPct: weightUnits,
                                          current: _unitProgress,
                                          target: totalUnits,
                                          unitLabel: _t("units", "unit"),
                                          textColor: textColor,
                                          subTextColor: subTextColor,
                                          accentColor: successColor,
                                          successColor: successColor,
                                        ),
                                        const SizedBox(height: AppSpacing.xl),

                                        // 4. Smart Recommendation Card
                                        _buildRecommendationCard(
                                          isDark: isDark,
                                          recommendation: recommendation,
                                          textColor: textColor,
                                          subTextColor: subTextColor,
                                        ),
                                        const SizedBox(height: AppSpacing.xxxl),
                                      ],
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
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeroReadinessCard({
    required bool isDark,
    required bool reduceMotion,
    required double readiness,
    required Color surfaceColor,
    required Color textColor,
    required Color subTextColor,
    required Color accentColor,
    required Color secondaryColor,
    required Color tierColor,
    required Color borderColor,
  }) {
    final Color gradientStart = isDark
        ? AppColors.primaryContainerDark.withValues(alpha: 0.55)
        : AppColors.primaryContainerLight.withValues(alpha: 0.75);
    final Color gradientEnd = isDark
        ? AppColors.secondaryContainerDark.withValues(alpha: 0.40)
        : AppColors.secondaryContainerLight.withValues(alpha: 0.55);

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
        border: Border.all(
          color: accentColor.withValues(alpha: isDark ? 0.35 : 0.25),
          width: 1.5,
        ),
        boxShadow: AppShadows.card(isDark),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
        child: Stack(
          children: [
            // Soft Japanese Heritage Gradient Backdrop
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      gradientStart,
                      surfaceColor,
                      gradientEnd,
                    ],
                  ),
                ),
              ),
            ),

            // Subtle Japanese Watermark ("合格" - Goukaku / Pass)
            Positioned(
              right: -AppSpacing.sm,
              top: -AppSpacing.xs,
              child: IgnorePointer(
                child: Text(
                  "合格",
                  style: AppTextStyles.japaneseHero.copyWith(
                    color: accentColor.withValues(alpha: isDark ? 0.08 : 0.07),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  // Top Badges Row (Responsive Wrap for 360dp screens)
                  SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        AppBadge(
                          label: "JLPT N5 LEVEL",
                          icon: Icons.verified_rounded,
                          color: accentColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs,
                          ),
                        ),
                        AppBadge(
                          label: _getReadinessTierLabel(readiness),
                          icon: _getReadinessTierIcon(readiness),
                          color: tierColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Overall Readiness Circular Gauge with Animation
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
                          // Inner soft medallion backdrop
                          Container(
                            width: _gaugeInnerSize,
                            height: _gaugeInnerSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: surfaceColor.withValues(
                                alpha: isDark ? 0.85 : 0.90,
                              ),
                              boxShadow: AppShadows.accentGlow(
                                tierColor,
                                isDark: isDark,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: _gaugeOuterSize,
                            height: _gaugeOuterSize,
                            child: CircularProgressIndicator(
                              value: value,
                              strokeWidth: _gaugeStrokeWidth,
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
                                style: AppTextStyles.displayLarge.copyWith(
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xxs),
                              Text(
                                _t("READY", "SIAP"),
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: subTextColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Motivational Banner Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: surfaceColor.withValues(
                        alpha: isDark ? 0.88 : 0.92,
                      ),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.xs),
                          decoration: BoxDecoration(
                            color: tierColor.withValues(
                              alpha: isDark ? 0.18 : 0.12,
                            ),
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusSm,
                            ),
                          ),
                          child: Icon(
                            Icons.auto_awesome_rounded,
                            color: tierColor,
                            size: AppSpacing.lg,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            _getMotivationalText(readiness),
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickSummaryStrip({
    required bool isDark,
    required int totalLearnedScripts,
    required int unitProgress,
    required double readiness,
    required int remainingPct,
    required Color textColor,
    required Color subTextColor,
    required Color accentColor,
    required Color secondaryColor,
    required Color successColor,
    required Color accentGoldColor,
  }) {
    final bool isSimReady = readiness >= 0.8;
    final String targetValue = isSimReady
        ? _t("Ready for Sim!", "Siap Simulasi!")
        : (remainingPct == 0
              ? "100%"
              : _t("$remainingPct% to go", "$remainingPct% lagi"));

    return Row(
      children: [
        Expanded(
          child: _buildSummaryChip(
            isDark: isDark,
            icon: Icons.translate_rounded,
            color: accentColor,
            label: _t("Scripts", "Aksara"),
            value: "$totalLearnedScripts / $totalScripts",
            textColor: textColor,
            subTextColor: subTextColor,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: _buildSummaryChip(
            isDark: isDark,
            icon: Icons.fact_check_rounded,
            color: secondaryColor,
            label: _t("Unit Exams", "Ujian Unit"),
            value: "$unitProgress / $totalUnits",
            textColor: textColor,
            subTextColor: subTextColor,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: _buildSummaryChip(
            isDark: isDark,
            icon: isSimReady ? Icons.verified_rounded : Icons.flag_rounded,
            color: isSimReady ? successColor : accentGoldColor,
            label: _t("Pass Target", "Target Lulus"),
            value: targetValue,
            textColor: textColor,
            subTextColor: subTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryChip({
    required bool isDark,
    required IconData icon,
    required Color color,
    required String label,
    required String value,
    required Color textColor,
    required Color subTextColor,
  }) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      borderRadius: AppSpacing.radiusLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xxs),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.18 : 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(icon, size: AppSpacing.md, color: color),
          ),
          const SizedBox(height: AppSpacing.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: AppTextStyles.titleMedium.copyWith(
                color: textColor,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.labelSmall.copyWith(
              color: subTextColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String badgeLabel,
    required Color textColor,
    required Color accentColor,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: [
          Text(
            title,
            style: AppTextStyles.titleLarge.copyWith(
              color: textColor,
              fontWeight: FontWeight.w900,
            ),
          ),
          AppBadge(
            label: badgeLabel,
            color: accentColor,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard({
    required bool isDark,
    required String title,
    required String subtitle,
    String? scriptBadge,
    IconData? iconBadge,
    required int weightPct,
    required int current,
    required int target,
    required String unitLabel,
    required Color textColor,
    required Color subTextColor,
    required Color accentColor,
    required Color successColor,
  }) {
    final double targetProgress = (current / target).clamp(0.0, 1.0);
    final bool isCompleted = current >= target;
    final int pctInt = (targetProgress * 100).toInt();
    final int remaining = (target - current).clamp(0, target);
    final Color statusColor = isCompleted ? successColor : accentColor;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderColor: isCompleted
          ? successColor.withValues(alpha: isDark ? 0.45 : 0.35)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Character / Icon Badge
              Container(
                width: _skillBadgeSize,
                height: _skillBadgeSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: isDark ? 0.18 : 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: accentColor.withValues(alpha: isDark ? 0.35 : 0.25),
                  ),
                ),
                child: scriptBadge != null
                    ? Text(
                        scriptBadge,
                        style: AppTextStyles.japaneseTitle.copyWith(
                          color: accentColor,
                          fontWeight: FontWeight.w900,
                        ),
                      )
                    : Icon(
                        iconBadge ?? Icons.school_rounded,
                        color: accentColor,
                        size: AppSpacing.xl,
                      ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Title, Subtitle & Weight / Status Pills
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          "$current / $target",
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w900,
                            color: isCompleted ? successColor : textColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: subTextColor,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xxs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        AppBadge(
                          label: _t(
                            "Weight $weightPct%",
                            "Bobot $weightPct%",
                          ),
                          color: accentColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: AppSpacing.xxs,
                          ),
                        ),
                        AppBadge(
                          label: isCompleted
                              ? _t("Done ✓", "Selesai ✓")
                              : _t(
                                  "$remaining $unitLabel left",
                                  "$remaining $unitLabel lagi",
                                ),
                          color: statusColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: AppSpacing.xxs,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Progress Bar + Percentage Row
          Row(
            children: [
              Expanded(
                child: AppProgressBar(
                  progress: targetProgress,
                  height: AppSpacing.sm,
                  color: isCompleted ? successColor : accentColor,
                  semanticLabel: title,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                "$pctInt%",
                style: AppTextStyles.labelLarge.copyWith(
                  color: isCompleted ? successColor : accentColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard({
    required bool isDark,
    required _RecommendationInfo recommendation,
    required Color textColor,
    required Color subTextColor,
  }) {
    final Color cardTint = recommendation.color.withValues(
      alpha: isDark ? 0.14 : 0.08,
    );
    final Color borderTint = recommendation.color.withValues(
      alpha: isDark ? 0.40 : 0.30,
    );

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      backgroundColor: cardTint,
      borderColor: borderTint,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lightbulb_rounded,
                      color: recommendation.color,
                      size: AppSpacing.lg,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Flexible(
                      child: Text(
                        _t("Next Recommended Step", "Fokus Selanjutnya"),
                        style: AppTextStyles.labelLarge.copyWith(
                          color: recommendation.color,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                AppBadge(
                  label: recommendation.badgeLabel,
                  color: recommendation.color,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: AppSpacing.xxs,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: recommendation.color.withValues(
                    alpha: isDark ? 0.22 : 0.14,
                  ),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(
                  recommendation.icon,
                  color: recommendation.color,
                  size: AppSpacing.xl,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recommendation.headline,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      recommendation.body,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: subTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SkillCandidate {
  final String title;
  final double progress;
  final int remainingCount;
  final int remainingWeightPct;
  final int weightPct;
  final Color color;
  final IconData icon;
  final String description;

  const _SkillCandidate({
    required this.title,
    required this.progress,
    required this.remainingCount,
    required this.remainingWeightPct,
    required this.weightPct,
    required this.color,
    required this.icon,
    required this.description,
  });
}

class _RecommendationInfo {
  final String badgeLabel;
  final String headline;
  final String body;
  final Color color;
  final IconData icon;

  const _RecommendationInfo({
    required this.badgeLabel,
    required this.headline,
    required this.body,
    required this.color,
    required this.icon,
  });
}
