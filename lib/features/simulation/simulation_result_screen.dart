import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/game_manager.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_badge.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_progress_bar.dart';
import '../../data/simulation_data.dart';
import '../../widgets/rounded_mochi_asset.dart';
import 'simulation_review_screen.dart';

/// Strength / focus tag assigned to each section in [SectionScoreTile].
enum SectionStrengthTag {
  strongest,
  needsPractice,
  balanced,
}

/// Pure, testable analytics helper for [SimulationResultScreen].
class SimulationResultAnalytics {
  static const int maxScore = 180;
  static const int passTarget = 80;
  static const int maxLangPoints = 60;
  static const int maxReadPoints = 120;

  final int totalScore;
  final bool isPassed;
  final int gapToPass;
  final int surplusAboveTarget;
  final String grade;
  final double passThresholdPercent;
  final String passThresholdPercentText;
  final int langPoints;
  final int readPoints;
  final double langRatio;
  final double readRatio;
  final SectionStrengthTag langTag;
  final SectionStrengthTag readTag;
  final int totalCorrect;
  final int totalQuestions;
  final int accuracyPercent;
  final int? previousScoreDelta;

  const SimulationResultAnalytics({
    required this.totalScore,
    required this.isPassed,
    required this.gapToPass,
    required this.surplusAboveTarget,
    required this.grade,
    required this.passThresholdPercent,
    required this.passThresholdPercentText,
    required this.langPoints,
    required this.readPoints,
    required this.langRatio,
    required this.readRatio,
    required this.langTag,
    required this.readTag,
    required this.totalCorrect,
    required this.totalQuestions,
    required this.accuracyPercent,
    required this.previousScoreDelta,
  });

  /// Computes the exact passing percentage from [passTarget] and [maxScore]
  /// (80 / 180 = 44.444...% -> 44.4%), fixing the hardcoded 44.5% bug.
  static double computePassThresholdPercent({
    int target = passTarget,
    int max = maxScore,
  }) {
    if (max <= 0) return 0.0;
    final double raw = (target / max) * 100.0;
    return (raw * 10).round() / 10.0;
  }

  /// Formats the computed passing threshold percentage to 1 decimal place ('44.4').
  static String formatPassThresholdPercent({
    int target = passTarget,
    int max = maxScore,
  }) {
    return computePassThresholdPercent(target: target, max: max)
        .toStringAsFixed(1);
  }

  /// Computes remaining points needed to reach [passTarget] (80).
  static int computeGapToPass(num score, {int target = passTarget}) {
    final int pts = score.round().clamp(0, maxScore);
    return math.max(0, target - pts);
  }

  /// Computes letter grade consistently with the 80/180 (44.44%) pass threshold.
  static String computeGrade(num score) {
    final int pts = score.round().clamp(0, maxScore);
    final double percent = (pts / maxScore) * 100.0;
    if (percent >= 90.0) return 'S';
    if (percent >= 80.0) return 'A';
    if (percent >= 70.0) return 'B';
    if (pts >= passTarget) return 'C';
    return 'D';
  }

  /// Determines section strength tags ('Strongest' vs 'Needs practice') from
  /// sectional accuracy ratios.
  static (SectionStrengthTag, SectionStrengthTag) evaluateSectionTags({
    required double langRatio,
    required double readRatio,
  }) {
    const double passRatio = passTarget / maxScore; // ~0.4444
    final double diff = (langRatio - readRatio).abs();

    if (diff >= 0.05) {
      if (langRatio > readRatio) {
        final SectionStrengthTag langTag = langRatio >= passRatio
            ? SectionStrengthTag.strongest
            : SectionStrengthTag.balanced;
        return (langTag, SectionStrengthTag.needsPractice);
      } else {
        final SectionStrengthTag readTag = readRatio >= passRatio
            ? SectionStrengthTag.strongest
            : SectionStrengthTag.balanced;
        return (SectionStrengthTag.needsPractice, readTag);
      }
    }

    // Ratios are within 5% of each other
    if (langRatio < passRatio && readRatio < passRatio) {
      return (
        SectionStrengthTag.needsPractice,
        SectionStrengthTag.needsPractice,
      );
    }
    return (SectionStrengthTag.strongest, SectionStrengthTag. balanced);
  }

