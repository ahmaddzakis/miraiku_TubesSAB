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
import 'simulation_result_screen.dart';

/// Performance level tier replacing raw letter grades in the summary dashboard.
enum SimulationPerformanceTier {
  mastery,
  ready,
  passed,
  almost,
  practice,
}

/// Date grouping bucket for exam history list headers.
enum SimulationDateGroup {
  today,
  yesterday,
  thisWeek,
  earlier,
}

/// Pure, testable analytics model computed from [globalSimulationHistory].
class SimulationHistoryEntry {
  final Map<String, dynamic> rawItem;
  final DateTime date;
  final int score;
  final bool isPassed;
  final int langPoints;
  final int readPoints;
  final int timeSpentSeconds;
  final int? scoreDelta;
  final bool isBestSession;
  final SimulationDateGroup dateGroup;

  const SimulationHistoryEntry({
    required this.rawItem,
    required this.date,
    required this.score,
    required this.isPassed,
    required this.langPoints,
    required this.readPoints,
    required this.timeSpentSeconds,
    required this.scoreDelta,
    required this.isBestSession,
    required this.dateGroup,
  });
}

/// Pure helper class for computing derived exam history metrics (best session,
/// gap to pass target 80, score deltas between sessions, and date grouping).
class SimulationHistoryAnalytics {
  static const int maxScore = 180;
  static const int passTarget = 80;
  static const int maxLangPoints = 60;
  static const int maxReadPoints = 120;

  final int totalAttempts;
  final int bestScore;
  final int passRate;
  final int gapToPass;
  final SimulationPerformanceTier performanceTier;
  final List<int> chronologicalScores;
  final List<SimulationHistoryEntry> entriesNewestFirst;

  const SimulationHistoryAnalytics({
    required this.totalAttempts,
    required this.bestScore,
    required this.passRate,
    required this.gapToPass,
    required this.performanceTier,
    required this.chronologicalScores,
    required this.entriesNewestFirst,
  });

  /// Calculates remaining points needed to reach the 80-point passing mark.
  static int computeGapToPass(num bestScore) {
    final int rounded = bestScore.round().clamp(0, maxScore);
    return math.max(0, passTarget - rounded);
  }

  /// Resolves supportive performance tier from best score (0..180).
  static SimulationPerformanceTier resolveTier(num score) {
    final int pts = score.round();
    if (pts >= 144) return SimulationPerformanceTier.mastery;
    if (pts >= 110) return SimulationPerformanceTier.ready;
    if (pts >= passTarget) return SimulationPerformanceTier.passed;
    if (pts >= 50) return SimulationPerformanceTier.almost;
    return SimulationPerformanceTier.practice;
  }

  /// Classifies a session timestamp relative to [referenceNow].
  static SimulationDateGroup classifyDateGroup(
    DateTime date,
    DateTime referenceNow,
  ) {
    final DateTime todayStart = DateTime(
      referenceNow.year,
      referenceNow.month,
      referenceNow.day,
    );
    final DateTime itemDay = DateTime(date.year, date.month, date.day);
    final int dayDiff = todayStart.difference(itemDay).inDays;

    if (dayDiff <= 0) return SimulationDateGroup.today;
    if (dayDiff == 1) return SimulationDateGroup.yesterday;
    if (dayDiff < 7) return SimulationDateGroup.thisWeek;
    return SimulationDateGroup.earlier;
  }

