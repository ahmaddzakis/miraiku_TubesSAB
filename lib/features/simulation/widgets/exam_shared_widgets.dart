import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_progress_bar.dart';
import '../../../data/simulation_data.dart';

/// Shared display mode for simulation exam and review widgets.
enum ExamDisplayMode { exam, review }

/// Thin progress bar with right-aligned question counter (`1/40`),
/// shared by both SimulationTestScreen and SimulationReviewScreen.
class ExamProgressHeader extends StatelessWidget {
  final int current;
  final int total;
  final Color color;
  final Color subTextColor;
  final String semanticLabel;

  const ExamProgressHeader({
    super.key,
    required this.current,
    required this.total,
    required this.color,
    required this.subTextColor,
    required this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = total > 0 ? (current / total).clamp(0.0, 1.0) : 0.0;

    return Row(
      children: [
        Expanded(
          child: AppProgressBar(
            progress: progress,
            color: color,
            semanticLabel: semanticLabel,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          '$current/$total',
          style: AppTextStyles.labelMedium.copyWith(
            color: subTextColor,
          ),
        ),
      ],
    );
  }
}

/// Horizontal question number indicator strip with automatic scrolling to keep
/// the active chip visible.
///
/// - In [ExamDisplayMode.exam]: purely non-interactive indicator with neutral
///   active, answered, and unanswered states (no green/red feedback).
/// - In [ExamDisplayMode.review]: interactive strip allowing direct jump with
///   correct/wrong coloring.
class QuestionNumberStrip extends StatefulWidget {
  final ExamDisplayMode mode;
  final List<int> itemNumbers;
  final int activeIndex;
  final List<bool>? answeredStates;
  final List<bool>? correctStates;
  final ValueChanged<int>? onTapItem;
  final bool isDark;
  final String Function(int questionNumber, bool isActive, bool isAnswered)?
      itemSemanticBuilder;

  const QuestionNumberStrip({
    super.key,
    required this.mode,
    required this.itemNumbers,
    required this.activeIndex,
    required this.isDark,
    this.answeredStates,
    this.correctStates,
    this.onTapItem,
    this.itemSemanticBuilder,
  });

  @override
  State<QuestionNumberStrip> createState() => _QuestionNumberStripState();
}

class _QuestionNumberStripState extends State<QuestionNumberStrip> {
  static const double _itemSize = 38.0;
  static const double _itemExtent = _itemSize + AppSpacing.xs;

  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToActiveIndex(animate: false);
    });
  }

  @override
  void didUpdateWidget(covariant QuestionNumberStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeIndex != widget.activeIndex ||
        oldWidget.itemNumbers.length != widget.itemNumbers.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToActiveIndex(animate: true);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToActiveIndex({required bool animate}) {
    if (!mounted || !_scrollController.hasClients) return;
    if (widget.itemNumbers.isEmpty) return;

    final double viewportWidth = _scrollController.position.viewportDimension;
    final double maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll <= 0) return;

    final double targetCenter =
        (widget.activeIndex * _itemExtent) + (_itemSize / 2);
    final double desiredOffset =
        (targetCenter - (viewportWidth / 2)).clamp(0.0, maxScroll);

    final bool reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (!animate || reduceMotion) {
      _scrollController.jumpTo(desiredOffset);
    } else {
      _scrollController.animateTo(
        desiredOffset,
        duration: AppSpacing.animNormal,
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor =
        widget.isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final Color onPrimaryColor =
        widget.isDark ? AppColors.onPrimaryDark : AppColors.onPrimaryLight;
    final Color successColor =
        widget.isDark ? AppColors.successDark : AppColors.successLight;
    final Color errorColor =
        widget.isDark ? AppColors.errorDark : AppColors.errorLight;
    final Color subTextColor = widget.isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final Color defaultBg = widget.isDark
        ? AppColors.surfaceVariantDark
        : AppColors.surfaceVariantLight;
    final Color defaultBorder =
        widget.isDark ? AppColors.borderDark : AppColors.borderLight;

    return SizedBox(
      height: _itemSize,
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: widget.itemNumbers.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
        itemBuilder: (context, idx) {
          final int questionNumber = widget.itemNumbers[idx];
          final bool isCurrent = idx == widget.activeIndex;

          late final Color bgColor;
          late final Color borderColor;
          late final Color textColor;
          late final double borderWidth;
          bool isAnswered = false;

          if (widget.mode == ExamDisplayMode.review) {
            final bool isRight =
                widget.correctStates != null && idx < widget.correctStates!.length
                    ? widget.correctStates![idx]
                    : false;
            final Color statusColor = isRight ? successColor : errorColor;
            bgColor =
                isCurrent ? statusColor : statusColor.withValues(alpha: 0.12);
            borderColor = statusColor;
            textColor = isCurrent ? Colors.white : statusColor;
            borderWidth = isCurrent ? 2.0 : 1.0;
          } else {
            isAnswered = widget.answeredStates != null &&
                idx < widget.answeredStates!.length &&
                widget.answeredStates![idx];

            if (isCurrent) {
              bgColor = primaryColor;
              borderColor = primaryColor;
              textColor = onPrimaryColor;
              borderWidth = 2.0;
            } else if (isAnswered) {
              bgColor = widget.isDark
                  ? AppColors.primaryContainerDark.withValues(alpha: 0.45)
                  : AppColors.primaryContainerLight;
              borderColor = primaryColor.withValues(alpha: 0.45);
              textColor = primaryColor;
              borderWidth = 1.0;
            } else {
              bgColor = defaultBg;
              borderColor = defaultBorder;
              textColor = subTextColor;
              borderWidth = 1.0;
            }
          }

          final Widget chip = Container(
            width: _itemSize,
            height: _itemSize,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              border: Border.all(
                color: borderColor,
                width: borderWidth,
              ),
            ),
            child: Center(
              child: Text(
                '$questionNumber',
                style: AppTextStyles.labelMedium.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          );

          if (widget.mode == ExamDisplayMode.review &&
              widget.onTapItem != null) {
            return GestureDetector(
              onTap: () => widget.onTapItem!(idx),
              child: chip,
            );
          }

          final String? semanticLabel = widget.itemSemanticBuilder?.call(
            questionNumber,
            isCurrent,
            isAnswered,
          );
          return Semantics(
            label: semanticLabel,
            child: chip,
          );
        },
      ),
    );
  }
}

/// Shared question & passage card used in both Exam and Exam Review screens.
/// Uses [Wrap] in its header so section/status badges never truncate with ellipsis.
class ExamQuestionCard extends StatelessWidget {
  final int questionNumber;
  final SimulationQuestion question;
  final String sectionLabel;
  final Color sectionColor;
  final bool isDark;
  final Widget? trailingBadge;

  const ExamQuestionCard({
    super.key,
    required this.questionNumber,
    required this.question,
    required this.sectionLabel,
    required this.sectionColor,
    required this.isDark,
    this.trailingBadge,
  });

  @override
  Widget build(BuildContext context) {
    final bool isReading = question.section == 'Reading';
    final Color textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final Color subTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return AppCard(
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
                AppBadge(
                  label: '#$questionNumber • $sectionLabel',
                  icon: isReading
                      ? Icons.menu_book_rounded
                      : Icons.translate_rounded,
                  color: sectionColor,
                ),
                ?trailingBadge,
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            question.question,
            style: AppTextStyles.japaneseTitle.copyWith(
              fontWeight: FontWeight.w800,
              color: textColor,
              height: 1.5,
            ),
          ),
          if (question.romaji != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              question.romaji!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: subTextColor,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          if (question.subQuestion != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceVariantDark
                    : AppColors.surfaceVariantLight,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                  color: sectionColor.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                question.subQuestion!,
                style: AppTextStyles.japaneseBody.copyWith(
                  color: textColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Shared A/B/C/D answer option tile supporting neutral [ExamDisplayMode.exam]
/// and graded [ExamDisplayMode.review] presentation.
class AnswerOptionTile extends StatelessWidget {
  final ExamDisplayMode mode;
  final int index;
  final String text;
  final bool isDark;
  final bool isSelected;
  final bool isCorrectOption;
  final String? reviewStatusTag;
  final VoidCallback? onTap;
  final String? semanticLabel;

  const AnswerOptionTile({
    super.key,
    required this.mode,
    required this.index,
    required this.text,
    required this.isDark,
    this.isSelected = false,
    this.isCorrectOption = false,
    this.reviewStatusTag,
    this.onTap,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final bool reduceMotion = MediaQuery.disableAnimationsOf(context);
    final Color primaryColor =
        isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final Color onPrimaryColor =
        isDark ? AppColors.onPrimaryDark : AppColors.onPrimaryLight;
    final Color successColor =
        isDark ? AppColors.successDark : AppColors.successLight;
    final Color errorColor =
        isDark ? AppColors.errorDark : AppColors.errorLight;
    final Color textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final Color subTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final Color surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    Color optionBorderColor =
        isDark ? AppColors.borderDark : AppColors.borderLight;
    Color optionBgColor = surfaceColor;
    Color letterBoxBg = isDark
        ? AppColors.surfaceVariantDark
        : AppColors.surfaceVariantLight;
    Color letterColor = subTextColor;
    Color optionTextColor = textColor;
    double borderWidth = 1.5;
    FontWeight textWeight = FontWeight.w600;
    IconData? statusIcon;
    Color? statusColor;

    if (mode == ExamDisplayMode.review) {
      if (isCorrectOption) {
        optionBorderColor = successColor;
        optionBgColor = isDark
            ? AppColors.successContainerDark
            : AppColors.successContainerLight;
        letterBoxBg = successColor;
        letterColor = Colors.white;
        borderWidth = 2.0;
        textWeight = FontWeight.w800;
        statusIcon = Icons.check_circle_rounded;
        statusColor = successColor;
      } else if (isSelected && !isCorrectOption) {
        optionBorderColor = errorColor;
        optionBgColor = isDark
            ? AppColors.errorContainerDark
            : AppColors.errorContainerLight;
        letterBoxBg = errorColor;
        letterColor = Colors.white;
        borderWidth = 2.0;
        textWeight = FontWeight.w800;
        statusIcon = Icons.cancel_rounded;
        statusColor = errorColor;
      }
    } else if (isSelected) {
      optionBorderColor = primaryColor;
      optionBgColor = isDark
          ? AppColors.primaryContainerDark
          : AppColors.primaryContainerLight;
      letterBoxBg = primaryColor;
      letterColor = onPrimaryColor;
      optionTextColor = isDark ? AppColors.textPrimaryDark : primaryColor;
      borderWidth = 2.0;
      textWeight = FontWeight.w800;
    }

    final String optionLetter = String.fromCharCode(65 + index);

    final Widget content = AnimatedContainer(
      duration: reduceMotion ? Duration.zero : AppSpacing.animFast,
      curve: Curves.easeOutCubic,
      constraints: const BoxConstraints(minHeight: AppSpacing.minTapTarget),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: optionBgColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: optionBorderColor,
          width: borderWidth,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: letterBoxBg,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Center(
              child: Text(
                optionLetter,
                style: AppTextStyles.labelLarge.copyWith(
                  color: letterColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: AppTextStyles.japaneseBody.copyWith(
                    fontWeight: textWeight,
                    color: optionTextColor,
                  ),
                ),
                if (mode == ExamDisplayMode.review &&
                    reviewStatusTag != null &&
                    statusColor != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    reviewStatusTag!,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: statusColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (mode == ExamDisplayMode.review && statusIcon != null) ...[
            const SizedBox(width: AppSpacing.xs),
            Icon(statusIcon, color: statusColor, size: 24),
          ],
        ],
      ),
    );

    if (mode == ExamDisplayMode.exam) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Semantics(
          button: true,
          selected: isSelected,
          label: semanticLabel,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              onTap: onTap,
              child: content,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: content,
    );
  }
}
