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
import '../../data/simulation_data.dart';
import 'widgets/exam_shared_widgets.dart';

enum _ReviewFilter { all, wrong, correct }

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
  int _filteredCursor = 0;
  _ReviewFilter _activeFilter = _ReviewFilter.all;
  late final List<SimulationQuestion> _questions;

  @override
  void initState() {
    super.initState();
    _questions = widget.questions ?? SimulationData.n5Questions;
  }

  bool _isQuestionCorrect(int originalIndex) {
    final userAnswer = originalIndex < widget.userAnswers.length
        ? widget.userAnswers[originalIndex]
        : null;
    return userAnswer == _questions[originalIndex].correctAnswerIndex;
  }

  List<int> get _filteredIndices {
    final List<int> indices = [];
    for (int i = 0; i < _questions.length; i++) {
      final bool correct = _isQuestionCorrect(i);
      if (_activeFilter == _ReviewFilter.all ||
          (_activeFilter == _ReviewFilter.correct && correct) ||
          (_activeFilter == _ReviewFilter.wrong && !correct)) {
        indices.add(i);
      }
    }
    return indices;
  }

  void _setFilter(_ReviewFilter filter) {
    if (_activeFilter == filter) return;
    setState(() {
      _activeFilter = filter;
      _filteredCursor = 0;
    });
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
            final Color cardColor =
                isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
            final Color primaryColor =
                isDark ? AppColors.primaryDark : AppColors.primaryLight;
            final Color secondaryColor =
                isDark ? AppColors.secondaryDark : AppColors.secondaryLight;
            final Color successColor =
                isDark ? AppColors.successDark : AppColors.successLight;
            final Color errorColor =
                isDark ? AppColors.errorDark : AppColors.errorLight;

            int totalCorrect = 0;
            for (int i = 0; i < _questions.length; i++) {
              if (_isQuestionCorrect(i)) totalCorrect++;
            }
            final int totalWrong = _questions.length - totalCorrect;

            final List<int> visibleIndices = _filteredIndices;
            final int safeCursor = visibleIndices.isEmpty
                ? 0
                : _filteredCursor.clamp(0, visibleIndices.length - 1);

            return Scaffold(
              backgroundColor: bgColor,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: Semantics(
                  button: true,
                  label: AppLocalizations.simReviewBackSemantics(),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: _textColor(isDark),
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                title: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    AppLocalizations.simReviewAppBarTitle(),
                    style: AppTextStyles.titleLarge.copyWith(
                      color: _textColor(isDark),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                centerTitle: true,
              ),
              body: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppSpacing.maxContentWidth,
                  ),
                  child: Column(
                    children: [
                      // 1. Filter Chips & Horizontal Question Number Strip
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                          vertical: AppSpacing.xs,
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildFilterChip(
                                    label: AppLocalizations.simReviewFilterAll(
                                      _questions.length,
                                    ),
                                    isSelected:
                                        _activeFilter == _ReviewFilter.all,
                                    activeColor: primaryColor,
                                    isDark: isDark,
                                    onTap: () => _setFilter(_ReviewFilter.all),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Expanded(
                                  child: _buildFilterChip(
                                    label:
                                        AppLocalizations.simReviewFilterWrong(
                                      totalWrong,
                                    ),
                                    isSelected:
                                        _activeFilter == _ReviewFilter.wrong,
                                    activeColor: errorColor,
                                    isDark: isDark,
                                    onTap: () =>
                                        _setFilter(_ReviewFilter.wrong),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Expanded(
                                  child: _buildFilterChip(
                                    label:
                                        AppLocalizations.simReviewFilterCorrect(
                                      totalCorrect,
                                    ),
                                    isSelected:
                                        _activeFilter == _ReviewFilter.correct,
                                    activeColor: successColor,
                                    isDark: isDark,
                                    onTap: () =>
                                        _setFilter(_ReviewFilter.correct),
                                  ),
                                ),
                              ],
                            ),
                            if (visibleIndices.isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.sm),
                              ExamProgressHeader(
                                current: safeCursor + 1,
                                total: visibleIndices.length,
                                color: primaryColor,
                                subTextColor: _subTextColor(isDark),
                                semanticLabel: AppLocalizations
                                    .simReviewProgressSemantics(),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              QuestionNumberStrip(
                                mode: ExamDisplayMode.review,
                                itemNumbers: visibleIndices
                                    .map((origIdx) => origIdx + 1)
                                    .toList(),
                                activeIndex: safeCursor,
                                correctStates: visibleIndices
                                    .map(_isQuestionCorrect)
                                    .toList(),
                                isDark: isDark,
                                onTapItem: (idx) =>
                                    setState(() => _filteredCursor = idx),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // 2. Question, Answer Comparison, and Study Note Explanation
                      Expanded(
                        child: visibleIndices.isEmpty
                            ? _buildEmptyFilterState(
                                isDark: isDark,
                                primaryColor: primaryColor,
                              )
                            : _buildQuestionReviewContent(
                                originalIndex: visibleIndices[safeCursor],
                                isDark: isDark,
                                primaryColor: primaryColor,
                                secondaryColor: secondaryColor,
                                successColor: successColor,
                                errorColor: errorColor,
                              ),
                      ),

                      // 3. Bottom Navigation Bar
                      if (visibleIndices.isNotEmpty)
                        Container(
                          padding: EdgeInsets.fromLTRB(
                            AppSpacing.xl,
                            AppSpacing.md,
                            AppSpacing.xl,
                            MediaQuery.of(context).padding.bottom +
                                AppSpacing.md,
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
                            boxShadow: AppShadows.navBar(isDark),
                          ),
                          child: Row(
                            children: [
                              if (safeCursor > 0) ...[
                                Expanded(
                                  child: AppButton(
                                    label: AppLocalizations
                                        .simReviewPreviousCta(),
                                    icon: Icons.arrow_back_rounded,
                                    variant: AppButtonVariant.secondary,
                                    onPressed: () => setState(
                                      () => _filteredCursor = safeCursor - 1,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                              ],
                              Expanded(
                                child: AppButton(
                                  label: safeCursor < visibleIndices.length - 1
                                      ? AppLocalizations.simReviewNextCta()
                                      : AppLocalizations.simReviewDoneCta(),
                                  trailingIcon:
                                      safeCursor < visibleIndices.length - 1
                                          ? Icons.arrow_forward_rounded
                                          : Icons.check_rounded,
                                  onPressed:
                                      safeCursor < visibleIndices.length - 1
                                          ? () => setState(
                                                () => _filteredCursor =
                                                    safeCursor + 1,
                                              )
                                          : () => Navigator.pop(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required Color activeColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final Color borderColor = isSelected
        ? activeColor
        : (isDark ? AppColors.borderDark : AppColors.borderLight);
    final Color bgColor = isSelected
        ? activeColor.withValues(alpha: isDark ? 0.2 : 0.14)
        : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight);
    final Color labelColor =
        isSelected ? activeColor : _subTextColor(isDark);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 40),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            border: Border.all(
              color: borderColor,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: labelColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyFilterState({
    required bool isDark,
    required Color primaryColor,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: AppCard(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                size: 56,
                color: primaryColor,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                AppLocalizations.simReviewEmptyFilterTitle(),
                textAlign: TextAlign.center,
                style: AppTextStyles.titleLarge.copyWith(
                  color: _textColor(isDark),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: AppLocalizations.simReviewShowAllCta(),
                expand: false,
                onPressed: () => _setFilter(_ReviewFilter.all),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionReviewContent({
    required int originalIndex,
    required bool isDark,
    required Color primaryColor,
    required Color secondaryColor,
    required Color successColor,
    required Color errorColor,
  }) {
    final question = _questions[originalIndex];
    final bool isReading = question.section == 'Reading';
    final Color sectionColor = isReading ? secondaryColor : primaryColor;
    final int? userAnswer = originalIndex < widget.userAnswers.length
        ? widget.userAnswers[originalIndex]
        : null;
    final bool isCorrect = userAnswer == question.correctAnswerIndex;

    return SingleChildScrollView(
      key: ValueKey<int>(originalIndex),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question & Passage Card (shared, Wrap prevents badge ellipsis)
          ExamQuestionCard(
            questionNumber: originalIndex + 1,
            question: question,
            sectionLabel: isReading
                ? AppLocalizations.simExamSectionReading()
                : AppLocalizations.simExamSectionLanguage(),
            sectionColor: sectionColor,
            isDark: isDark,
            trailingBadge: AppBadge(
              label: isCorrect
                  ? AppLocalizations.simReviewStatusCorrect()
                  : AppLocalizations.simReviewStatusWrong(),
              icon: isCorrect
                  ? Icons.check_circle_rounded
                  : Icons.cancel_rounded,
              color: isCorrect ? successColor : errorColor,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Options Comparison List (shared)
          ...List.generate(question.options.length, (index) {
            final bool isCorrectOption = index == question.correctAnswerIndex;
            final bool isUserSelected = index == userAnswer;

            String? statusTag;
            if (isCorrectOption) {
              statusTag = isUserSelected
                  ? AppLocalizations.simReviewTagYourAnswer()
                  : AppLocalizations.simReviewTagCorrectAnswer();
            } else if (isUserSelected && !isCorrectOption) {
              statusTag = AppLocalizations.simReviewTagYourChoice();
            }

            return AnswerOptionTile(
              mode: ExamDisplayMode.review,
              index: index,
              text: question.options[index],
              isDark: isDark,
              isSelected: isUserSelected,
              isCorrectOption: isCorrectOption,
              reviewStatusTag: statusTag,
            );
          }),

          const SizedBox(height: AppSpacing.md),

          // Study Note Explanation Box
          if (question.explanationId != null ||
              question.explanationEn != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.primaryContainerDark.withValues(alpha: 0.45)
                    : AppColors.primaryContainerLight.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                border: Border.all(
                  color: primaryColor.withValues(alpha: 0.35),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.16),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                        child: Icon(
                          Icons.lightbulb_outline_rounded,
                          size: 18,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          AppLocalizations.simReviewExplanationHeader(),
                          style: AppTextStyles.labelMedium.copyWith(
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    (globalLanguage.value == 'id'
                            ? question.explanationId
                            : question.explanationEn) ??
                        question.explanationId ??
                        "",
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: _textColor(isDark),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Color _textColor(bool isDark) =>
      isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
  Color _subTextColor(bool isDark) =>
      isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
}
