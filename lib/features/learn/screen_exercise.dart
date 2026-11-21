import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/game_manager.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/sound_manager.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_badge.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_progress_bar.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../data/quiz_repository.dart';

class ExerciseScreen extends StatefulWidget {
  final int unit;
  final String difficulty;
  final int currentStars;
  final int currentHearts;
  final VoidCallback? onQuizPassed;
  final ValueChanged<int>? onHeartDecreased;
  final bool isReplay;
  final String? hint;

  const ExerciseScreen({
    super.key,
    this.unit = 1,
    this.difficulty = 'basic',
    this.currentStars = 0,
    this.currentHearts = 5,
    this.onQuizPassed,
    this.onHeartDecreased,
    this.isReplay = false,
    this.hint,
  });

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  int? selectedOption;

  String _t(String en, String id) => AppLocalizations.tr(en, id);

  bool _isAnswered = false;
  bool _isCurrentAnswerCorrect = false;

  late List<Map<String, dynamic>> _questions;
  late int _originalQuestionCount;

  bool get isTestMode => widget.difficulty == 'test';
  Timer? _countdownTimer;
  int _timeLeft = 900; // 15 Menit

  final List<String> _selectedWords = [];
  final List<String> _availableWords = [];

  static const List<String> _romajiDecoyPool = [
    'a', 'i', 'u', 'e', 'o',
    'ka', 'ki', 'ku', 'ke', 'ko',
    'sa', 'shi', 'su', 'se', 'so',
    'ta', 'chi', 'tsu', 'te', 'to',
    'na', 'ni', 'nu', 'ne', 'no',
    'ha', 'hi', 'fu', 'he', 'ho',
    'ma', 'mi', 'mu', 'me', 'mo',
    'ya', 'yu', 'yo',
    'ra', 'ri', 'ru', 're', 'ro',
    'wa', 'wo', 'n',
    'ga', 'za', 'da', 'ba', 'pa', 'pi', 'pu', 'pe', 'po',
  ];

  static const List<String> _meaningDecoyPoolId = [
    'perut', 'gambar', 'biru', 'pohon', 'rambut', 'kesemek', 'kota', 'punggung',
    'darah', 'tangan', 'besi', 'dua', 'akar', 'apa', 'api', 'daun', 'bunga',
    'buah', 'mata', 'persik', 'air panas', 'gunung', 'mimpi', 'langit', 'saya',
    'sekolah', 'roti', 'selamat siang', 'selamat tidur', 'terima kasih',
    'selamat tinggal', 'sehat', 'empat', 'sepuluh', 'delapan', 'tujuh',
    'seribu', 'makan', 'minum', 'membaca', 'mendengar', 'tidur', 'membeli',
    'berbicara', 'bekerja', 'mengerti', 'cinta', 'kamera', 'pintu', 'pena',
    'restoran', 'olahraga', 'dasi', 'hadiah', 'matahari', 'bulan', 'air',
    'sungai', 'batu', 'orang', 'anak', 'telinga', 'ayah', 'pergi', 'datang',
    'menulis', 'berenang', 'menunggu', 'pulang', 'duduk', 'enak', 'mahal',
    'murah', 'besar', 'kecil', 'baru', 'bagus', 'sulit', 'mudah',
  ];