  /// Resolves score delta compared to the chronologically previous attempt in
  /// [rawHistory], or returns `null` if no prior attempt exists.
  static int? computePreviousScoreDelta({
    required int currentScore,
    required int currentTimeSpentSeconds,
    required List<dynamic> rawHistory,
  }) {
    final List<Map<String, dynamic>> sorted = rawHistory
        .whereType<Map>()
        .map((m) => Map<String, dynamic>.from(m))
        .toList()
      ..sort((a, b) {
        final DateTime dateA =
            DateTime.tryParse('${a['date']}') ?? DateTime(1970);
        final DateTime dateB =
            DateTime.tryParse('${b['date']}') ?? DateTime(1970);
        return dateB.compareTo(dateA);
      });

    if (sorted.length < 2) return null;

    int matchedIndex = -1;
    for (int i = 0; i < sorted.length; i++) {
      final int itemScore =
          ((sorted[i]['totalPoints'] as num?) ?? 0).round().clamp(0, maxScore);
      final int itemTime =
          (sorted[i]['timeSpentSeconds'] as num?)?.toInt() ?? -1;
      if (itemScore == currentScore && itemTime == currentTimeSpentSeconds) {
        matchedIndex = i;
        break;
      }
    }

    if (matchedIndex == -1) {
      for (int i = 0; i < sorted.length; i++) {
        final int itemScore = ((sorted[i]['totalPoints'] as num?) ?? 0)
            .round()
            .clamp(0, maxScore);
        if (itemScore == currentScore) {
          matchedIndex = i;
          break;
        }
      }
    }

    final int currentIdx = matchedIndex >= 0 ? matchedIndex : 0;
    if (currentIdx + 1 >= sorted.length) return null;

    final int prevScore = ((sorted[currentIdx + 1]['totalPoints'] as num?) ?? 0)
        .round()
        .clamp(0, maxScore);
    return currentScore - prevScore;
  }

  /// Builds a complete [SimulationResultAnalytics] snapshot.
  factory SimulationResultAnalytics.compute({
    required double totalPoints,
    required bool isPassed,
    required int languageScore,
    required int languageTotal,
    required int readingScore,
    required int readingTotal,
    required int timeSpentSeconds,
    List<dynamic> rawHistory = const [],
  }) {
    final int totalScore = totalPoints.round().clamp(0, maxScore);
    final double langRatio =
        languageTotal > 0 ? (languageScore / languageTotal).clamp(0.0, 1.0) : 0.0;
    final double readRatio =
        readingTotal > 0 ? (readingScore / readingTotal).clamp(0.0, 1.0) : 0.0;

    final int langPoints =
        (langRatio * maxLangPoints).round().clamp(0, maxLangPoints);
    final int readPoints =
        (readRatio * maxReadPoints).round().clamp(0, maxReadPoints);

    final (langTag, readTag) = evaluateSectionTags(
      langRatio: langRatio,
      readRatio: readRatio,
    );

    final int totalQuestions = languageTotal + readingTotal;
    final int totalCorrect = languageScore + readingScore;
    final int accuracyPercent = totalQuestions > 0
        ? ((totalCorrect / totalQuestions) * 100).round().clamp(0, 100)
        : 0;

    final int gapToPass = computeGapToPass(totalScore);
    final int surplus = math.max(0, totalScore - passTarget);
    final double thresholdPct = computePassThresholdPercent();

    return SimulationResultAnalytics(
      totalScore: totalScore,
      isPassed: isPassed,
      gapToPass: gapToPass,
      surplusAboveTarget: surplus,
      grade: computeGrade(totalScore),
      passThresholdPercent: thresholdPct,
      passThresholdPercentText: formatPassThresholdPercent(),
      langPoints: langPoints,
      readPoints: readPoints,
      langRatio: langRatio,
      readRatio: readRatio,
      langTag: langTag,
      readTag: readTag,
      totalCorrect: totalCorrect,
      totalQuestions: totalQuestions,
      accuracyPercent: accuracyPercent,
      previousScoreDelta: computePreviousScoreDelta(
        currentScore: totalScore,
        currentTimeSpentSeconds: timeSpentSeconds,
        rawHistory: rawHistory,
      ),
    );
  }
}

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