  /// Builds full analytics from raw history maps without mutating the source list.
  static SimulationHistoryAnalytics fromRawList(
    List<dynamic> rawHistory, {
    DateTime? now,
  }) {
    final DateTime referenceNow = now ?? DateTime.now();
    if (rawHistory.isEmpty) {
      return const SimulationHistoryAnalytics(
        totalAttempts: 0,
        bestScore: 0,
        passRate: 0,
        gapToPass: passTarget,
        performanceTier: SimulationPerformanceTier.practice,
        chronologicalScores: [],
        entriesNewestFirst: [],
      );
    }

    final List<Map<String, dynamic>> sortedNewestFirst = rawHistory
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

    int passCount = 0;
    int bestScore = 0;
    int bestIndexNewestFirst = 0;

    final List<int> scoresNewestFirst = [];
    for (int i = 0; i < sortedNewestFirst.length; i++) {
      final item = sortedNewestFirst[i];
      final int score =
          ((item['totalPoints'] as num?) ?? 0).round().clamp(0, maxScore);
      final bool passed = (item['isPassed'] as bool?) ?? (score >= passTarget);
      if (passed) passCount++;
      scoresNewestFirst.add(score);
      // Tie-breaker: the newest session with the highest score is marked as best
      if (score > bestScore || (i == 0 && bestScore == 0)) {
        bestScore = score;
        bestIndexNewestFirst = i;
      }
    }

    final int totalAttempts = sortedNewestFirst.length;
    final int passRate =
        totalAttempts > 0 ? ((passCount / totalAttempts) * 100).round() : 0;

    final List<SimulationHistoryEntry> entries = [];
    for (int i = 0; i < totalAttempts; i++) {
      final item = sortedNewestFirst[i];
      final DateTime date =
          DateTime.tryParse('${item['date']}') ?? referenceNow;
      final int score = scoresNewestFirst[i];
      final bool passed = (item['isPassed'] as bool?) ?? (score >= passTarget);

      final int langScore = (item['languageScore'] as num?)?.toInt() ?? 0;
      final int langTotal = (item['languageTotal'] as num?)?.toInt() ?? 0;
      final int readScore = (item['readingScore'] as num?)?.toInt() ?? 0;
      final int readTotal = (item['readingTotal'] as num?)?.toInt() ?? 0;
      final int timeSpent = (item['timeSpentSeconds'] as num?)?.toInt() ?? 0;

      final int langPoints = langTotal > 0
          ? ((langScore / langTotal) * maxLangPoints)
              .round()
              .clamp(0, maxLangPoints)
          : 0;
      final int readPoints = readTotal > 0
          ? ((readScore / readTotal) * maxReadPoints)
              .round()
              .clamp(0, maxReadPoints)
          : 0;

      // Chronologically previous session is at index i + 1
      final int? delta =
          (i + 1 < totalAttempts) ? (score - scoresNewestFirst[i + 1]) : null;

      entries.add(
        SimulationHistoryEntry(
          rawItem: item,
          date: date,
          score: score,
          isPassed: passed,
          langPoints: langPoints,
          readPoints: readPoints,
          timeSpentSeconds: timeSpent,
          scoreDelta: delta,
          isBestSession: i == bestIndexNewestFirst && bestScore > 0,
          dateGroup: classifyDateGroup(date, referenceNow),
        ),
      );
    }

    final List<int> chronologicalScores =
        scoresNewestFirst.reversed.toList(growable: false);

    return SimulationHistoryAnalytics(
      totalAttempts: totalAttempts,
      bestScore: bestScore,
      passRate: passRate,
      gapToPass: computeGapToPass(bestScore),
      performanceTier: resolveTier(bestScore),
      chronologicalScores: chronologicalScores,
      entriesNewestFirst: entries,
    );
  }
}

class SimulationHistoryScreen extends StatefulWidget {
  const SimulationHistoryScreen({super.key});

  @override
  State<SimulationHistoryScreen> createState() =>
      _SimulationHistoryScreenState();
}

