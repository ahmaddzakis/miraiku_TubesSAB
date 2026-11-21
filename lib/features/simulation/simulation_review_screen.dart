import 'package:flutter/material.dart';
import '../../core/game_manager.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_badge.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_progress_bar.dart';
import '../../data/simulation_data.dart';

class SimulationReviewScreen extends StatefulWidget {
  final List<int?> userAnswers;
  final List<SimulationQuestion>? questions;

  const SimulationReviewScreen({
    super.key,
    required this.userAnswers,
    this.questions,
  });

  @override
  State<SimulationReviewScreen> createState() => _SimulationReviewScreenState();
}

class _SimulationReviewScreenState extends State<SimulationReviewScreen> {
  int _currentIndex = 0;
  late final List<SimulationQuestion> _questions;

  @override
  void initState() {
    super.initState();
    _questions = widget.questions ?? SimulationData.n5Questions;
  }

  String _t(String en, String id) {
    return globalLanguage.value == 'id' ? id : en;
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
        final Color successColor =
            isDark ? AppColors.successDark : AppColors.successLight;
        final Color errorColor =
            isDark ? AppColors.errorDark : AppColors.errorLight;

        final question = _questions[_currentIndex];
        final userAnswer = _currentIndex < widget.userAnswers.length
            ? widget.userAnswers[_currentIndex]
            : null;
        final isCorrect = userAnswer == question.correctAnswerIndex;

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: textColor(isDark),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              _t("Exam Review", "Tinjau Ujian"),
              style: AppTextStyles.titleLarge.copyWith(
                color: textColor(isDark),
                fontWeight: FontWeight.w900,
              ),
            ),
            centerTitle: true,
          ),
          body: Column(
            children: [
              // Progress indicator for review
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: AppProgressBar(
                        progress: (_currentIndex + 1) / _questions.length,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      "${_currentIndex + 1}/${_questions.length}",
                      style: AppTextStyles.labelMedium.copyWith(
                        color: subTextColor(isDark),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Question Card
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AppBadge(
                                  label: question.section.toUpperCase(),
                                  color: accentColor,
                                ),
                                AppBadge(
                                  label: isCorrect
                                      ? _t("CORRECT", "BENAR")
                                      : _t("WRONG", "SALAH"),
                                  color: isCorrect ? successColor : errorColor,
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              question.question,
                              style: AppTextStyles.japaneseTitle.copyWith(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: textColor(isDark),
                                height: 1.4,
                              ),
                            ),
                            if (question.romaji != null) ...[
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                question.romaji!,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: subTextColor(isDark),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                            if (question.subQuestion != null) ...[
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: AppSpacing.md,
                                ),
                                child: Divider(),
                              ),
                              Text(
                                question.subQuestion!,
                                style: AppTextStyles.japaneseBody.copyWith(
                                  color: textColor(isDark).withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Options
                      ...List.generate(question.options.length, (index) {
                        final isCorrectOption =
                            index == question.correctAnswerIndex;
                        final isUserSelected = index == userAnswer;

                        Color optionBorderColor = isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight;
                        Color optionBgColor = cardColor;
                        IconData? icon;
                        Color? iconColor;

                        if (isCorrectOption) {
                          optionBorderColor = successColor;
                          optionBgColor = isDark
                              ? AppColors.successContainerDark
                              : AppColors.successContainerLight;
                          icon = Icons.check_circle_rounded;
                          iconColor = successColor;
                        } else if (isUserSelected && !isCorrectOption) {
                          optionBorderColor = errorColor;
                          optionBgColor = isDark
                              ? AppColors.errorContainerDark
                              : AppColors.errorContainerLight;
                          icon = Icons.cancel_rounded;
                          iconColor = errorColor;
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: optionBgColor,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusMd),
                            border: Border.all(
                              color: optionBorderColor,
                              width: (isCorrectOption || isUserSelected) ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.surfaceVariantDark
                                      : AppColors.surfaceVariantLight,
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.xs,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    String.fromCharCode(65 + index),
                                    style: AppTextStyles.labelLarge.copyWith(
                                      color: subTextColor(isDark),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Text(
                                  question.options[index],
                                  style: AppTextStyles.japaneseBody.copyWith(
                                    fontSize: 16,
                                    fontWeight:
                                        (isCorrectOption || isUserSelected)
                                            ? FontWeight.w800
                                            : FontWeight.w500,
                                    color: textColor(isDark),
                                  ),
                                ),
                              ),
                              if (icon != null)
                                Icon(icon, color: iconColor, size: 24),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: AppSpacing.sm),

                      // Explanation
                      if (question.explanationId != null ||
                          question.explanationEn != null) ...[
                        Text(
                          _t("EXPLANATION", "PENJELASAN"),
                          style: AppTextStyles.labelSmall.copyWith(
                            color: subTextColor(isDark),
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.08),
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusLg),
                            border: Border.all(
                              color: accentColor.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Text(
                            (globalLanguage.value == 'id'
                                    ? question.explanationId
                                    : question.explanationEn) ??
                                question.explanationId ??
                                "",
                            style: AppTextStyles.bodyMedium.copyWith(
                              height: 1.6,
                              color: textColor(isDark),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xxxl),
                    ],
                  ),
                ),
              ),

              // Navigation Buttons
              Container(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.md,
                  AppSpacing.xl,
                  MediaQuery.of(context).padding.bottom + AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: cardColor,
                  border: Border(
                    top: BorderSide(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    if (_currentIndex > 0) ...[
                      Expanded(
                        child: AppButton(
                          label: _t("PREVIOUS", "SEBELUMNYA"),
                          variant: AppButtonVariant.secondary,
                          onPressed: () => setState(() => _currentIndex--),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                    ],
                    Expanded(
                      child: AppButton(
                        label: _currentIndex < _questions.length - 1
                            ? _t("NEXT", "SELANJUTNYA")
                            : _t("DONE", "SELESAI"),
                        onPressed: _currentIndex < _questions.length - 1
                            ? () => setState(() => _currentIndex++)
                            : () => Navigator.pop(context),
                      ),
                    ),
                  ],
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
}
