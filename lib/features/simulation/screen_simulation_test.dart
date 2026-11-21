import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/game_manager.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_badge.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_progress_bar.dart';
import '../../data/simulation_data.dart';
import '../../widgets/shake_widget.dart';
import 'simulation_result_screen.dart';

class SimulationTestScreen extends StatefulWidget {
  const SimulationTestScreen({super.key});

  @override
  State<SimulationTestScreen> createState() => _SimulationTestScreenState();
}

class _SimulationTestScreenState extends State<SimulationTestScreen>
    with SingleTickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  int _languageScore = 0;
  int _readingScore = 0;
  int _languageTotal = 0;
  int _readingTotal = 0;
  int? _selectedOption;
  bool _isAnswered = false;
  bool _isCurrentAnswerCorrect = false;
  bool _shouldShake = false;
  late List<SimulationQuestion> _questions;
  late List<int> _questionIndices;
  late List<int?> _userAnswers;

  static const int _totalDurationSeconds = 50 * 60; // 50 mins total
  Timer? _timer;
  int _timeLeft = _totalDurationSeconds;

  late AnimationController _mainController;

  @override
  void initState() {
    super.initState();

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

    _userAnswers = List.filled(_questions.length, null);
    _languageTotal = languageIndices.length;
    _readingTotal = readingIndices.length;

    _mainController = AnimationController(
      vsync: this,
      duration: AppSpacing.animSlow,
    );

    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _mainController.dispose();
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
    if (_isAnswered) return;
    HapticFeedback.selectionClick();
    setState(() => _selectedOption = index);
  }

  void _submitAnswer() {
    if (_selectedOption == null || _isAnswered) return;

    final currentQuestion = _questions[_currentQuestionIndex];
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    setState(() {
      _isAnswered = true;
      _userAnswers[_currentQuestionIndex] = _selectedOption;
      _isCurrentAnswerCorrect =
          _selectedOption == currentQuestion.correctAnswerIndex;

      if (_isCurrentAnswerCorrect) {
        if (currentQuestion.section == 'Language Knowledge') {
          _languageScore++;
        } else if (currentQuestion.section == 'Reading') {
          _readingScore++;
        }
        HapticFeedback.mediumImpact();
      } else {
        HapticFeedback.heavyImpact();
        if (!reduceMotion) {
          _shouldShake = true;
          Future.delayed(AppSpacing.animSlow, () {
            if (mounted) setState(() => _shouldShake = false);
          });
        }
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOption = null;
        _isAnswered = false;
        _isCurrentAnswerCorrect = false;
      });
    } else {
      _finishTest();
    }
  }

  void _finishTest() async {
    _timer?.cancel();

    // JLPT N5 Scaling (Simplified for app: Lang 60, Reading 120 = 180 total)
    final double langPoints =
        (_languageScore / (_languageTotal == 0 ? 1 : _languageTotal)) * 60;
    final double readingPoints =
        (_readingScore / (_readingTotal == 0 ? 1 : _readingTotal)) * 120;
    final double totalPoints = langPoints + readingPoints;
    final bool isPassed = totalPoints >= 80;
    final int timeSpent = _totalDurationSeconds - _timeLeft;

    // Save Result to History via GameManager including exact shuffled questionIndices
    final Map<String, dynamic> newResult = {
      'date': DateTime.now().toIso8601String(),
      'languageScore': _languageScore,
      'languageTotal': _languageTotal,
      'readingScore': _readingScore,
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

    await GameManager.incrementSimulationCount();
    await GameManager.syncToCloud();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SimulationResultScreen(
            languageScore: _languageScore,
            languageTotal: _languageTotal,
            readingScore: _readingScore,
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
            final progress = (_currentQuestionIndex + 1) / _questions.length;
            final Color accentColor =
                isDark ? AppColors.primaryDark : AppColors.primaryLight;
            final Color bgColor =
                isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
            final Color cardColor =
                isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
            final Color textColor =
                isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
            final Color subTextColor = isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight;
            final Color borderColor =
                isDark ? AppColors.borderDark : AppColors.borderLight;
            final Color successColor =
                isDark ? AppColors.successDark : AppColors.successLight;
            final Color errorColor =
                isDark ? AppColors.errorDark : AppColors.errorLight;

            return PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) {
                if (didPop) return;
                _showExitConfirmation();
              },
              child: Scaffold(
                backgroundColor: bgColor,
                body: SafeArea(
                  child: Column(
                    children: [
                      // Synchronized Header
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                          vertical: AppSpacing.md,
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Semantics(
                                  button: true,
                                  label: _t('Exit exam', 'Keluar ujian'),
                                  child: GestureDetector(
                                    onTap: _showExitConfirmation,
                                    child: Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: cardColor,
                                        borderRadius: BorderRadius.circular(
                                          AppSpacing.radiusMd,
                                        ),
                                        border: Border.all(color: borderColor),
                                      ),
                                      child: Icon(
                                        Icons.close_rounded,
                                        color: subTextColor,
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                ),
                                Text(
                                  "JLPT N5 • SIMULATION",
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: accentColor,
                                    letterSpacing: 2.0,
                                  ),
                                ),
                                AppBadge(
                                  label: _formattedTime,
                                  icon: Icons.timer_outlined,
                                  color: accentColor,
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            AppProgressBar(
                              progress: progress,
                              color: accentColor,
                              semanticLabel: _t(
                                'Exam progress',
                                'Progres ujian',
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: reduceMotion
                              ? Duration.zero
                              : AppSpacing.animNormal,
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
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
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.xl,
                              AppSpacing.xs,
                              AppSpacing.xl,
                              100,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppBadge(
                                  label: question.section.toUpperCase(),
                                  color: accentColor,
                                ),
                                const SizedBox(height: AppSpacing.lg),

                                // Question Card
                                ShakeWidget(
                                  shake: _shouldShake,
                                  child: AnimatedContainer(
                                    duration: reduceMotion
                                        ? Duration.zero
                                        : AppSpacing.animNormal,
                                    curve: Curves.easeOutBack,
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(28),
                                    decoration: BoxDecoration(
                                      color: cardColor,
                                      borderRadius: BorderRadius.circular(
                                        AppSpacing.radiusXxl,
                                      ),
                                      border: Border.all(
                                        color: _isAnswered
                                            ? (_isCurrentAnswerCorrect
                                                ? successColor.withValues(
                                                    alpha: 0.6,
                                                  )
                                                : errorColor.withValues(
                                                    alpha: 0.6,
                                                  ))
                                            : borderColor,
                                        width: 2,
                                      ),
                                      boxShadow: _isAnswered
                                          ? AppShadows.accentGlow(
                                              _isCurrentAnswerCorrect
                                                  ? successColor
                                                  : errorColor,
                                              isDark: isDark,
                                            )
                                          : AppShadows.card(isDark),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          question.question,
                                          style: AppTextStyles.japaneseTitle
                                              .copyWith(
                                            fontSize: 26,
                                            fontWeight: FontWeight.w900,
                                            color: textColor,
                                            height: 1.4,
                                          ),
                                        ),
                                        if (question.romaji != null) ...[
                                          const SizedBox(height: AppSpacing.sm),
                                          Text(
                                            question.romaji!,
                                            style: AppTextStyles.bodyLarge
                                                .copyWith(
                                              color: subTextColor,
                                              fontStyle: FontStyle.italic,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                        if (question.subQuestion != null) ...[
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: AppSpacing.lg,
                                            ),
                                            child: Divider(
                                              color: accentColor.withValues(
                                                alpha: 0.15,
                                              ),
                                              thickness: 2,
                                            ),
                                          ),
                                          Text(
                                            question.subQuestion!,
                                            style: AppTextStyles.japaneseBody
                                                .copyWith(
                                              color: textColor.withValues(
                                                alpha: 0.9,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xl),

                                // Options List
                                ...List.generate(question.options.length,
                                    (index) {
                                  return _buildOptionTile(
                                    index,
                                    question.options[index],
                                    isDark,
                                    reduceMotion,
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ),
                      _buildBottomBar(isDark),
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

  String _t(String en, String id) {
    return globalLanguage.value == 'id' ? id : en;
  }

  Widget _buildOptionTile(
    int index,
    String text,
    bool isDark,
    bool reduceMotion,
  ) {
    final bool isSelected = _selectedOption == index;
    final Color accentColor =
        isDark ? AppColors.primaryDark : AppColors.primaryLight;

    Color borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    Color bgColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    Color textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    Color letterBoxColor =
        isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight;
    Color letterTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    if (isSelected) {
      borderColor = accentColor;
      bgColor = isDark
          ? AppColors.primaryContainerDark
          : AppColors.primaryContainerLight;
      letterBoxColor = accentColor;
      letterTextColor =
          isDark ? AppColors.onPrimaryDark : AppColors.onPrimaryLight;
      textColor = isDark ? AppColors.textPrimaryDark : accentColor;
    }

    return GestureDetector(
      onTap: () => _handleOptionSelect(index),
      child: AnimatedContainer(
        duration: reduceMotion ? Duration.zero : AppSpacing.animNormal,
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: borderColor,
            width: (isSelected || _isAnswered) ? 2.5 : 1.5,
          ),
          boxShadow: isSelected && !_isAnswered
              ? AppShadows.accentGlow(accentColor, isDark: isDark)
              : const [],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: reduceMotion ? Duration.zero : AppSpacing.animNormal,
              curve: Curves.easeOutCubic,
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: letterBoxColor,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + index),
                  style: AppTextStyles.titleMedium.copyWith(
                    color: letterTextColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                text,
                style: AppTextStyles.japaneseBody.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(bool isDark) {
    final bool canConfirm = _selectedOption != null || _isAnswered;
    final Color bgColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final Color borderColor =
        isDark ? AppColors.borderDark : AppColors.borderLight;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        MediaQuery.of(context).padding.bottom + AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: AppButton(
        label: _isAnswered
            ? (_currentQuestionIndex == _questions.length - 1
                ? _t("FINISH", "SELESAI")
                : _t("CONTINUE", "LANJUTKAN"))
            : _t("SUBMIT ANSWER", "KONFIRMASI"),
        onPressed:
            canConfirm ? (_isAnswered ? _nextQuestion : _submitAnswer) : null,
      ),
    );
  }

  void _showExitConfirmation() {
    final isDark = globalDarkMode.value;
    final errorColor = isDark ? AppColors.errorDark : AppColors.errorLight;
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
              "Chotto Matte! 🛑",
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineMedium.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _t(
                "Are you sure you want to exit? All simulation progress in this session will be lost!",
                "Yakin ingin keluar? Semua progress simulasi di sesi ini akan hilang lho!",
              ),
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
                    label: _t("CANCEL", "BATAL"),
                    variant: AppButtonVariant.ghost,
                    height: 48,
                    onPressed: () => Navigator.pop(dialogContext),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppButton(
                    label: _t("EXIT", "KELUAR"),
                    variant: AppButtonVariant.danger,
                    height: 48,
                    onPressed: () {
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
    );
  }
}