class _SimulationHistoryScreenState extends State<SimulationHistoryScreen>
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

  String _formatDate(DateTime date) {
    const List<String> monthsEn = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    const List<String> monthsId = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final List<String> months = AppLocalizations.isId ? monthsId : monthsEn;
    final String month = months[(date.month - 1).clamp(0, 11)];
    final String hour = date.hour.toString().padLeft(2, '0');
    final String minute = date.minute.toString().padLeft(2, '0');
    return '${date.day} $month ${date.year} • $hour:$minute';
  }

  String _formatDuration(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes}m ${remainingSeconds}s';
  }

  String _groupLabel(SimulationDateGroup group) {
    switch (group) {
      case SimulationDateGroup.today:
        return AppLocalizations.simHistoryGroupToday();
      case SimulationDateGroup.yesterday:
        return AppLocalizations.simHistoryGroupYesterday();
      case SimulationDateGroup.thisWeek:
        return AppLocalizations.simHistoryGroupThisWeek();
      case SimulationDateGroup.earlier:
        return AppLocalizations.simHistoryGroupEarlier();
    }
  }

  void _navigateToDetails(SimulationHistoryEntry entry) {
    final item = entry.rawItem;
    List<SimulationQuestion>? reconstructedQuestions;
    if (item['questionIndices'] != null) {
      final indices = List<int>.from(item['questionIndices']);
      final all = SimulationData.n5Questions;
      if (indices.every((i) => i >= 0 && i < all.length)) {
        reconstructedQuestions = indices.map((i) => all[i]).toList();
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SimulationResultScreen(
          languageScore: (item['languageScore'] as num?)?.toInt() ?? 0,
          languageTotal: (item['languageTotal'] as num?)?.toInt() ?? 0,
          readingScore: (item['readingScore'] as num?)?.toInt() ?? 0,
          readingTotal: (item['readingTotal'] as num?)?.toInt() ?? 0,
          timeSpentSeconds: entry.timeSpentSeconds,
          totalPoints: entry.score.toDouble(),
          isPassed: entry.isPassed,
          userAnswers: item['userAnswers'] != null
              ? List<int?>.from(item['userAnswers'])
              : List.filled(SimulationData.n5Questions.length, null),
          questions: reconstructedQuestions,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool reduceMotion = MediaQuery.disableAnimationsOf(context);

    return ValueListenableBuilder<String>(
      valueListenable: globalLanguage,
      builder: (context, lang, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: globalDarkMode,
          builder: (context, isDark, _) {
            final Color bgColor =
                isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
            final Color textColor =
                isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
            final Color subTextColor = isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight;
            final Color primaryColor =
                isDark ? AppColors.primaryDark : AppColors.primaryLight;

            return Scaffold(
              backgroundColor: bgColor,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: Semantics(
                  button: true,
                  label: AppLocalizations.simHistoryBackSemantics(),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: textColor,
                      size: AppSpacing.lg,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                title: Text(
                  AppLocalizations.simHistoryAppBarTitle(),
                  style: AppTextStyles.titleLarge.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                ),
                centerTitle: true,
              ),
              body: ValueListenableBuilder<List<dynamic>>(
                valueListenable: globalSimulationHistory,
                builder: (context, historyList, _) {
                  if (historyList.isEmpty) {
                    return _HistoryEmptyState(
                      isDark: isDark,
                      textColor: textColor,
                      subTextColor: subTextColor,
                      primaryColor: primaryColor,
                      onStartSimulation: () => Navigator.pop(context),
                    );
                  }

                  final analytics =
                      SimulationHistoryAnalytics.fromRawList(historyList);
                  final entries = analytics.entriesNewestFirst;
                  final bool showDateGroups = entries.length >= 2;

                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: AppSpacing.maxContentWidth,
                      ),
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                          vertical: AppSpacing.md,
                        ),
                        itemCount: entries.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.lg,
                              ),
                              child: _StaggeredAppear(
                                controller: _entryController,
                                stepIndex: 0,
                                reduceMotion: reduceMotion,
                                child: PerformanceSummaryCard(
                                  analytics: analytics,
                                  isDark: isDark,
                                  textColor: textColor,
                                  subTextColor: subTextColor,
                                  primaryColor: primaryColor,
                                ),
                              ),
                            );
                          }

                          final int entryIndex = index - 1;
                          final entry = entries[entryIndex];
                          final bool isFirstInGroup = showDateGroups &&
                              (entryIndex == 0 ||
                                  entries[entryIndex - 1].dateGroup !=
                                      entry.dateGroup);

                          return _StaggeredAppear(
                            controller: _entryController,
                            stepIndex: (index).clamp(0, 6),
                            reduceMotion: reduceMotion,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (isFirstInGroup)
                                  Padding(
                                    padding: EdgeInsets.only(
                                      top: entryIndex == 0
                                          ? AppSpacing.xs
                                          : AppSpacing.md,
                                      bottom: AppSpacing.sm,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today_rounded,
                                          size: 14,
                                          color: primaryColor,
                                        ),
                                        const SizedBox(width: AppSpacing.xs),
                                        Text(
                                          _groupLabel(entry.dateGroup)
                                              .toUpperCase(),
                                          style:
                                              AppTextStyles.labelMedium.copyWith(
                                            color: subTextColor,
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.sm),
                                        Expanded(
                                          child: Divider(
                                            height: 1,
                                            color: isDark
                                                ? AppColors.borderDark
                                                : AppColors.borderLight,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ExamHistoryTile(
                                  entry: entry,
                                  formattedDate: _formatDate(entry.date),
                                  formattedDuration: entry.timeSpentSeconds > 0
                                      ? _formatDuration(entry.timeSpentSeconds)
                                      : null,
                                  isDark: isDark,
                                  textColor: textColor,
                                  subTextColor: subTextColor,
                                  primaryColor: primaryColor,
                                  onTap: () => _navigateToDetails(entry),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

/// Top Hero Performance Summary Card with Best Score target bar, a single
/// completed sessions stat box, supportive performance tier badge, and
/// contextual Octalysis motivation.
class PerformanceSummaryCard extends StatelessWidget {
  final SimulationHistoryAnalytics analytics;
  final bool isDark;
  final Color textColor;
  final Color subTextColor;
  final Color primaryColor;

  const PerformanceSummaryCard({
    super.key,
    required this.analytics,
    required this.isDark,
    required this.textColor,
    required this.subTextColor,
    required this.primaryColor,
  });

  String _tierLabel(SimulationPerformanceTier tier) {
    switch (tier) {
      case SimulationPerformanceTier.mastery:
        return AppLocalizations.simHistoryLevelMastery();
      case SimulationPerformanceTier.ready:
        return AppLocalizations.simHistoryLevelReady();
      case SimulationPerformanceTier.passed:
        return AppLocalizations.simHistoryLevelPassed();
      case SimulationPerformanceTier.almost:
        return AppLocalizations.simHistoryLevelAlmost();
      case SimulationPerformanceTier.practice:
        return AppLocalizations.simHistoryLevelPractice();
    }
  }

  IconData _tierIcon(SimulationPerformanceTier tier) {
    switch (tier) {
      case SimulationPerformanceTier.mastery:
        return Icons.workspace_premium_rounded;
      case SimulationPerformanceTier.ready:
      case SimulationPerformanceTier.passed:
        return Icons.verified_rounded;
      case SimulationPerformanceTier.almost:
        return Icons.trending_up_rounded;
      case SimulationPerformanceTier.practice:
        return Icons.auto_awesome_rounded;
    }
  }

  Color _tierColor(SimulationPerformanceTier tier) {
    switch (tier) {
      case SimulationPerformanceTier.mastery:
      case SimulationPerformanceTier.passed:
        return isDark ? AppColors.successDark : AppColors.successLight;
      case SimulationPerformanceTier.ready:
        return isDark ? AppColors.secondaryDark : AppColors.secondaryLight;
      case SimulationPerformanceTier.almost:
        return isDark ? AppColors.accentDark : AppColors.accentLight;
      case SimulationPerformanceTier.practice:
        return primaryColor;
    }
  }

  String _motivationText() {
    if (analytics.gapToPass <= 0) {
      return AppLocalizations.simHistoryMotivationPassed();
    }
    if (analytics.bestScore >= 50) {
      return AppLocalizations.simHistoryMotivationAlmost(analytics.gapToPass);
    }
    return AppLocalizations.simHistoryMotivationPractice(analytics.gapToPass);
  }

  @override
  Widget build(BuildContext context) {
    final Color successColor =
        isDark ? AppColors.successDark : AppColors.successLight;
    final Color secondaryColor =
        isDark ? AppColors.secondaryDark : AppColors.secondaryLight;
    final Color accentColor =
        isDark ? AppColors.accentDark : AppColors.accentLight;
    final Color tierColor = _tierColor(analytics.performanceTier);
    final bool hasPassedBest =
        analytics.bestScore >= SimulationHistoryAnalytics.passTarget;
    final Color heroProgressColor = hasPassedBest ? successColor : primaryColor;
    final Color cardTint = isDark
        ? AppColors.primaryContainerDark.withValues(alpha: 0.24)
        : AppColors.primaryContainerLight.withValues(alpha: 0.42);
    final Color surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cardTint, surfaceColor],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: AppShadows.card(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Row: Summary Label + Supportive Performance Tier Badge
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
                      Icons.insights_rounded,
                      color: primaryColor,
                      size: AppSpacing.lg,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Flexible(
                      child: Text(
                        AppLocalizations.simHistorySummaryHeader(),
                        style: AppTextStyles.labelMedium.copyWith(
                          color: subTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
                AppBadge(
                  label: _tierLabel(analytics.performanceTier),
                  icon: _tierIcon(analytics.performanceTier),
                  color: tierColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // 2. Hero Best Score + Target 80 Marker Bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceVariantDark.withValues(alpha: 0.75)
                  : AppColors.surfaceLight.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(
                color: heroProgressColor.withValues(alpha: 0.25),
              ),
            ),
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.simHistoryBestScoreLabel(),
                            style: AppTextStyles.labelSmall.copyWith(
                              color: subTextColor,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '${analytics.bestScore}',
                                style: AppTextStyles.displayMedium.copyWith(
                                  color: heroProgressColor,
                                ),
                              ),
                              Text(
                                ' / ${SimulationHistoryAnalytics.maxScore}',
                                style: AppTextStyles.titleLarge.copyWith(
                                  color: subTextColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      AppBadge(
                        label: hasPassedBest
                            ? AppLocalizations.simHistoryTargetReached()
                            : AppLocalizations.simHistoryGapToPass(
                                analytics.gapToPass,
                              ),
                        icon: hasPassedBest
                            ? Icons.check_circle_rounded
                            : Icons.flag_rounded,
                        color: hasPassedBest ? successColor : accentColor,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _TargetMarkerProgressBar(
                  score: analytics.bestScore,
                  maxScore: SimulationHistoryAnalytics.maxScore,
                  passTarget: SimulationHistoryAnalytics.passTarget,
                  activeColor: heroProgressColor,
                  isDark: isDark,
                  subTextColor: subTextColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // 3. Single Completed Sessions Stat Column
          _CompactSummaryStatBox(
            icon: Icons.assignment_turned_in_rounded,
            iconColor: secondaryColor,
            value: '${analytics.totalAttempts}',
            label: AppLocalizations.simHistoryStatDone(),
            valueColor: textColor,
            subTextColor: subTextColor,
            isDark: isDark,
          ),
          const SizedBox(height: AppSpacing.md),

          // 4. Octalysis Motivation Message
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceVariantDark
                  : AppColors.surfaceVariantLight,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Row(
              children: [
                Icon(
                  hasPassedBest
                      ? Icons.auto_awesome_rounded
                      : Icons.rocket_launch_rounded,
                  size: AppSpacing.lg,
                  color: heroProgressColor,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    _motivationText(),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                    ),
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

/// Progress bar with a visual vertical marker at the 80/180 passing score threshold.
class _TargetMarkerProgressBar extends StatelessWidget {
  final int score;
  final int maxScore;
  final int passTarget;
  final Color activeColor;
  final bool isDark;
  final Color subTextColor;

  const _TargetMarkerProgressBar({
    required this.score,
    required this.maxScore,
    required this.passTarget,
    required this.activeColor,
    required this.isDark,
    required this.subTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = (score / maxScore).clamp(0.0, 1.0);
    final double targetRatio = (passTarget / maxScore).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final double width = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : MediaQuery.of(context).size.width;
            final double markerLeft =
                (width * targetRatio).clamp(0.0, math.max(0.0, width - 2.0));

            return Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.centerLeft,
              children: [
                AppProgressBar(
                  progress: progress,
                  height: AppSpacing.xs,
                  color: activeColor,
                  semanticLabel: AppLocalizations.simBestScoreSemantics(),
                ),
                Positioned(
                  left: markerLeft,
                  top: -2,
                  bottom: -2,
                  child: Container(
                    width: 2.5,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusPill),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: AppSpacing.xxs),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '0',
              style: AppTextStyles.labelSmall.copyWith(color: subTextColor),
            ),
            Text(
              AppLocalizations.simHistoryTargetMarkerLabel(),
              style: AppTextStyles.labelSmall.copyWith(color: subTextColor),
            ),
            Text(
              '$maxScore',
              style: AppTextStyles.labelSmall.copyWith(color: subTextColor),
            ),
          ],
        ),
      ],
    );
  }
}

/// Full-width stat row for completed exam count.
class _CompactSummaryStatBox extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final Color valueColor;
  final Color subTextColor;
  final bool isDark;

  const _CompactSummaryStatBox({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.valueColor,
    required this.subTextColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceVariantDark
            : AppColors.surfaceVariantLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(icon, size: AppSpacing.md, color: iconColor),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: AppTextStyles.labelLarge.copyWith(
                  color: subTextColor,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: AppTextStyles.titleLarge.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

/// Scannable exam history tile with a clear single hierarchy:
/// - Large score (`63 / 180`), delta chip (`+9` / `-15`), best session crown badge
/// - Status badge (`LULUS` green or `BELUM LULUS` warm terracotta/amber — no harsh red wall)
/// - Date/time & duration subtitle row
/// - Two compact labeled progress bars for Language (`60`) and Reading (`120`)
class ExamHistoryTile extends StatelessWidget {
  final SimulationHistoryEntry entry;
  final String formattedDate;
  final String? formattedDuration;
  final bool isDark;
  final Color textColor;
  final Color subTextColor;
  final Color primaryColor;
  final VoidCallback onTap;

  const ExamHistoryTile({
    super.key,
    required this.entry,
    required this.formattedDate,
    required this.formattedDuration,
    required this.isDark,
    required this.textColor,
    required this.subTextColor,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color successColor =
        isDark ? AppColors.successDark : AppColors.successLight;
    final Color secondaryColor =
        isDark ? AppColors.secondaryDark : AppColors.secondaryLight;
    final Color accentColor =
        isDark ? AppColors.accentDark : AppColors.accentLight;
    final Color statusColor = entry.isPassed ? successColor : primaryColor;
    final String statusLabel = entry.isPassed
        ? AppLocalizations.simHistoryStatusPassed()
        : AppLocalizations.simHistoryStatusNotPassed();
    final Color insetBg = isDark
        ? AppColors.surfaceVariantDark
        : AppColors.surfaceVariantLight;
    final Color borderColor =
        isDark ? AppColors.borderDark : AppColors.borderLight;

    return Semantics(
      button: true,
      label: AppLocalizations.simHistoryTileSemantics(
        entry.score,
        statusLabel,
        formattedDate,
      ),
      child: AppCard(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        borderWidth: 1.0,
        borderColor: entry.isBestSession
            ? accentColor.withValues(alpha: 0.45)
            : borderColor,
        borderRadius: AppSpacing.radiusXl,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Top Row: Score + Delta/Best on left, Status Badge + Chevron on right
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: AppSpacing.xs,
                          runSpacing: AppSpacing.xxs,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '${entry.score}',
                                  style: AppTextStyles.headlineLarge.copyWith(
                                    color: statusColor,
                                  ),
                                ),
                                Text(
                                  ' / ${SimulationHistoryAnalytics.maxScore}',
                                  style: AppTextStyles.titleMedium.copyWith(
                                    color: subTextColor,
                                  ),
                                ),
                              ],
                            ),
                            if (entry.scoreDelta != null &&
                                entry.scoreDelta != 0)
                              _ScoreDeltaChip(
                                delta: entry.scoreDelta!,
                                successColor: successColor,
                                accentColor: accentColor,
                              ),
                            if (entry.isBestSession)
                              AppBadge(
                                label: AppLocalizations
                                    .simHistoryBestSessionBadge(),
                                icon: Icons.emoji_events_rounded,
                                color: accentColor,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.xs,
                                  vertical: AppSpacing.xxs,
                                ),
                              ),
                          ],
                        ),
                        AppBadge(
                          label: statusLabel,
                          color: statusColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xxs,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Icon(
                  Icons.chevron_right_rounded,
                  size: AppSpacing.lg,
                  color: subTextColor,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),

            // 2. Clean Metadata Row: Date/Time + Duration
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xxs,
              children: [
                Text(
                  formattedDate,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: subTextColor,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                if (formattedDuration != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 14,
                        color: subTextColor,
                      ),
                      const SizedBox(width: AppSpacing.xxs),
                      Text(
                        formattedDuration!,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: subTextColor,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // 3. Inset Section Breakdown Box (matches PerformanceSummaryCard inner blocks)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: insetBg,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _SectionMiniBar(
                      label: AppLocalizations.simHistoryLangBarLabel(
                        entry.langPoints,
                      ),
                      progress: entry.langPoints /
                          SimulationHistoryAnalytics.maxLangPoints,
                      color: primaryColor,
                      subTextColor: subTextColor,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: AppSpacing.xl,
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    color: borderColor,
                  ),
                  Expanded(
                    child: _SectionMiniBar(
                      label: AppLocalizations.simHistoryReadBarLabel(
                        entry.readPoints,
                      ),
                      progress: entry.readPoints /
                          SimulationHistoryAnalytics.maxReadPoints,
                      color: secondaryColor,
                      subTextColor: subTextColor,
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
}

class _ScoreDeltaChip extends StatelessWidget {
  final int delta;
  final Color successColor;
  final Color accentColor;

  const _ScoreDeltaChip({
    required this.delta,
    required this.successColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPositive = delta > 0;
    final Color chipColor = isPositive ? successColor : accentColor;
    final String text = isPositive ? '+$delta' : '$delta';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.14),
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
            color: chipColor,
          ),
          const SizedBox(width: 2),
          Text(
            text,
            style: AppTextStyles.labelSmall.copyWith(
              color: chipColor,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionMiniBar extends StatelessWidget {
  final String label;
  final double progress;
  final Color color;
  final Color subTextColor;

  const _SectionMiniBar({
    required this.label,
    required this.progress,
    required this.color,
    required this.subTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.labelSmall.copyWith(
            color: subTextColor,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        AppProgressBar(
          progress: progress,
          height: 6.0,
          color: color,
          trackColor: isDark ? AppColors.surfaceDark : AppColors.borderLight,
          semanticLabel: label,
        ),
      ],
    );
  }
}

class _HistoryEmptyState extends StatelessWidget {
  final bool isDark;
  final Color textColor;
  final Color subTextColor;
  final Color primaryColor;
  final VoidCallback onStartSimulation;

  const _HistoryEmptyState({
    required this.isDark,
    required this.textColor,
    required this.subTextColor,
    required this.primaryColor,
    required this.onStartSimulation,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: AppCard(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            borderWidth: 1.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const RoundedMochiAsset(
                  assetPath: 'assets/images/mochi_semangat.png',
                  size: 120,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  AppLocalizations.simHistoryEmptyTitle(),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: textColor,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  AppLocalizations.simHistoryEmptySubtitle(),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: subTextColor,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  label: AppLocalizations.simHistoryStartSimulationCta(),
                  icon: Icons.play_arrow_rounded,
                  onPressed: onStartSimulation,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StaggeredAppear extends StatelessWidget {
  final AnimationController controller;
  final int stepIndex;
  final bool reduceMotion;
  final Widget child;

  const _StaggeredAppear({
    required this.controller,
    required this.stepIndex,
    required this.reduceMotion,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (reduceMotion) return child;

    final double start = (stepIndex * 0.1).clamp(0.0, 0.6);
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