  static const List<String> _meaningDecoyPoolEn = [
    'stomach', 'picture', 'blue', 'tree', 'hair', 'persimmon', 'city', 'back',
    'blood', 'hand', 'iron', 'two', 'root', 'what', 'fire', 'leaf', 'flower',
    'fruit', 'eye', 'peach', 'hot water', 'mountain', 'dream', 'sky', 'I / me',
    'school', 'bread', 'good afternoon', 'good night', 'thank you', 'goodbye',
    'healthy / well', 'four', 'ten', 'eight', 'seven', 'thousand', 'eat',
    'drink', 'read', 'listen / hear', 'sleep', 'buy', 'speak / talk', 'work',
    'understand', 'love', 'camera', 'door', 'pen', 'restaurant', 'sports',
    'necktie', 'gift', 'sun', 'moon', 'water', 'river', 'stone', 'person',
    'child', 'ear', 'father', 'go', 'come', 'write', 'swim', 'wait',
    'return home', 'sit down', 'delicious', 'expensive / high', 'cheap', 'big',
    'small', 'new', 'good', 'difficult', 'easy / kind',
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (globalHearts.value <= 0) {
        _showGameOverDialog(reason: AppLocalizations.outOfHearts());
      }
    });

    final allQuestions = List<Map<String, dynamic>>.from(
      QuizRepository.getQuestions(
        widget.unit,
        widget.difficulty,
        widget.currentStars,
        globalLanguage.value,
      ),
    )..shuffle();

    if (isTestMode) {
      _questions = allQuestions.take(20).toList();
    } else {
      _questions = allQuestions;
    }

    _originalQuestionCount = _questions.length;
    _setupWordBank();

    if (isTestMode) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _countdownTimer?.cancel();
        _showGameOverDialog(reason: AppLocalizations.timesUp());
      }
    });
  }

  String get _formattedTime {
    final int minutes = _timeLeft ~/ 60;
    final int seconds = _timeLeft % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  List<String> _resolveDecoyPool(
    Map<String, dynamic> question,
    String correctAnswer,
  ) {
    final dynamic customDecoys = question['decoys'];
    if (customDecoys is List) {
      return customDecoys.map((e) => e.toString()).toList();
    }
    if (customDecoys is Map) {
      final dynamic langDecoys =
          customDecoys[globalLanguage.value] ?? customDecoys['en'];
      if (langDecoys is List) {
        return langDecoys.map((e) => e.toString()).toList();
      }
    }

    final String prompt = (question['question'] ?? '').toString().toLowerCase();
    final bool isReadingPrompt = question['is_reading'] == true ||
        prompt.contains('cara baca') ||
        prompt.contains('bunyi') ||
        prompt.contains('reading') ||
        prompt.contains('sound') ||
        prompt.contains('pilih karakter') ||
        prompt.contains('choose the correct character');

    if (isReadingPrompt) {
      return _romajiDecoyPool;
    }

    return globalLanguage.value == 'id'
        ? _meaningDecoyPoolId
        : _meaningDecoyPoolEn;
  }

  void _setupWordBank() {
    _selectedWords.clear();
    _availableWords.clear();

    final currentQ = _questions[_currentQuestionIndex];

    if (currentQ['audio'] != null) {
      SoundManager.playSound(currentQ['audio']);
    }

    if (currentQ['type'] == 'essay') {
      final String correctAnswer =
          currentQ['answer'].toString().trim().toLowerCase();
      _availableWords.add(correctAnswer);

      final Set<String> seenNormalized = {correctAnswer};
      final List<String> pool = _resolveDecoyPool(currentQ, correctAnswer);
      final List<String> uniqueDecoys = [];

      for (final candidate in pool) {
        final String normalized = candidate.trim().toLowerCase();
        if (normalized.isNotEmpty && seenNormalized.add(normalized)) {
          uniqueDecoys.add(normalized);
        }
      }

      uniqueDecoys.shuffle();
      _availableWords.addAll(uniqueDecoys.take(3));
      _availableWords.shuffle();
    }
  }

  void _selectOption(int index) {
    if (_isAnswered) return;
    HapticFeedback.selectionClick();
    setState(() {
      selectedOption = index;
    });
  }

  Future<void> _checkAnswer(bool isMultipleChoice) async {
    if (_isAnswered) return;

    setState(() {
      _isAnswered = true;
    });

    bool isCorrect = false;
    if (isMultipleChoice) {
      if (selectedOption == _questions[_currentQuestionIndex]['correctIndex']) {
        isCorrect = true;
      }
    } else {
      final int maxSelection =
          (_questions[_currentQuestionIndex]['maxSelection'] as int?) ?? 1;
      final String userAnswer = (maxSelection == 1
              ? (_selectedWords.isNotEmpty ? _selectedWords.first : '')
              : _selectedWords.join(''))
          .trim()
          .toLowerCase();
      final String correctAnswer = _questions[_currentQuestionIndex]['answer']
          .toString()
          .trim()
          .toLowerCase();
      if (userAnswer == correctAnswer) {
        isCorrect = true;
      }
    }

    setState(() {
      _isCurrentAnswerCorrect = isCorrect;
      if (isCorrect) {
        _score++;
        SoundManager.playSound('benar.mp3');
        if (!widget.isReplay) {
          GameManager.addXP(25);
        }
      } else {
        SoundManager.playSound('salah.mp3');
      }
    });

    if (!isCorrect) {
      await GameManager.decreaseHeart();

      if (widget.onHeartDecreased != null) {
        widget.onHeartDecreased!(globalHearts.value);
      }

      if (globalHearts.value <= 0) {
        _countdownTimer?.cancel();
        _showGameOverDialog(reason: AppLocalizations.outOfHearts());
        return;
      }

      setState(() {
        _questions.add(
          Map<String, dynamic>.from(_questions[_currentQuestionIndex]),
        );
      });
    }
  }

  void _nextQuestion() {
    if (!isTestMode && globalHearts.value <= 0) {
      _showGameOverDialog();
      return;
    }

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        selectedOption = null;
        _isAnswered = false;
        _isCurrentAnswerCorrect = false;
        _setupWordBank();
      });
    } else {
      _countdownTimer?.cancel();
      const bool isPassed = true;
      if (widget.onQuizPassed != null) {
        widget.onQuizPassed!();
      }
      _showResultDialog(isPassed);
    }
  }

  void _showExitConfirmationDialog() {
    HapticFeedback.lightImpact();
    final bool isDark = globalDarkMode.value;
    final Color errorColor =
        isDark ? AppColors.errorDark : AppColors.errorLight;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        title: Column(
          children: [
            Icon(Icons.warning_rounded, color: errorColor, size: 48),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'ちょっと待って!',
              style: AppTextStyles.labelSmall.copyWith(
                color: errorColor,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AppLocalizations.holdOn(),
              style: AppTextStyles.headlineMedium.copyWith(
                fontWeight: FontWeight.w900,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Text(
          AppLocalizations.exitConfirmMessage(),
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyLarge.copyWith(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: AppLocalizations.cancelLabel(),
                  variant: AppButtonVariant.secondary,
                  height: 48,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppButton(
                  label: AppLocalizations.exitLabel(),
                  variant: AppButtonVariant.danger,
                  height: 48,
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showGameOverDialog({String? reason}) {
    SoundManager.playSound('defeat.mp3');
    final bool isDark = globalDarkMode.value;
    final Color errorColor =
        isDark ? AppColors.errorDark : AppColors.errorLight;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          ),
          backgroundColor:
              isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          title: Column(
            children: [
              Icon(Icons.heart_broken_rounded, color: errorColor, size: 64),
              const SizedBox(height: AppSpacing.md),
              Text(
                reason != null
                    ? "❌ $reason"
                    : _t("Failure is normal!", "Gagal Itu Wajar!"),
                style: AppTextStyles.headlineMedium.copyWith(
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppColors.textPrimaryDark : errorColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                reason == _t("Time's Up!", "Waktu Habis!")
                    ? _t(
                        "Your exam time has run out! Restore your hearts and try to finish faster.",
                        "Waktu ujianmu telah habis! Ayo pulihkan nyawamu lalu coba selesaikan lebih cepat.",
                      )
                    : _t(
                        "Don't give up! Every mistake is a step towards success. Come on, restore your lives and try again!",
                        "Jangan menyerah! Setiap kesalahan adalah langkah menuju kesuksesan. Yuk, pulihkan nyawa dan coba lagi!",
                      ),
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.flash_on,
                    color: AppColors.streakFlame,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _t("Needs 150 XP for 1 Heart", "Butuh 150 XP untuk 1 Nyawa"),
                    style: AppTextStyles.labelLarge.copyWith(
                      color: isDark
                          ? AppColors.warningDark
                          : AppColors.warningLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          actions: [
            Column(
              children: [
                AppButton(
                  label: _t("BUY HEART (150 XP)", "BELI NYAWA (150 XP)"),
                  height: 50,
                  onPressed: () async {
                    final bool success = await GameManager.buyHeartWithXP();
                    if (!context.mounted) return;
                    if (success) {
                      Navigator.pop(context);
                    } else {
                      AppSnackbar.showError(
                        context,
                        _t("Not enough XP!", "XP tidak cukup!"),
                      );
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: _t("BACK TO MENU", "KEMBALI KE MENU"),
                  variant: AppButtonVariant.ghost,
                  height: 48,
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showResultDialog(bool isPassed) {
    final int newStarsCount =
        isPassed ? (widget.currentStars + 1).clamp(0, 3) : widget.currentStars;
    final int xpGained = !widget.isReplay ? _score * 25 : 0;
    SoundManager.playSound('victory.mp3');
    final bool isDark = globalDarkMode.value;
    final Color primaryColor =
        isDark ? AppColors.primaryDark : AppColors.primaryLight;

    String motivation = _t(
      "Great! Keep honing your skills!",
      "Wah hebat! Terus asah kemampuanmu!",
    );
    if (_score == _originalQuestionCount) {
      motivation = _t(
        "Incredible! You are getting closer to fluency!",
        "Luar biasa! Kamu semakin dekat dengan kefasihan!",
      );
    } else if (_score > _originalQuestionCount / 2) {
      motivation = _t(
        "Cool! Don't stop here!",
        "Keren sekali! Jangan berhenti di sini!",
      );
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        title: Text(
          isTestMode
              ? _t("🏆 Unit Test Passed!", "🏆 Unit Test Lulus!")
              : _t("🎉 Exercise Finished!", "🎉 Latihan Selesai!"),
          style: AppTextStyles.headlineMedium.copyWith(
            fontWeight: FontWeight.w900,
            color: primaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              motivation,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleLarge.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceVariantDark
                    : AppColors.surfaceVariantLight,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    Icons.flash_on,
                    xpGained > 0 ? "+$xpGained" : "0",
                    "XP",
                    AppColors.streakFlame,
                  ),
                  _buildStatItem(
                    Icons.favorite,
                    "${globalHearts.value}",
                    "HP",
                    AppColors.heartCrimson,
                  ),
                  _buildStatItem(
                    Icons.check_circle,
                    "$_score/$_originalQuestionCount",
                    _t("Score", "Skor"),
                    primaryColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            if (!isTestMode) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Icon(
                    index < newStarsCount
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: AppColors.starGold,
                    size: 40,
                  );
                }),
              ),
            ] else ...[
              const Icon(
                Icons.workspace_premium_rounded,
                color: AppColors.starGold,
                size: 60,
              ),
            ],
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          AppButton(
            label: _t("CONTINUE", "LANJUTKAN"),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    final bool isDark = globalDarkMode.value;
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.w900,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentQuestionIndex];
    final double progressPercent =
        _originalQuestionCount > 0 ? (_score) / _originalQuestionCount : 0.0;
    final bool isMultipleChoice = currentQuestion['type'] == 'multiple_choice';
    final int maxSelection = (currentQuestion['maxSelection'] as int?) ?? 1;
    final bool reduceMotion = MediaQuery.disableAnimationsOf(context);

    final String japaneseText =
        (currentQuestion['japanese'] ?? '').toString();
    final String? rawKanji = currentQuestion['kanji'] as String?;
    final String? kanjiText = (rawKanji != null &&
            rawKanji.trim().isNotEmpty &&
            rawKanji.trim() != japaneseText.trim())
        ? rawKanji.trim()
        : null;

    final bool isButtonEnabled = _isAnswered ||
        (isMultipleChoice
            ? selectedOption != null
            : (maxSelection == 1
                ? _selectedWords.length == 1
                : _selectedWords.isNotEmpty));

    return ValueListenableBuilder<bool>(
      valueListenable: globalDarkMode,
      builder: (context, isDark, _) {
        final Color bgColor =
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
        final Color cardColor =
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
        final Color textColor =
            isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
        final Color subTextColor =
            isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
        final Color borderColor =
            isDark ? AppColors.borderDark : AppColors.borderLight;
        final Color primaryColor =
            isDark ? AppColors.primaryDark : AppColors.primaryLight;
        final Color errorColor =
            isDark ? AppColors.errorDark : AppColors.errorLight;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            _showExitConfirmationDialog();
          },
          child: Scaffold(
            backgroundColor: bgColor,
            body: SafeArea(
              child: Column(
                children: [
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
                              label: _t('Exit exercise', 'Keluar latihan'),
                              child: GestureDetector(
                                onTap: _showExitConfirmationDialog,
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
                              isTestMode
                                  ? "UNIT TEST"
                                  : (widget.isReplay
                                      ? "REPLAY QUIZ"
                                      : "UNIT ${widget.unit} • QUIZ"),
                              style: AppTextStyles.labelSmall.copyWith(
                                color: primaryColor,
                                letterSpacing: 2.0,
                              ),
                            ),
                            if (isTestMode)
                              Row(
                                children: [
                                  AppBadge(
                                    label: _formattedTime,
                                    icon: Icons.timer_rounded,
                                    color: _timeLeft <= 60
                                        ? errorColor
                                        : primaryColor,
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  ValueListenableBuilder<int>(
                                    valueListenable: globalHearts,
                                    builder: (context, hearts, child) {
                                      return AppBadge(
                                        label: "$hearts",
                                        icon: Icons.favorite_rounded,
                                        color: AppColors.heartCrimson,
                                      );
                                    },
                                  ),
                                ],
                              )
                            else
                              ValueListenableBuilder<int>(
                                valueListenable: globalHearts,
                                builder: (context, hearts, child) {
                                  return AppBadge(
                                    label: "$hearts",
                                    icon: Icons.favorite_rounded,
                                    color: AppColors.heartCrimson,
                                  );
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppProgressBar(
                          progress: progressPercent,
                          height: 6,
                          color: primaryColor,
                          semanticLabel: _t('Quiz progress', 'Progres kuis'),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: AnimatedSwitcher(
                      duration:
                          reduceMotion ? Duration.zero : AppSpacing.animNormal,
                      switchInCurve: Curves.easeInOut,
                      switchOutCurve: Curves.easeInOut,
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        if (reduceMotion) return child;
                        final offsetAnimation = Tween<Offset>(
                          begin: const Offset(0.0, 0.04),
                          end: Offset.zero,
                        ).animate(animation);

                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: offsetAnimation,
                            child: child,
                          ),
                        );
                      },
                      child: SingleChildScrollView(
                        key: ValueKey<int>(_currentQuestionIndex),
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                          vertical: AppSpacing.sm,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildQuestionHeader(
                              textColor,
                              primaryColor,
                              isDark,
                            ),
                            const SizedBox(height: AppSpacing.xl),

                            Hero(
                              tag: 'quiz_card_$_currentQuestionIndex',
                              child: Material(
                                color: Colors.transparent,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.xxxl,
                                  ),
                                  decoration: BoxDecoration(
                                    color: cardColor,
                                    borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusXxl,
                                    ),
                                    border: Border.all(
                                      color: borderColor,
                                      width: 2,
                                    ),
                                    boxShadow: AppShadows.card(isDark),
                                  ),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.md,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              kanjiText ?? japaneseText,
                                              maxLines: 2,
                                              textAlign: TextAlign.center,
                                              style: AppTextStyles.japaneseHero
                                                  .copyWith(
                                                color: textColor,
                                              ),
                                            ),
                                          ),
                                          if (kanjiText != null) ...[
                                            const SizedBox(
                                              height: AppSpacing.sm,
                                            ),
                                            FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                japaneseText,
                                                maxLines: 2,
                                                textAlign: TextAlign.center,
                                                style: AppTextStyles
                                                    .japaneseTitle
                                                    .copyWith(
                                                  color: subTextColor,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xxl),

                            if (isMultipleChoice) ...[
                              _buildAnimatedOptions(
                                currentQuestion,
                                isDark,
                                reduceMotion,
                              ),
                            ] else ...[
                              _buildWordBankInput(
                                reduceMotion,
                                maxSelection: maxSelection,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: _buildBottomActionBar(
              isButtonEnabled,
              isMultipleChoice,
              currentQuestion,
              reduceMotion,
            ),
          ),
        );
      },
    );
  }

  Widget _buildWordBankInput(bool reduceMotion, {int maxSelection = 1}) {
    final bool isDark = globalDarkMode.value;
    final Color inputBg = isDark
        ? AppColors.surfaceVariantDark
        : AppColors.surfaceVariantLight;
    final Color borderColor =
        isDark ? AppColors.borderDark : AppColors.borderLight;
    final Color subTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          constraints: const BoxConstraints(minHeight: 70),
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: inputBg,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: _selectedWords.isEmpty
              ? Center(
                  child: Text(
                    AppLocalizations.answerSlotPlaceholder(),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: subTextColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
              : Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: _selectedWords
                      .map(
                        (word) => _buildWordTile(
                          word: word,
                          isActive: true,
                          reduceMotion: reduceMotion,
                          onTap: () {
                            if (!_isAnswered) {
                              HapticFeedback.selectionClick();
                              setState(() {
                                _selectedWords.remove(word);
                              });
                            }
                          },
                        ),
                      )
                      .toList(),
                ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.md,
          alignment: WrapAlignment.center,
          children: _availableWords.map((word) {
            final bool isSelected = _selectedWords.contains(word);
            return _buildWordTile(
              word: word,
              isActive: isSelected,
              reduceMotion: reduceMotion,
              onTap: () {
                if (_isAnswered) return;
                HapticFeedback.selectionClick();
                setState(() {
                  if (isSelected) {
                    // Tapping the same chip cancels the selection
                    _selectedWords.remove(word);
                  } else if (maxSelection == 1) {
                    // Single choice: selecting another chip replaces the previous one
                    _selectedWords
                      ..clear()
                      ..add(word);
                  } else {
                    if (_selectedWords.length < maxSelection) {
                      _selectedWords.add(word);
                    } else {
                      _selectedWords
                        ..removeLast()
                        ..add(word);
                    }
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildWordTile({
    required String word,
    required bool isActive,
    required bool reduceMotion,
    required VoidCallback onTap,
  }) {
    final bool isDark = globalDarkMode.value;
    final bool isDisabled = _isAnswered;
    final Color primaryColor =
        isDark ? AppColors.primaryDark : AppColors.primaryLight;

    Color bgColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    Color borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    Color textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    if (isDisabled) {
      bgColor = isDark
          ? AppColors.surfaceVariantDark.withValues(alpha: 0.4)
          : AppColors.surfaceVariantLight.withValues(alpha: 0.5);
      textColor = isDark
          ? AppColors.textSecondaryDark.withValues(alpha: 0.5)
          : AppColors.textSecondaryLight.withValues(alpha: 0.5);
    } else if (isActive) {
      bgColor = isDark
          ? AppColors.primaryContainerDark
          : AppColors.primaryContainerLight;
      borderColor = primaryColor;
      textColor = primaryColor;
    }

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: AnimatedContainer(
        duration: reduceMotion ? Duration.zero : AppSpacing.animNormal,
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Text(
          word,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActionBar(
    bool isButtonEnabled,
    bool isMultipleChoice,
    Map<String, dynamic> currentQuestion,
    bool reduceMotion,
  ) {
    final bool isDark = globalDarkMode.value;
    final Color successColor =
        isDark ? AppColors.successDark : AppColors.successLight;
    final Color errorColor =
        isDark ? AppColors.errorDark : AppColors.errorLight;

    Color panelColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    if (_isAnswered) {
      panelColor = _isCurrentAnswerCorrect
          ? (isDark
              ? AppColors.successContainerDark
              : AppColors.successContainerLight)
          : (isDark
              ? AppColors.errorContainerDark
              : AppColors.errorContainerLight);
    }

    return AnimatedContainer(
      duration: reduceMotion ? Duration.zero : AppSpacing.animNormal,
      curve: Curves.easeInOut,
      padding: EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: panelColor,
        border: Border(
          top: BorderSide(
            color: _isAnswered
                ? Colors.transparent
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: 1,
          ),
        ),
        boxShadow: _isAnswered ? null : AppShadows.navBar(isDark),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isAnswered) ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _isCurrentAnswerCorrect ? successColor : errorColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isCurrentAnswerCorrect
                        ? Icons.check_rounded
                        : Icons.close_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isCurrentAnswerCorrect
                            ? AppLocalizations.excellentLabel()
                            : AppLocalizations.correctAnswerLabel(),
                        style: AppTextStyles.titleLarge.copyWith(
                          color: _isCurrentAnswerCorrect
                              ? successColor
                              : errorColor,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (!_isCurrentAnswerCorrect)
                        Text(
                          isMultipleChoice
                              ? currentQuestion['options']
                                      [currentQuestion['correctIndex']]['text']
                                  .toString()
                              : currentQuestion['answer'].toString(),
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: errorColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          AppButton(
            label: _isAnswered
                ? (_currentQuestionIndex == _questions.length - 1
                    ? AppLocalizations.finishLabel()
                    : AppLocalizations.continueLabel())
                : AppLocalizations.checkAnswer(),
            onPressed: isButtonEnabled
                ? () {
                    if (_isAnswered) {
                      _nextQuestion();
                    } else {
                      _checkAnswer(isMultipleChoice);
                    }
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionHeader(
    Color textColor,
    Color primaryColor,
    bool isDark,
  ) {
    final currentQuestion = _questions[_currentQuestionIndex];
    return Column(
      children: [
        if (widget.hint != null && widget.hint!.trim().isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: isDark ? 0.16 : 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              border: Border.all(
                color: primaryColor.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 16,
                  color: primaryColor,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    widget.hint!,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: primaryColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        Text(
          currentQuestion['question'] ??
              AppLocalizations.wordMeaningQuestion(),
          style: AppTextStyles.headlineMedium.copyWith(
            fontWeight: FontWeight.w900,
            color: textColor,
          ),
          textAlign: TextAlign.center,
        ),
        if (currentQuestion['audio'] != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Semantics(
            button: true,
            label: AppLocalizations.playAudioSemantics(),
            child: GestureDetector(
              onTap: () => SoundManager.playSound(currentQuestion['audio']),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.volume_up_rounded,
                  color: primaryColor,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAnimatedOptions(
    Map<String, dynamic> currentQuestion,
    bool isDark,
    bool reduceMotion,
  ) {
    final options = currentQuestion['options'] as List;
    return Column(
      children: List.generate(options.length, (index) {
        final option = options[index];
        return _buildOption(
          index,
          option['code'],
          option['text'],
          option['romaji'] ?? '',
          currentQuestion['correctIndex'],
          reduceMotion,
        );
      }),
    );
  }

  Widget _buildOption(
    int index,
    String code,
    String text,
    String romaji,
    int correctIndex,
    bool reduceMotion,
  ) {
    final bool isDark = globalDarkMode.value;
    final bool isSelected = selectedOption == index;
    final Color primaryColor =
        isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final Color successColor =
        isDark ? AppColors.successDark : AppColors.successLight;
    final Color errorColor =
        isDark ? AppColors.errorDark : AppColors.errorLight;

    Color borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    Color bgColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    Color letterBoxColor =
        isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight;
    Color letterTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    Color mainTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    if (_isAnswered) {
      if (index == correctIndex) {
        borderColor = successColor;
        bgColor = isDark
            ? AppColors.successContainerDark
            : AppColors.successContainerLight;
        letterBoxColor = successColor;
        letterTextColor = Colors.white;
        mainTextColor = isDark ? AppColors.textPrimaryDark : successColor;
      } else if (isSelected && index != correctIndex) {
        borderColor = errorColor;
        bgColor = isDark
            ? AppColors.errorContainerDark
            : AppColors.errorContainerLight;
        letterBoxColor = errorColor;
        letterTextColor = Colors.white;
        mainTextColor = isDark ? AppColors.textPrimaryDark : errorColor;
      } else {
        bgColor = bgColor.withValues(alpha: 0.5);
        borderColor = borderColor.withValues(alpha: 0.4);
        mainTextColor = mainTextColor.withValues(alpha: 0.4);
      }
    } else if (isSelected) {
      borderColor = primaryColor;
      bgColor = isDark
          ? AppColors.primaryContainerDark
          : AppColors.primaryContainerLight;
      letterBoxColor = primaryColor;
      letterTextColor =
          isDark ? AppColors.onPrimaryDark : AppColors.onPrimaryLight;
      mainTextColor = isDark ? AppColors.textPrimaryDark : primaryColor;
    }

    return GestureDetector(
      onTap: () => _selectOption(index),
      child: AnimatedContainer(
        duration: reduceMotion ? Duration.zero : AppSpacing.animNormal,
        curve: Curves.easeInOut,
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
            width: isSelected ||
                    (_isAnswered && (index == correctIndex || isSelected))
                ? 2.5
                : 1.5,
          ),
          boxShadow: isSelected && !_isAnswered
              ? AppShadows.accentGlow(primaryColor, isDark: isDark)
              : const [],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: reduceMotion ? Duration.zero : AppSpacing.animNormal,
              curve: Curves.easeInOut,
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: letterBoxColor,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Center(
                child: Text(
                  code,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: letterTextColor,
                    fontWeight: FontWeight.w900,
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
                      fontWeight: FontWeight.w900,
                      color: mainTextColor,
                    ),
                  ),
                  if (romaji.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      romaji,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: mainTextColor.withValues(alpha: 0.7),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
