import 'package:flutter/material.dart';
import '../../core/game_manager.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_card.dart';
import '../../data/simulation_data.dart';
import 'simulation_result_screen.dart';

class SimulationHistoryScreen extends StatefulWidget {
  const SimulationHistoryScreen({super.key});

  @override
  State<SimulationHistoryScreen> createState() =>
      _SimulationHistoryScreenState();
}

class _SimulationHistoryScreenState extends State<SimulationHistoryScreen> {
  String _t(String en, String id) {
    return globalLanguage.value == 'id' ? id : en;
  }

  @override
  Widget build(BuildContext context) {
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

            return Scaffold(
              backgroundColor: bgColor,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: textColor,
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  _t("EXAM HISTORY", "RIWAYAT UJIAN"),
                  style: AppTextStyles.titleLarge.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                centerTitle: true,
              ),
              body: ValueListenableBuilder<List<dynamic>>(
                valueListenable: globalSimulationHistory,
                builder: (context, historyList, _) {
                  if (historyList.isEmpty) {
                    return _buildEmptyState(textColor);
                  }

                  final sortedHistory = List.from(historyList);
                  sortedHistory.sort(
                    (a, b) => DateTime.parse(b['date'])
                        .compareTo(DateTime.parse(a['date'])),
                  );

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.md,
                    ),
                    itemCount: sortedHistory.length,
                    itemBuilder: (context, index) {
                      final item = sortedHistory[index];
                      final date = DateTime.parse(item['date']);
                      final bool passed = item['isPassed'] ?? false;
                      final double score =
                          (item['totalPoints'] as num).toDouble();

                      return _buildHistoryItem(
                        item,
                        date,
                        passed,
                        score,
                        isDark,
                        textColor,
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

  Widget _buildEmptyState(Color textColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_rounded,
            size: 80,
            color: textColor.withValues(alpha: 0.12),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _t("No history available", "Belum ada riwayat"),
            style: AppTextStyles.bodyLarge.copyWith(
              color: textColor.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(
    dynamic item,
    DateTime date,
    bool passed,
    double score,
    bool isDark,
    Color textColor,
  ) {
    final statusColor = passed
        ? (isDark ? AppColors.successDark : AppColors.successLight)
        : (isDark ? AppColors.errorDark : AppColors.errorLight);

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: AppSpacing.radiusLg,
      onTap: () => _navigateToDetails(item, score, passed),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              passed ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: statusColor,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${date.day}/${date.month}/${date.year} - ${date.hour}:${date.minute.toString().padLeft(2, '0')}",
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w900,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _t(
                    "Score: ${score.toInt()}/180",
                    "Skor: ${score.toInt()}/180",
                  ),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: textColor.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  void _navigateToDetails(dynamic item, double score, bool passed) {
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
          languageScore: item['languageScore'],
          languageTotal: item['languageTotal'],
          readingScore: item['readingScore'],
          readingTotal: item['readingTotal'],
          timeSpentSeconds: item['timeSpentSeconds'],
          totalPoints: score,
          isPassed: passed,
          userAnswers: item['userAnswers'] != null
              ? List<int?>.from(item['userAnswers'])
              : List.filled(SimulationData.n5Questions.length, null),
          questions: reconstructedQuestions,
        ),
      ),
    );
  }
}