class _SimulationResultScreenState extends State<SimulationResultScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entryController;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: AppSpacing.animSlow,
    )..forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes}m ${remainingSeconds}s';
  }

  void _openReviewScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SimulationReviewScreen(
          userAnswers: widget.userAnswers,
          questions: widget.questions,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool reduceMotion = MediaQuery.disableAnimationsOf(context);

    return ValueListenableBuilder<bool>(
      valueListenable: globalDarkMode,
      builder: (context, isDark, _) {
        return ValueListenableBuilder<String>(
          valueListenable: globalLanguage,
          builder: (context, lang, _) {
            return ValueListenableBuilder<List<dynamic>>(
              valueListenable: globalSimulationHistory,
              builder: (context, historyList, _) {
                final Color bgColor = isDark
                    ? AppColors.backgroundDark
                    : AppColors.backgroundLight;
                final Color textColor = isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight;
                final Color subTextColor = isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight;
                final Color primaryColor =
                    isDark ? AppColors.primaryDark : AppColors.primaryLight;
                final Color secondaryColor =
                    isDark ? AppColors.secondaryDark : AppColors.secondaryLight;
                final Color successColor =
                    isDark ? AppColors.successDark : AppColors.successLight;
                final Color accentColor =
                    isDark ? AppColors.accentDark : AppColors.accentLight;

                final analytics = SimulationResultAnalytics.compute(
                  totalPoints: widget.totalPoints,
                  isPassed: widget.isPassed,
                  languageScore: widget.languageScore,
                  languageTotal: widget.languageTotal,
                  readingScore: widget.readingScore,
                  readingTotal: widget.readingTotal,
                  timeSpentSeconds: widget.timeSpentSeconds,
                  rawHistory: historyList,
                );

                return Scaffold(
                  backgroundColor: bgColor,
                  appBar: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: Semantics(
                      button: true,
                      label: AppLocalizations.simResultCloseSemantics(),
                      child: IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: textColor,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    title: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppLocalizations.simResultAppBarTitle(),
                          style: AppTextStyles.titleLarge.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Text(
                          AppLocalizations.simResultAppBarSubtitle(),
                          style: AppTextStyles.labelSmall.copyWith(
                            color: subTextColor,
                          ),
                        ),
                      ],
                    ),
                    centerTitle: true,
                  ),
                  body: SafeArea(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                        vertical: AppSpacing.md,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: AppSpacing.maxContentWidth,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // 1. ScoreRingHero Card
                              _StaggeredSlideFade(
                                controller: _entryController,
                                stepIndex: 0,
                                reduceMotion: reduceMotion,
                                child: ScoreRingHero(
                                  analytics: analytics,
                                  isDark: isDark,
                                  reduceMotion: reduceMotion,
                                  textColor: textColor,
                                  subTextColor: subTextColor,
                                  primaryColor: primaryColor,
                                  successColor: successColor,
                                  accentColor: accentColor,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),

                              // 2. Sectional Score Breakdown Card
                              _StaggeredSlideFade(
                                controller: _entryController,
                                stepIndex: 1,
                                reduceMotion: reduceMotion,
                                child: _SectionalBreakdownCard(
                                  analytics: analytics,
                                  languageScore: widget.languageScore,
                                  languageTotal: widget.languageTotal,
                                  readingScore: widget.readingScore,
                                  readingTotal: widget.readingTotal,
                                  isDark: isDark,
                                  textColor: textColor,
                                  subTextColor: subTextColor,
                                  primaryColor: primaryColor,
                                  secondaryColor: secondaryColor,
                                  successColor: successColor,
                                  accentColor: accentColor,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),

                              // 3. Unified Accuracy & Duration Summary Card
                              _StaggeredSlideFade(
                                controller: _entryController,
                                stepIndex: 2,
                                reduceMotion: reduceMotion,
                                child: _ReportMetricsCard(
                                  accuracyLabel: AppLocalizations
                                      .simResultAccuracyLabel(),
                                  accuracyValue: '${analytics.accuracyPercent}%',
                                  accuracySubtitle: AppLocalizations
                                      .simResultCorrectCount(
                                    analytics.totalCorrect,
                                    analytics.totalQuestions,
                                  ),
                                  durationLabel: AppLocalizations
                                      .simResultDurationLabel(),
                                  durationValue: _formatDuration(
                                    widget.timeSpentSeconds,
                                  ),
                                  durationSubtitle: AppLocalizations
                                      .simResultDurationSubtitle(),
                                  primaryColor: primaryColor,
                                  secondaryColor: secondaryColor,
                                  textColor: textColor,
                                  subTextColor: subTextColor,
                                  isDark: isDark,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xl),

                              // 4. ExamActionBar (Review Answers only)
                              _StaggeredSlideFade(
                                controller: _entryController,
                                stepIndex: 3,
                                reduceMotion: reduceMotion,
                                child: ExamActionBar(
                                  onReviewAnswers: _openReviewScreen,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xxl),
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
    );
  }
}

/// Hero card aligned with Exam History's PerformanceSummaryCard:
/// - Balanced 1-line header (`Passed • 合格` / `Not Passed • 不合格` on left, `Grade X` on right)
/// - Inset score gauge block with animated ring, target `80` marker, gap + delta, and dynamic `44.4%` pass mark
/// - Clean inset Mochi mascot encouragement banner without emojis
class ScoreRingHero extends StatelessWidget {
  final SimulationResultAnalytics analytics;
  final bool isDark;
  final bool reduceMotion;
  final Color textColor;
  final Color subTextColor;
  final Color primaryColor;
  final Color successColor;
  final Color accentColor;

  const ScoreRingHero({
    super.key,
    required this.analytics,
    required this.isDark,
    required this.reduceMotion,
    required this.textColor,
    required this.subTextColor,
    required this.primaryColor,
    required this.successColor,
    required this.accentColor,
  });

  Color _resolveGradeColor(String grade) {
    switch (grade) {
      case 'S':
      case 'A':
        return successColor;
      case 'B':
        return isDark ? AppColors.secondaryDark : AppColors.secondaryLight;
      case 'C':
        return accentColor;
      default:
        return primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color heroAccent = analytics.isPassed ? successColor : primaryColor;
    final Color surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final Color containerTint = analytics.isPassed
        ? (isDark
            ? AppColors.successContainerDark.withValues(alpha: 0.28)
            : AppColors.successContainerLight.withValues(alpha: 0.48))
        : (isDark
            ? AppColors.primaryContainerDark.withValues(alpha: 0.24)
            : AppColors.primaryContainerLight.withValues(alpha: 0.42));
    final Color gradeColor = _resolveGradeColor(analytics.grade);
    final double scoreProgress =
        (analytics.totalScore / SimulationResultAnalytics.maxScore)
            .clamp(0.0, 1.0);

    final String targetStatusText = analytics.isPassed
        ? AppLocalizations.simResultPassedAboveTarget(
            analytics.surplusAboveTarget,
          )
        : AppLocalizations.simResultGapToPass(analytics.gapToPass);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [containerTint, surfaceColor],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: AppShadows.card(isDark),
      ),
      child: Column(
        children: [
          // 1. Balanced Single Header Row: Status Badge (left) & Grade Badge (right)
          SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                AppBadge(
                  label: analytics.isPassed
                      ? AppLocalizations.simResultStatusPassedBadge()
                      : AppLocalizations.simResultStatusNotPassedBadge(),
                  icon: analytics.isPassed
                      ? Icons.check_circle_rounded
                      : Icons.flag_rounded,
                  color: heroAccent,
                ),
                AppBadge(
                  label: AppLocalizations.simResultGradeBadge(
                    analytics.grade,
                  ),
                  icon: Icons.workspace_premium_rounded,
                  color: gradeColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // 2. Inset Score Gauge Block (cohesive with PerformanceSummaryCard's Best Score panel)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceVariantDark.withValues(alpha: 0.75)
                  : AppColors.surfaceLight.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(
                color: heroAccent.withValues(alpha: 0.25),
              ),
            ),
            child: Column(
              children: [
                Semantics(
                  label: AppLocalizations.simResultRingSemantics(
                    analytics.totalScore,
                    SimulationResultAnalytics.maxScore,
                    targetStatusText,
                  ),
                  child: RepaintBoundary(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                        begin: reduceMotion ? 1.0 : 0.0,
                        end: 1.0,
                      ),
                      duration:
                          reduceMotion ? Duration.zero : AppSpacing.animSlow,
                      curve: Curves.easeOutCubic,
                      builder: (context, animValue, _) {
                        final double animatedProgress =
                            scoreProgress * animValue;
                        final int animatedScore =
                            (analytics.totalScore * animValue).round();

                        return SizedBox(
                          width: 164,
                          height: 164,
                          child: CustomPaint(
                            painter: _ScoreRingPainter(
                              progress: animatedProgress,
                              targetRatio:
                                  SimulationResultAnalytics.passTarget /
                                      SimulationResultAnalytics.maxScore,
                              activeColor: heroAccent,
                              trackColor: isDark
                                  ? AppColors.surfaceDark
                                  : AppColors.borderLight,
                              markerColor: analytics.isPassed
                                  ? successColor
                                  : accentColor,
                              labelStyle: AppTextStyles.labelSmall.copyWith(
                                color: subTextColor,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '$animatedScore',
                                    style: AppTextStyles.displayLarge.copyWith(
                                      color: textColor,
                                    ),
                                  ),
                                  Text(
                                    '/ ${SimulationResultAnalytics.maxScore}',
                                    style: AppTextStyles.titleMedium.copyWith(
                                      color: subTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Gap / Surplus + Score Delta Chip inline
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xxs,
                  children: [
                    Text(
                      targetStatusText,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: heroAccent,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (analytics.previousScoreDelta != null &&
                        analytics.previousScoreDelta != 0)
                      _ResultScoreDeltaChip(
                        delta: analytics.previousScoreDelta!,
                        successColor: successColor,
                        accentColor: accentColor,
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),

                // Clean pass mark reference line
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    AppLocalizations.simResultPassMarkPill(
                      SimulationResultAnalytics.passTarget,
                      SimulationResultAnalytics.maxScore,
                    ),
                    maxLines: 1,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: subTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // 3. Clean Inset Mochi Motivation Row (matching PerformanceSummaryCard)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceVariantDark
                  : AppColors.surfaceVariantLight,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                RoundedMochiAsset(
                  assetPath: analytics.isPassed
                      ? 'assets/images/mochi_senang.png'
                      : 'assets/images/mochi_semangat.png',
                  size: 56,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        analytics.isPassed
                            ? AppLocalizations.simResultMotivationTitlePassed()
                            : AppLocalizations
                                .simResultMotivationTitleNotPassed(),
                        style: AppTextStyles.titleMedium.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        analytics.isPassed
                            ? AppLocalizations.simResultMotivationBodyPassed()
                            : AppLocalizations
                                .simResultMotivationBodyNotPassed(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: subTextColor,
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
    );
  }
}

/// CustomPainter for the circular score gauge with a target marker at 80/180.
class _ScoreRingPainter extends CustomPainter {
  final double progress;
  final double targetRatio;
  final Color activeColor;
  final Color trackColor;
  final Color markerColor;
  final TextStyle labelStyle;

  const _ScoreRingPainter({
    required this.progress,
    required this.targetRatio,
    required this.activeColor,
    required this.trackColor,
    required this.markerColor,
    required this.labelStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double strokeWidth = 11.0;
    const double startAngle = -math.pi / 2;
    const double fullSweep = 2 * math.pi;

    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius =
        (math.min(size.width, size.height) / 2) - strokeWidth - 6.0;
    final Rect arcRect = Rect.fromCircle(center: center, radius: radius);

    // 1. Background Track
    final Paint trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    // 2. Active Progress Arc
    if (progress > 0) {
      final Paint activePaint = Paint()
        ..color = activeColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        arcRect,
        startAngle,
        fullSweep * progress.clamp(0.0, 1.0),
        false,
        activePaint,
      );
    }

    // 3. Pass Target Marker Tick & "80" Label on Ring Perimeter
    final double targetAngle = startAngle + (fullSweep * targetRatio);
    final Offset innerTick = Offset(
      center.dx + (radius - (strokeWidth / 2) - 2) * math.cos(targetAngle),
      center.dy + (radius - (strokeWidth / 2) - 2) * math.sin(targetAngle),
    );
    final Offset outerTick = Offset(
      center.dx + (radius + (strokeWidth / 2) + 3) * math.cos(targetAngle),
      center.dy + (radius + (strokeWidth / 2) + 3) * math.sin(targetAngle),
    );

    final Paint tickPaint = Paint()
      ..color = markerColor
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(innerTick, outerTick, tickPaint);

    final TextPainter tp = TextPainter(
      text: TextSpan(text: '80', style: labelStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    final double labelRadius = radius + (strokeWidth / 2) + 12.0;
    final Offset labelCenter = Offset(
      center.dx + labelRadius * math.cos(targetAngle),
      center.dy + labelRadius * math.sin(targetAngle),
    );
    tp.paint(
      canvas,
      Offset(labelCenter.dx - tp.width / 2, labelCenter.dy - tp.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _ScoreRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.trackColor != trackColor;
  }
}

class _ResultScoreDeltaChip extends StatelessWidget {
  final int delta;
  final Color successColor;
  final Color accentColor;

  const _ResultScoreDeltaChip({
    required this.delta,
    required this.successColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPositive = delta > 0;
    final Color color = isPositive ? successColor : accentColor;
    final String text = isPositive ? '+$delta' : '$delta';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive
                ? Icons.trending_up_rounded
                : Icons.trending_down_rounded,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 2),
          Text(
            text,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

/// Sectional Score Breakdown Card aligned with Exam History's inset surfaces.
class _SectionalBreakdownCard extends StatelessWidget {
  final SimulationResultAnalytics analytics;
  final int languageScore;
  final int languageTotal;
  final int readingScore;
  final int readingTotal;
  final bool isDark;
  final Color textColor;
  final Color subTextColor;
  final Color primaryColor;
  final Color secondaryColor;
  final Color successColor;
  final Color accentColor;

  const _SectionalBreakdownCard({
    required this.analytics,
    required this.languageScore,
    required this.languageTotal,
    required this.readingScore,
    required this.readingTotal,
    required this.isDark,
    required this.textColor,
    required this.subTextColor,
    required this.primaryColor,
    required this.secondaryColor,
    required this.successColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      borderRadius: AppSpacing.radiusXl,
      borderWidth: 1.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.bar_chart_rounded,
                color: primaryColor,
                size: AppSpacing.lg,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  AppLocalizations.simResultBreakdownTitle().toUpperCase(),
                  style: AppTextStyles.labelMedium.copyWith(
                    color: subTextColor,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SectionScoreTile(
            title: AppLocalizations.simModule1Title(),
            correctCountText: AppLocalizations.simResultCorrectCount(
              languageScore,
              languageTotal,
            ),
            scoreText:
                '${analytics.langPoints} / ${SimulationResultAnalytics.maxLangPoints}',
            progress: analytics.langRatio,
            tag: analytics.langTag,
            icon: Icons.translate_rounded,
            color: primaryColor,
            successColor: successColor,
            accentColor: accentColor,
            textColor: textColor,
            subTextColor: subTextColor,
            isDark: isDark,
          ),
          const SizedBox(height: AppSpacing.sm),
          SectionScoreTile(
            title: AppLocalizations.simModule2Title(),
            correctCountText: AppLocalizations.simResultCorrectCount(
              readingScore,
              readingTotal,
            ),
            scoreText:
                '${analytics.readPoints} / ${SimulationResultAnalytics.maxReadPoints}',
            progress: analytics.readRatio,
            tag: analytics.readTag,
            icon: Icons.menu_book_rounded,
            color: secondaryColor,
            successColor: successColor,
            accentColor: accentColor,
            textColor: textColor,
            subTextColor: subTextColor,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

/// Individual sectional breakdown inset tile with icon, title, right-aligned score,
/// accuracy count + strength/weakness badge row, and progress bar with threshold tick.
class SectionScoreTile extends StatelessWidget {
  final String title;
  final String correctCountText;
  final String scoreText;
  final double progress;
  final SectionStrengthTag tag;
  final IconData icon;
  final Color color;
  final Color successColor;
  final Color accentColor;
  final Color textColor;
  final Color subTextColor;
  final bool isDark;

  const SectionScoreTile({
    super.key,
    required this.title,
    required this.correctCountText,
    required this.scoreText,
    required this.progress,
    required this.tag,
    required this.icon,
    required this.color,
    required this.successColor,
    required this.accentColor,
    required this.textColor,
    required this.subTextColor,
    required this.isDark,
  });

  String _tagLabel() {
    switch (tag) {
      case SectionStrengthTag.strongest:
        return AppLocalizations.simResultTagStrongest();
      case SectionStrengthTag.needsPractice:
        return AppLocalizations.simResultTagNeedsPractice();
      case SectionStrengthTag.balanced:
        return AppLocalizations.simResultTagBalanced();
    }
  }

  Color _tagColor() {
    switch (tag) {
      case SectionStrengthTag.strongest:
        return successColor;
      case SectionStrengthTag.needsPractice:
        return accentColor;
      case SectionStrengthTag.balanced:
        return color;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color badgeColor = _tagColor();
    const double thresholdRatio =
        SimulationResultAnalytics.passTarget / SimulationResultAnalytics.maxScore;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceVariantDark
            : AppColors.surfaceVariantLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Icon + Section Title + Right-aligned Score
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(icon, size: AppSpacing.md, color: color),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                scoreText,
                style: AppTextStyles.titleMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),

          // Row 2: Correct Count (left) + Strength/Focus Badge (right)
          SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xxs,
              children: [
                Text(
                  correctCountText,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: subTextColor,
                  ),
                ),
                AppBadge(
                  label: _tagLabel(),
                  color: badgeColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: 2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Row 3: High-contrast Progress Bar with 44.4% Target Marker
          LayoutBuilder(
            builder: (context, constraints) {
              final double width = constraints.maxWidth.isFinite
                  ? constraints.maxWidth
                  : MediaQuery.of(context).size.width;
              final double markerLeft = (width * thresholdRatio)
                  .clamp(0.0, math.max(0.0, width - 2.0));

              return Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.centerLeft,
                children: [
                  AppProgressBar(
                    progress: progress,
                    height: AppSpacing.xs,
                    color: color,
                    trackColor:
                        isDark ? AppColors.surfaceDark : AppColors.borderLight,
                    semanticLabel: title,
                  ),
                  Positioned(
                    left: markerLeft,
                    top: -2,
                    bottom: -2,
                    child: Container(
                      width: 2.0,
                      decoration: BoxDecoration(
                        color: subTextColor.withValues(alpha: 0.7),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusPill),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Unified 2-column metrics card for Accuracy and Time Spent, matching
/// Exam History's clean inset + divider visual grammar.
class _ReportMetricsCard extends StatelessWidget {
  final String accuracyLabel;
  final String accuracyValue;
  final String accuracySubtitle;
  final String durationLabel;
  final String durationValue;
  final String durationSubtitle;
  final Color primaryColor;
  final Color secondaryColor;
  final Color textColor;
  final Color subTextColor;
  final bool isDark;

  const _ReportMetricsCard({
    required this.accuracyLabel,
    required this.accuracyValue,
    required this.accuracySubtitle,
    required this.durationLabel,
    required this.durationValue,
    required this.durationSubtitle,
    required this.primaryColor,
    required this.secondaryColor,
    required this.textColor,
    required this.subTextColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final Color dividerColor =
        isDark ? AppColors.borderDark : AppColors.borderLight;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppSpacing.radiusXl,
      borderWidth: 1.0,
      child: Row(
        children: [
          Expanded(
            child: _MetricColumnItem(
              label: accuracyLabel,
              value: accuracyValue,
              subtitle: accuracySubtitle,
              icon: Icons.ads_click_rounded,
              accentColor: primaryColor,
              textColor: textColor,
              subTextColor: subTextColor,
            ),
          ),
          Container(
            width: 1,
            height: 52,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            color: dividerColor,
          ),
          Expanded(
            child: _MetricColumnItem(
              label: durationLabel,
              value: durationValue,
              subtitle: durationSubtitle,
              icon: Icons.timer_outlined,
              accentColor: secondaryColor,
              textColor: textColor,
              subTextColor: subTextColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricColumnItem extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Color textColor;
  final Color subTextColor;

  const _MetricColumnItem({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.textColor,
    required this.subTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: accentColor, size: AppSpacing.md),
            const SizedBox(width: AppSpacing.xxs),
            Expanded(
              child: Text(
                label.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelSmall.copyWith(
                  color: subTextColor,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: AppTextStyles.headlineMedium.copyWith(
              color: textColor,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.labelSmall.copyWith(
            color: subTextColor,
          ),
        ),
      ],
    );
  }
}

/// Bottom action bar featuring the single primary 'Review Answers' button.
class ExamActionBar extends StatelessWidget {
  final VoidCallback onReviewAnswers;

  const ExamActionBar({
    super.key,
    required this.onReviewAnswers,
  });

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: AppLocalizations.simResultReviewAnswersCta(),
      icon: Icons.fact_check_rounded,
      onPressed: onReviewAnswers,
    );
  }
}

class _StaggeredSlideFade extends StatelessWidget {
  final AnimationController controller;
  final int stepIndex;
  final bool reduceMotion;
  final Widget child;

  const _StaggeredSlideFade({
    required this.controller,
    required this.stepIndex,
    required this.reduceMotion,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (reduceMotion) return child;

    final double start = (stepIndex * 0.12).clamp(0.0, 0.6);
    final double end = (start + 0.4).clamp(0.2, 1.0);
    final Animation<double> curved = CurvedAnimation(
      parent: controller,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );

    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}
