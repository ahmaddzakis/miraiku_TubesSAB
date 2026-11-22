import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/game_manager.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_badge.dart';
import '../../core/widgets/app_button.dart';
import '../../data/simulation_data.dart';
import 'simulation_result_screen.dart';
import 'widgets/exam_shared_widgets.dart';

class SimulationTestScreen extends StatefulWidget {
  /// Optional custom question list for testing. Production uses shuffled
  /// [SimulationData.n5Questions] grouped by section.
  final List<SimulationQuestion>? initialQuestions;

  const SimulationTestScreen({
    super.key,
    this.initialQuestions,
  });

  @override
  State<SimulationTestScreen> createState() => _SimulationTestScreenState();
}

class _SimulationTestScreenState extends State<SimulationTestScreen> {
  int _currentQuestionIndex = 0;
  int _languageTotal = 0;
  int _readingTotal = 0;
  int? _selectedOption;
  bool _hasFinished = false;
  bool _isDialogOpen = false;
  late List<SimulationQuestion> _questions;
  late List<int> _questionIndices;
  late List<int?> _userAnswers;

  static const int _totalDurationSeconds = 50 * 60; // 50 mins total
  Timer? _timer;
  int _timeLeft = _totalDurationSeconds;

  @override
  void initState() {
    super.initState();

    if (widget.initialQuestions != null &&
        widget.initialQuestions!.isNotEmpty) {
      _questions = List<SimulationQuestion>.from(widget.initialQuestions!);
      _questionIndices = List<int>.generate(_questions.length, (i) => i);
      _languageTotal =
          _questions.where((q) => q.section == 'Language Knowledge').length;
      _readingTotal = _questions.where((q) => q.section == 'Reading').length;
    } else {
      // Group, Shuffle, and Concatenate while preserving exact indices in SimulationData.n5Questions
      final allQuestions = SimulationData.n5Questions;

      final List<int> languageIndices = [];
      final List<int> readingIndices = [];

      for (int i = 0; i < allQuestions.length; i++) {
        if (allQuestions[i].section == 'Language Knowledge') {
          languageIndices.add(i);
        } else if (allQuestions[i].section == 'Reading') {
          readingIndices.add(i);
        }
      }

      languageIndices.shuffle();
      readingIndices.shuffle();

      _questionIndices = [...languageIndices, ...readingIndices];
      _questions = _questionIndices.map((i) => allQuestions[i]).toList();
      _languageTotal = languageIndices.length;
      _readingTotal = readingIndices.length;
    }

    _userAnswers = List.filled(_questions.length, null);

    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        if (mounted) setState(() => _timeLeft--);
      } else {
        _timer?.cancel();
        _finishTest();
      }
    });
  }

  String get _formattedTime {
    final int minutes = _timeLeft ~/ 60;
    final int seconds = _timeLeft % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _handleOptionSelect(int index) {
    if (_hasFinished) return;
    setState(() => _selectedOption = index);
  }

  void _commitAndAdvance() {
    if (_selectedOption == null || _hasFinished) return;

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _userAnswers[_currentQuestionIndex] = _selectedOption;
        _currentQuestionIndex++;
        _selectedOption = null;
      });
    } else {
      _showFinishConfirmation();
    }
  }

  int _countUnansweredQuestions() {
    int unanswered = 0;
    for (int i = 0; i < _questions.length; i++) {
      final int? effectiveAnswer =
          i == _currentQuestionIndex ? _selectedOption : _userAnswers[i];
      if (effectiveAnswer == null) unanswered++;
    }
    return unanswered;
  }

  void _finishTest() async {
    if (_hasFinished) return;
    _hasFinished = true;
    _timer?.cancel();

    if (_isDialogOpen && mounted) {
      _isDialogOpen = false;
      Navigator.of(context).pop();
    }

    // Evaluate all saved answers only upon finishing the exam
    int languageScore = 0;
    int readingScore = 0;
    for (int i = 0; i < _questions.length; i++) {
      final int? answer = _userAnswers[i];
      if (answer != null && answer == _questions[i].correctAnswerIndex) {
        if (_questions[i].section == 'Language Knowledge') {
          languageScore++;
        } else if (_questions[i].section == 'Reading') {
          readingScore++;
        }
      }
    }

    // JLPT N5 Scaling (Simplified for app: Lang 60, Reading 120 = 180 total)
    final double langPoints =
        (languageScore / (_languageTotal == 0 ? 1 : _languageTotal)) * 60;
    final double readingPoints =
        (readingScore / (_readingTotal == 0 ? 1 : _readingTotal)) * 120;
    final double totalPoints = langPoints + readingPoints;
    final bool isPassed = totalPoints >= 80;
    final int timeSpent = _totalDurationSeconds - _timeLeft;
    final bool completedAllQuestions =
        _userAnswers.isNotEmpty && _userAnswers.every((ans) => ans != null);

    // Save Result to History via GameManager including exact shuffled questionIndices
    final Map<String, dynamic> newResult = {
      'date': DateTime.now().toIso8601String(),
      'languageScore': languageScore,
      'languageTotal': _languageTotal,
      'readingScore': readingScore,
      'readingTotal': _readingTotal,
      'timeSpentSeconds': timeSpent,
      'totalPoints': totalPoints,
      'isPassed': isPassed,
      'userAnswers': _userAnswers,
      'questionIndices': _questionIndices,
    };

    List<dynamic> history = List.from(globalSimulationHistory.value);
    history.insert(0, newResult);

    if (history.length > 10) history = history.sublist(0, 10);
    globalSimulationHistory.value = history;

    if (completedAllQuestions) {
      await GameManager.incrementSimulationCount();
    }
    await GameManager.syncToCloud();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SimulationResultScreen(
            languageScore: languageScore,
            languageTotal: _languageTotal,
            readingScore: readingScore,
            readingTotal: _readingTotal,
            timeSpentSeconds: timeSpent,
            totalPoints: totalPoints,
            isPassed: isPassed,
            userAnswers: _userAnswers,
            questions: _questions,
          ),
        ),
      );
    }
  }

  Color _resolveTimerColor(bool isDark) {
    if (_timeLeft <= 60) {
      return isDark ? AppColors.errorDark : AppColors.errorLight;
    }
    if (_timeLeft <= 300) {
      return isDark ? AppColors.warningDark : AppColors.warningLight;
    }
    return isDark ? AppColors.primaryDark : AppColors.primaryLight;
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return ValueListenableBuilder<bool>(
      valueListenable: globalDarkMode,
      builder: (context, isDark, _) {
        return ValueListenableBuilder<String>(
          valueListenable: globalLanguage,
          builder: (context, lang, _) {
            final question = _questions[_currentQuestionIndex];
            final bool isReadingSection = question.section == 'Reading';

            final Color primaryColor =
                isDark ? AppColors.primaryDark : AppColors.primaryLight;
            final Color secondaryColor =
                isDark ? AppColors.secondaryDark : AppColors.secondaryLight;
            final Color sectionColor =
                isReadingSection ? secondaryColor : primaryColor;
            final Color timerColor = _resolveTimerColor(isDark);

            final Color bgColor =
                isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
            final Color textColor =
                isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
            final Color subTextColor = isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight;

            final List<int> questionNumbers = List<int>.generate(
              _questions.length,
              (i) => i + 1,
            );
            final List<bool> answeredStates = List<bool>.generate(
              _questions.length,
              (i) => _userAnswers[i] != null,
            );
            final String sectionLabel = isReadingSection
                ? AppLocalizations.simExamSectionReading()
                : AppLocalizations.simExamSectionLanguage();

            return PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) {
                if (didPop) return;
                _showExitConfirmation();
              },
              child: Scaffold(
                backgroundColor: bgColor,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: Semantics(
                    button: true,
                    label: AppLocalizations.simTestExitSemantics(),
                    child: IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: textColor,
                      ),
                      onPressed: _showExitConfirmation,
                    ),
                  ),
                  title: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      AppLocalizations.simTestAppBarTitle(),
                      style: AppTextStyles.titleLarge.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  centerTitle: true,
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.md),
                      child: Center(
                        child: Semantics(
                          label: AppLocalizations.simTestTimerSemantics(
                            _formattedTime,
                          ),
                          child: AppBadge(
                            label: _formattedTime,
                            icon: _timeLeft <= 60
                                ? Icons.timer_off_outlined
                                : Icons.timer_outlined,
                            color: timerColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 6,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                body: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppSpacing.maxContentWidth,
                    ),
                    child: Column(
                      children: [
                        // 1. Thin Progress Bar + Counter & Horizontal Question Number Strip
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                            vertical: AppSpacing.xs,
                          ),
                          child: Column(
                            children: [
                              ExamProgressHeader(
                                current: _currentQuestionIndex + 1,
                                total: _questions.length,
                                color: primaryColor,
                                subTextColor: subTextColor,
                                semanticLabel: AppLocalizations
                                    .simTestProgressSemantics(),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              QuestionNumberStrip(
                                mode: ExamDisplayMode.exam,
                                itemNumbers: questionNumbers,
                                activeIndex: _currentQuestionIndex,
                                answeredStates: answeredStates,
                                isDark: isDark,
                                itemSemanticBuilder:
                                    (number, isActive, isAnswered) {
                                  if (isActive) {
                                    return AppLocalizations
                                        .simTestChipActiveSemantics(number);
                                  }
                                  if (isAnswered) {
                                    return AppLocalizations
                                        .simTestChipAnsweredSemantics(number);
                                  }
                                  return AppLocalizations
                                      .simTestChipUnansweredSemantics(number);
                                },
                              ),
                            ],
                          ),
                        ),

                        // 2. Question Card & Neutral Options List (matching Exam Review)
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: reduceMotion
                                ? Duration.zero
                                : AppSpacing.animNormal,
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            transitionBuilder: (
                              Widget child,
                              Animation<double> animation,
                            ) {
                              if (reduceMotion) return child;
                              final slideIn = Tween<Offset>(
                                begin: const Offset(0.04, 0.0),
                                end: Offset.zero,
                              ).animate(animation);

                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: slideIn,
                                  child: child,
                                ),
                              );
                            },
                            child: SingleChildScrollView(
                              key: ValueKey<int>(_currentQuestionIndex),
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.all(AppSpacing.xl),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ExamQuestionCard(
                                    questionNumber: _currentQuestionIndex + 1,
                                    question: question,
                                    sectionLabel: sectionLabel,
                                    sectionColor: sectionColor,
                                    isDark: isDark,
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  ...List.generate(question.options.length, (
                                    index,
                                  ) {
                                    final bool isSelected =
                                        _selectedOption == index;
                                    final String letter =
                                        String.fromCharCode(65 + index);
                                    return AnswerOptionTile(
                                      mode: ExamDisplayMode.exam,
                                      index: index,
                                      text: question.options[index],
                                      isDark: isDark,
                                      isSelected: isSelected,
                                      onTap: () => _handleOptionSelect(index),
                                      semanticLabel: AppLocalizations
                                          .simTestOptionSemantics(
                                        letter,
                                        question.options[index],
                                        isSelected,
                                      ),
                                    );
                                  }),
                                  const SizedBox(height: AppSpacing.lg),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // 3. Bottom Action Bar (matching Exam Review)
                        _buildBottomBar(isDark),
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
  }

  Widget _buildBottomBar(bool isDark) {
    final bool canProceed = _selectedOption != null;
    final bool isLastQuestion = _currentQuestionIndex == _questions.length - 1;
    final Color panelColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.md,
        AppSpacing.xl,
        MediaQuery.of(context).padding.bottom + AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: panelColor,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        boxShadow: AppShadows.navBar(isDark),
      ),
      child: AppButton(
        label: isLastQuestion
            ? AppLocalizations.simTestFinishCta()
            : AppLocalizations.simTestNextCta(),
        trailingIcon:
            isLastQuestion ? Icons.check_rounded : Icons.arrow_forward_rounded,
        onPressed: canProceed ? _commitAndAdvance : null,
      ),
    );
  }

  void _showFinishConfirmation() {
    if (_hasFinished || _isDialogOpen) return;
    final bool isDark = globalDarkMode.value;
    final Color primaryColor =
        isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final int unansweredCount = _countUnansweredQuestions();

    _isDialogOpen = true;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.task_alt_rounded,
                size: 48,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              AppLocalizations.simTestFinishDialogTitle(),
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineMedium.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              unansweredCount > 0
                  ? AppLocalizations.simTestFinishDialogBodyUnanswered(
                      unansweredCount,
                    )
                  : AppLocalizations.simTestFinishDialogBodyAllAnswered(),
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: AppLocalizations.simTestCancelCta(),
                    variant: AppButtonVariant.ghost,
                    height: 48,
                    onPressed: () => Navigator.pop(dialogContext),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppButton(
                    label: AppLocalizations.simTestFinishCta(),
                    height: 48,
                    onPressed: () {
                      _isDialogOpen = false;
                      Navigator.pop(dialogContext);
                      _userAnswers[_currentQuestionIndex] = _selectedOption;
                      _finishTest();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).then((_) => _isDialogOpen = false);
  }

  void _showExitConfirmation() {
    if (_hasFinished || _isDialogOpen) return;
    final isDark = globalDarkMode.value;
    final errorColor = isDark ? AppColors.errorDark : AppColors.errorLight;

    _isDialogOpen = true;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: errorColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                size: 48,
                color: errorColor,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              AppLocalizations.simTestExitDialogTitle(),
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineMedium.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              AppLocalizations.simTestExitDialogBody(),
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: AppLocalizations.simTestCancelCta(),
                    variant: AppButtonVariant.ghost,
                    height: 48,
                    onPressed: () => Navigator.pop(dialogContext),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppButton(
                    label: AppLocalizations.simTestExitCta(),
                    variant: AppButtonVariant.danger,
                    height: 48,
                    onPressed: () {
                      _isDialogOpen = false;
                      Navigator.pop(dialogContext);
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).then((_) => _isDialogOpen = false);
  }
}
