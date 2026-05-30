import 'dart:async'; // 👈 Tambahkan ini untuk Timer
import 'package:flutter/material.dart';
import '../../data/quiz_repository.dart';
import '../../core/sound_manager.dart';
import '../../core/game_manager.dart';

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

  bool _isAnswered = false;
  bool _isCurrentAnswerCorrect = false;

  late List<Map<String, dynamic>> _questions;
  late int _originalQuestionCount;

  // ==========================================
  // ⏳ VARIABEL TIMER KHUSUS UNIT TEST
  // ==========================================
  bool get isTestMode => widget.difficulty == 'test';
  Timer? _countdownTimer;
  int _timeLeft = 900; // 15 Menit

  // STATE WORD BANK
  final List<String> _selectedWords = [];
  final List<String> _availableWords = [];

  final List<String> _decoyDictionary = [
    'ka', 'ki', 'ku', 'ke', 'ko', 'sa', 'shi', 'su', 'se', 'so',
    'ta', 'chi', 'tsu', 'te', 'to', 'na', 'ni', 'nu', 'ne', 'no',
    'sushi', 'sake', 'natsu', 'sakana', 'chika', 'aoi', 'aka', 'ie', 'neko', 'inu'
  ];

  @override
  void initState() {
    super.initState();

    // 🛑 CEK NYAWA DI AWAL: Jika 0, langsung kunci layar dengan Game Over
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (globalHearts.value <= 0) {
        _showGameOverDialog(reason: "Nyawa Habis!");
      }
    });

    var allQuestions = List<Map<String, dynamic>>.from(
        QuizRepository.getQuestions(widget.unit, widget.difficulty, widget.currentStars)
    )..shuffle();

    if (isTestMode) {
      _questions = allQuestions.take(20).toList();
    } else {
      _questions = allQuestions;
    }

    _originalQuestionCount = _questions.length;
    _setupWordBank();

    // 🔥 JIKA MODE TEST, JALANKAN TIMER (TERMASUK REPLAY)!
    if (isTestMode) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel(); // Pastikan timer mati saat keluar layar
    super.dispose();
  }

  // FUNGSI PENGHITUNG WAKTU MUNDUR
  void _startTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _countdownTimer?.cancel();
        _showGameOverDialog(reason: "Waktu Habis!"); // Waktu Habis!
      }
    });
  }

  // Format detik menjadi MM:SS (Contoh: 01:59)
  String get _formattedTime {
    int minutes = _timeLeft ~/ 60;
    int seconds = _timeLeft % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _setupWordBank() {
    _selectedWords.clear();
    _availableWords.clear();

    final currentQ = _questions[_currentQuestionIndex];

    // 🔥 MAIN AUDIO JIKA ADA
    if (currentQ['audio'] != null) {
      SoundManager.playSound(currentQ['audio']);
    }

    if (currentQ['type'] == 'essay') {
      String correctAnswer = currentQ['answer'].toString().toLowerCase();
      _availableWords.add(correctAnswer);

      var decoys = _decoyDictionary.where((d) => d != correctAnswer).toList()..shuffle();
      _availableWords.addAll(decoys.take(3));
      _availableWords.shuffle();
    }
  }

  void _selectOption(int index) {
    if (_isAnswered) return;
    setState(() {
      selectedOption = index;
    });
  }

  Future<void> _checkAnswer(bool isMultipleChoice) async {
    if (_isAnswered) return;

    setState(() {
      _isAnswered = true;
      _isCurrentAnswerCorrect = false;

      if (isMultipleChoice) {
        if (selectedOption == _questions[_currentQuestionIndex]['correctIndex']) {
          _score++;
          _isCurrentAnswerCorrect = true;
        }
      } else {
        String userAnswer = _selectedWords.join('').trim().toLowerCase();
        String correctAnswer = _questions[_currentQuestionIndex]['answer'].toString().toLowerCase();
        if (userAnswer == correctAnswer) {
          _score++;
          _isCurrentAnswerCorrect = true;
        }
      }

      if (_isCurrentAnswerCorrect) {
        SoundManager.playSound('benar.mp3');
        // Hanya beri XP jika bukan replay
        if (!widget.isReplay) {
          GameManager.addXP(25);
        }
      } else {
        SoundManager.playSound('salah.mp3');
      }
    });

    if (!_isCurrentAnswerCorrect) {
      // 🔥 WAJIB AWAIT agar nyawa berkurang di memory sebelum dicek
      await GameManager.decreaseHeart();

      if (widget.onHeartDecreased != null) {
        widget.onHeartDecreased!(globalHearts.value);
      }

      if (globalHearts.value <= 0) {
        _countdownTimer?.cancel();
        _showGameOverDialog(reason: "Nyawa Habis!");
        return;
      }

      setState(() {
        // Lempar soal salah ke belakang
        _questions.add(Map<String, dynamic>.from(_questions[_currentQuestionIndex]));
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
      _countdownTimer?.cancel(); // Hentikan timer jika selesai
      bool isPassed = true;
      if (isPassed && widget.onQuizPassed != null) {
        widget.onQuizPassed!();
      }
      _showResultDialog(isPassed);
    }
  }

  // ==========================================
  // 🚪 POP-UP KONFIRMASI KELUAR LATIHAN
  // ==========================================
  void _showExitConfirmationDialog() {
    SoundManager.playSound('klik.mp3');
    final bool isDark = globalDarkMode.value;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Column(
          children: [
            const Icon(Icons.warning_rounded, color: Color(0xFFE53935), size: 48),
            const SizedBox(height: 12),
            const Text('ちょっと待って!', style: TextStyle(color: Color(0xFFE53935), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
            Text('Tunggu Dulu!', style: TextStyle(fontWeight: FontWeight.w900, color: isDark ? Colors.white : const Color(0xFF333333), fontSize: 22), textAlign: TextAlign.center),
          ],
        ),
        content: Text(
          'Yakin ingin keluar? Progres dan jawaban benarmu di sesi ini akan hangus loh!',
          textAlign: TextAlign.center,
          style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF666666), height: 1.5, fontSize: 15),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFCC6633), width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('BATAL', style: TextStyle(color: Color(0xFFCC6633), fontWeight: FontWeight.w900, letterSpacing: 1)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53935),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text('KELUAR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  void _showGameOverDialog({String? reason}) {
    SoundManager.playSound('defeat.mp3');
    final bool isDark = globalDarkMode.value;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false, // 🔒 Kunci tombol back fisik agar tidak bisa di-bypass
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          title: Column(
            children: [
              const Icon(Icons.heart_broken_rounded, color: Color(0xFFE53935), size: 64),
              const SizedBox(height: 16),
              Text(
                reason != null ? "❌ $reason" : 'Gagal Itu Wajar!',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFFE53935),
                  fontSize: 22,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                reason == "Waktu Habis!"
                    ? 'Waktu ujianmu telah habis! Ayo pulihkan nyawamu lalu coba selesaikan lebih cepat.'
                    : 'Jangan menyerah! Setiap kesalahan adalah langkah menuju kesuksesan. Yuk, pulihkan nyawa dan coba lagi!',
                textAlign: TextAlign.center,
                style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF4B4B4B), height: 1.5, fontSize: 16),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.flash_on, color: Colors.orange, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    "Butuh 150 XP untuk 1 Nyawa",
                    style: TextStyle(
                      color: isDark ? Colors.orangeAccent : Colors.orange.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          actions: [
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFCC6633),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      bool success = await GameManager.buyHeartWithXP();
                      if (!context.mounted) return;
                      if (success) {
                        Navigator.pop(context); // Tutup dialog Game Over
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("XP tidak cukup!")),
                        );
                      }
                    },
                    child: const Text('BELI NYAWA (150 XP)',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1)),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Text(
                    'KEMBALI KE MENU',
                    style: TextStyle(color: isDark ? Colors.white60 : Colors.grey, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showResultDialog(bool isPassed) {
    int newStarsCount = isPassed ? (widget.currentStars + 1).clamp(0, 3) : widget.currentStars;
    int xpGained = !widget.isReplay ? _score * 25 : 0;
    SoundManager.playSound('victory.mp3');
    final bool isDark = globalDarkMode.value;

    String motivation = "Wah hebat! Terus asah kemampuanmu!";
    if (_score == _originalQuestionCount) {
      motivation = "Luar biasa! Kamu semakin dekat dengan kefasihan!";
    } else if (_score > _originalQuestionCount / 2) {
      motivation = "Keren sekali! Jangan berhenti di sini!";
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text(
          isTestMode ? '🏆 Unit Test Lulus!' : '🎉 Latihan Selesai!',
          style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF4CAF50), fontSize: 24),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              motivation,
              textAlign: TextAlign.center,
              style: TextStyle(color: isDark ? Colors.white : const Color(0xFF333333), fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF9F6F0),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(Icons.flash_on, xpGained > 0 ? "+$xpGained" : "0", "XP", Colors.orange),
                  _buildStatItem(Icons.favorite, "${globalHearts.value}", "HP", Colors.red),
                  _buildStatItem(Icons.check_circle, "$_score/$_originalQuestionCount", "Skor", Colors.green),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // JIKA MODE TEST, SEMBUNYIKAN BINTANG. JIKA NORMAL, TAMPILKAN BINTANG.
            if (!isTestMode) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Icon(
                    index < newStarsCount ? Icons.star_rounded : Icons.star_border_rounded,
                    color: const Color(0xFFFFC107),
                    size: 40,
                  );
                }),
              ),
            ] else ...[
              const Icon(Icons.workspace_premium_rounded, color: Color(0xFFFFC107), size: 60),
            ],
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCC6633),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('LANJUTKAN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    final bool isDark = globalDarkMode.value;
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: isDark ? Colors.white : Colors.black87)),
        Text(label, style: TextStyle(color: isDark ? Colors.white54 : Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentQuestionIndex];
    double progressPercent = (_score) / _originalQuestionCount;
    bool isMultipleChoice = currentQuestion['type'] == 'multiple_choice';

    bool isButtonEnabled = _isAnswered ||
        (isMultipleChoice ? selectedOption != null : _selectedWords.isNotEmpty);

    return ValueListenableBuilder<bool>(
      valueListenable: globalDarkMode,
      builder: (context, isDark, _) {
        final Color bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF9F6F0);
        final Color cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
        final Color textColor = isDark ? Colors.white : const Color(0xFF4A453F);
        final Color subTextColor = isDark ? Colors.white70 : const Color(0xFF8C8A87);
        final Color borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFE8E3DA);

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
                  // HEADER & PROGRESS BAR
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => _showExitConfirmationDialog(),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderColor),
                              ),
                              child: Icon(Icons.close_rounded, color: subTextColor, size: 24),
                            ),
                          ),
                          Text(
                            isTestMode ? "UNIT TEST" : (widget.isReplay ? "REPLAY QUIZ" : "UNIT ${widget.unit} • QUIZ"),
                            style: const TextStyle(
                              color: Color(0xFFCC6633), 
                              fontWeight: FontWeight.w900, 
                              fontSize: 11, 
                              letterSpacing: 2.2
                            ),
                          ),

                          // ==========================================
                          // 🔁 LOGIKA UI KANAN ATAS (TIMER VS NYAWA)
                          // ==========================================
                          if (isTestMode)
                          // UI TIMER & LIVES KHUSUS UNIT TEST
                            Row(
                              children: [
                                // TIMER
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _timeLeft <= 60 ? Colors.red.withValues(alpha: 0.15) : const Color(0xFFCC6633).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: _timeLeft <= 60 ? Colors.red : Colors.transparent),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.timer_rounded, color: _timeLeft <= 60 ? Colors.red : const Color(0xFFCC6633), size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                          _formattedTime,
                                          style: TextStyle(
                                              color: _timeLeft <= 60 ? Colors.red : const Color(0xFFCC6633),
                                              fontWeight: FontWeight.w900,
                                              fontSize: 14
                                          )
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // LIVES (NYAWA)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE53935).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.favorite_rounded, color: Color(0xFFE53935), size: 16),
                                      const SizedBox(width: 4),
                                      ValueListenableBuilder<int>(
                                        valueListenable: globalHearts,
                                        builder: (context, hearts, child) {
                                          return Text(
                                            "$hearts",
                                            style: const TextStyle(color: Color(0xFFE53935), fontWeight: FontWeight.w900, fontSize: 14)
                                          );
                                        }
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          else
                          // UI NYAWA UNTUK MODE NORMAL
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                              child: Row(
                                children: [
                                  const Icon(Icons.favorite_rounded, color: Color(0xFFE53935), size: 20),
                                  const SizedBox(width: 4),
                                  ValueListenableBuilder<int>(
                                      valueListenable: globalHearts,
                                      builder: (context, hearts, child) {
                                        return Text("$hearts", style: const TextStyle(color: Color(0xFFE53935), fontWeight: FontWeight.w900, fontSize: 16));
                                      }
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const SizedBox(height: 10),
                      Stack(
                        children: [
                          Container(
                            height: 6,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: borderColor, 
                              borderRadius: BorderRadius.circular(10)
                            ),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                            height: 6,
                            width: MediaQuery.of(context).size.width * 0.85 * progressPercent,
                            decoration: BoxDecoration(
                              color: const Color(0xFFCC6633), 
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFCC6633).withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2)
                                )
                              ]
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // KONTEN SOAL & JAWABAN DENGAN ANIMASI
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    switchInCurve: Curves.easeInOut,
                    switchOutCurve: Curves.easeInOut,
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      var offsetAnimation = Tween<Offset>(
                        begin: const Offset(0.0, 0.05),
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
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildQuestionHeader(textColor),
                          const SizedBox(height: 24),

                          Hero(
                            tag: 'quiz_card_$_currentQuestionIndex',
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(color: borderColor, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFCC6633).withValues(alpha: 0.08), 
                                    blurRadius: 20, 
                                    offset: const Offset(0, 10)
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      currentQuestion['japanese'],
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 64,
                                        fontWeight: FontWeight.w900,
                                        color: isDark ? Colors.white : const Color(0xFF333333),
                                        letterSpacing: 2
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          if (isMultipleChoice) ...[
                            _buildAnimatedOptions(currentQuestion, isDark)
                          ] else ...[
                            _buildWordBankInput(),
                          ]
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomActionBar(isButtonEnabled, isMultipleChoice, currentQuestion),
        ),
      );
    },
  );
}


  // WIDGET WORD BANK
  Widget _buildWordBankInput() {
    final bool isDark = globalDarkMode.value;
    final Color inputBg = isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFEFEBE1);
    final Color borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFE8E3DA);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          constraints: const BoxConstraints(minHeight: 70),
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: inputBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: _selectedWords.isEmpty
              ? Center(child: Text("Ketuk pilihan di bawah untuk mengisi", style: TextStyle(color: isDark ? Colors.white38 : const Color(0xFFB5B0A8), fontStyle: FontStyle.italic)))
              : Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: _selectedWords.map((word) => _buildWordTile(
                word: word,
                isActive: true,
                onTap: () {
                  if (!_isAnswered) {
                    setState(() {
                      _selectedWords.remove(word);
                      _availableWords.add(word);
                    });
                  }
                }
            )).toList(),
          ),
        ),
        const SizedBox(height: 30),

        Wrap(
          spacing: 12,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: _availableWords.map((word) => _buildWordTile(
              word: word,
              isActive: false,
              onTap: () {
                if (!_isAnswered) {
                  setState(() {
                    _availableWords.remove(word);
                    _selectedWords.add(word);
                  });
                }
              }
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildWordTile({required String word, required bool isActive, required VoidCallback onTap}) {
    final bool isDark = globalDarkMode.value;
    bool isDisabled = _isAnswered;

    Color bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    Color borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFD6D1C4);
    Color textColor = isDark ? Colors.white : const Color(0xFF4B4B4B);

    if (isDisabled) {
      bgColor = isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFE8E3DA).withValues(alpha: 0.5);
      borderColor = isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE8E3DA);
      textColor = isDark ? Colors.white38 : const Color(0xFFB5B0A8);
    } else if (isActive) {
      bgColor = isDark ? const Color(0xFF4A2B18) : const Color(0xFFF6E7DC);
      borderColor = const Color(0xFFCC6633);
      textColor = const Color(0xFFCC6633);
    }

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
              color: borderColor,
              width: 1.5
          ),
        ),
        child: Text(
          word,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActionBar(bool isButtonEnabled, bool isMultipleChoice, Map<String, dynamic> currentQuestion) {
    final bool isDark = globalDarkMode.value;
    Color panelColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    if (_isAnswered) {
      panelColor = _isCurrentAnswerCorrect
          ? (isDark ? const Color(0xFF1B3320) : const Color(0xFFE8F5E9))
          : (isDark ? const Color(0xFF331B1B) : const Color(0xFFFFEBEE));
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 20,
          bottom: MediaQuery.of(context).padding.bottom + 20
      ),
      decoration: BoxDecoration(
        color: panelColor,
        border: Border(top: BorderSide(color: _isAnswered ? Colors.transparent : (isDark ? const Color(0xFF333333) : const Color(0xFFE8E3DA)), width: 1)),
        boxShadow: _isAnswered ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, -5))],
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
                    color: _isCurrentAnswerCorrect ? Colors.green : const Color(0xFFE53935),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isCurrentAnswerCorrect ? Icons.check_rounded : Icons.close_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isCurrentAnswerCorrect ? "Luar Biasa!" : "Jawaban yang Benar:",
                        style: TextStyle(
                          color: _isCurrentAnswerCorrect ? Colors.green.shade700 : const Color(0xFFE53935),
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      if (!_isCurrentAnswerCorrect)
                        Text(
                          isMultipleChoice
                              ? currentQuestion['options'][currentQuestion['correctIndex']]['text']
                              : currentQuestion['answer'],
                          style: TextStyle(
                            color: isDark ? Colors.redAccent : const Color(0xFFE53935),
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isAnswered
                    ? (_isCurrentAnswerCorrect ? const Color(0xFF4CAF50) : const Color(0xFFE53935))
                    : const Color(0xFFCC6633),
                disabledBackgroundColor: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE8E3DA),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: _isAnswered ? 0 : (isButtonEnabled ? 4 : 0),
              ),
              onPressed: isButtonEnabled
                  ? () {
                if (_isAnswered) {
                  _nextQuestion();
                } else {
                  _checkAnswer(isMultipleChoice);
                }
              }
                  : null,
              child: Text(
                _isAnswered
                    ? (_currentQuestionIndex == _questions.length - 1 ? "SELESAI" : "LANJUTKAN")
                    : "CEK JAWABAN",
                style: TextStyle(
                    color: isButtonEnabled ? Colors.white : (isDark ? Colors.white24 : const Color(0xFFAFAFAF)),
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    letterSpacing: 1
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionHeader(Color textColor) {
    final currentQuestion = _questions[_currentQuestionIndex];
    return Column(
      children: [
        if (widget.hint != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: const EdgeInsets.only(bottom: 16),
          ),
        ],
        Text(
          currentQuestion['question'] ?? 'Terjemahkan karakter ini:',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: textColor,
          ),
          textAlign: TextAlign.center,
        ),
        if (currentQuestion['audio'] != null) ...[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => SoundManager.playSound(currentQuestion['audio']),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFCC6633).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.volume_up_rounded, color: Color(0xFFCC6633), size: 32),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAnimatedOptions(Map<String, dynamic> currentQuestion, bool isDark) {
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
        );
      }),
    );
  }

  Widget _buildOption(int index, String code, String text, String romaji, int correctIndex) {
    final bool isDark = globalDarkMode.value;
    bool isSelected = selectedOption == index;

    Color borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFE8E3DA);
    Color bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    Color letterBoxColor = isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF9F6F0);
    Color letterTextColor = isDark ? Colors.white60 : const Color(0xFF8C8A87);
    Color mainTextColor = isDark ? Colors.white : const Color(0xFF4B4B4B);

    if (_isAnswered) {
      if (index == correctIndex) {
        borderColor = const Color(0xFF4CAF50);
        bgColor = isDark ? const Color(0xFF1B3320) : const Color(0xFFE8F5E9);
        letterBoxColor = const Color(0xFF4CAF50);
        letterTextColor = Colors.white;
        mainTextColor = isDark ? Colors.white : const Color(0xFF2E7D32);
      } else if (isSelected && index != correctIndex) {
        borderColor = const Color(0xFFE53935);
        bgColor = isDark ? const Color(0xFF331B1B) : const Color(0xFFFFEBEE);
        letterBoxColor = const Color(0xFFE53935);
        letterTextColor = Colors.white;
        mainTextColor = isDark ? Colors.white : const Color(0xFFC62828);
      } else {
        bgColor = isDark ? Colors.white.withValues(alpha: 0.02) : Colors.white.withValues(alpha: 0.5);
        borderColor = isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFE8E3DA).withValues(alpha: 0.5);
        mainTextColor = isDark ? Colors.white24 : const Color(0xFF8C8A87).withValues(alpha: 0.5);
      }
    } else if (isSelected) {
      borderColor = const Color(0xFFCC6633);
      bgColor = isDark ? const Color(0xFF4A2B18) : const Color(0xFFF6E7DC);
      letterBoxColor = const Color(0xFFCC6633);
      letterTextColor = Colors.white;
      mainTextColor = const Color(0xFFCC6633);
    }

    return GestureDetector(
      onTap: () => _selectOption(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: isSelected || (_isAnswered && (index == correctIndex || isSelected)) ? 2.5 : 1.5),
          boxShadow: isSelected && !_isAnswered ? [BoxShadow(color: const Color(0xFFCC6633).withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))] : [],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: letterBoxColor, borderRadius: BorderRadius.circular(10)),
              child: Center(child: Text(code, style: TextStyle(color: letterTextColor, fontWeight: FontWeight.w900, fontSize: 16))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(text, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: mainTextColor)),
                  if (romaji.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(romaji, style: TextStyle(fontSize: 12, color: mainTextColor.withValues(alpha: 0.7), fontWeight: FontWeight.bold)),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
