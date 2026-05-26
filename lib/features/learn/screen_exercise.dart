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

  const ExerciseScreen({
    super.key,
    this.unit = 1,
    this.difficulty = 'basic',
    this.currentStars = 0,
    this.currentHearts = 5,
    this.onQuizPassed,
    this.onHeartDecreased,
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
  int _timeLeft = 1200;

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
    _questions = List<Map<String, dynamic>>.from(
        QuizRepository.getQuestions(widget.unit, widget.difficulty, widget.currentStars)
    )..shuffle();

    _originalQuestionCount = _questions.length;
    _setupWordBank();

    // 🔥 JIKA MODE TEST, JALANKAN TIMER!
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
        _showTimeUpDialog(); // Waktu Habis!
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

  void _checkAnswer(bool isMultipleChoice) {
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
        GameManager.addXP(75);
      } else {
        SoundManager.playSound('salah.mp3');

        // JIKA MODE TEST, JANGAN KURANGI NYAWA UTAMA. HUKUMANNYA HANYA BUANG-BUANG WAKTU TIMER!
        if (!isTestMode) {
          GameManager.decreaseHeart();
          if (widget.onHeartDecreased != null) {
            widget.onHeartDecreased!(globalHearts.value);
          }
        }

        // Lempar soal salah ke belakang
        _questions.add(Map<String, dynamic>.from(_questions[_currentQuestionIndex]));
      }
    });
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        title: const Column(
          children: [
            Icon(Icons.warning_rounded, color: Color(0xFFE53935), size: 48),
            SizedBox(height: 12),
            Text('ちょっと待って!', style: TextStyle(color: Color(0xFFE53935), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
            Text('Tunggu Dulu!', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF333333), fontSize: 22), textAlign: TextAlign.center),
          ],
        ),
        content: const Text(
          'Yakin ingin keluar? Progres dan jawaban benarmu di sesi ini akan hangus loh!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF666666), height: 1.5, fontSize: 15),
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

  // DIALOG WAKTU HABIS (KHUSUS UNIT TEST)
  void _showTimeUpDialog() {
    SoundManager.playSound('salah.mp3');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: const Text('⏰ Waktu Habis!', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFE53935)), textAlign: TextAlign.center),
        content: const Text(
            'Kamu gagal menyelesaikan Unit Test dalam batas waktu yang ditentukan. Jangan menyerah, coba lagi!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF4B4B4B), height: 1.5)
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('KEMBALI KE MENU', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)),
            ),
          )
        ],
      ),
    );
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: const Text('😢 Nyawa Habis!', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFE53935)), textAlign: TextAlign.center),
        content: const Text(
            'Kamu telah kehabisan nyawa. Tunggu beberapa saat agar nyawa pulih kembali, atau beli nyawa menggunakan XP di halaman utama.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF4B4B4B), height: 1.5)
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCC6633),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('KEMBALI KE MENU', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)),
            ),
          )
        ],
      ),
    );
  }

  void _showResultDialog(bool isPassed) {
    int newStarsCount = isPassed ? (widget.currentStars + 1).clamp(0, 3) : widget.currentStars;
    SoundManager.playSound('benar.mp3');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Text(
          isTestMode ? '🏆 Unit Test Lulus!' : '🎉 Latihan Sempurna!',
          style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF4CAF50)),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Jawaban Benar: $_originalQuestionCount / $_originalQuestionCount',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF4B4B4B), fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // JIKA MODE TEST, SEMBUNYIKAN BINTANG. JIKA NORMAL, TAMPILKAN BINTANG.
            if (!isTestMode) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Icon(
                    index < newStarsCount ? Icons.star_rounded : Icons.star_border_rounded,
                    color: const Color(0xFFFFC107),
                    size: 48,
                  );
                }),
              ),
              const SizedBox(height: 20),
            ] else ...[
              const Icon(Icons.workspace_premium_rounded, color: Color(0xFFFFC107), size: 70),
              const SizedBox(height: 20),
            ],

            Text(
              isTestMode
                  ? "Luar Biasa! Kamu berhasil membuktikan kemampuanmu dengan menyelesaikan ujian sebelum waktu habis."
                  : (newStarsCount >= 3
                  ? "Luar Biasa! Anda telah menaklukkan rintangan dan menguasai tahap ini sepenuhnya!"
                  : "Kerja Bagus! Anda berhasil merampungkan semua soal."),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF666666), fontSize: 14, height: 1.5),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCC6633),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('LANJUTKAN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentQuestionIndex];
    double progressPercent = (_score) / _originalQuestionCount;
    bool isMultipleChoice = currentQuestion['type'] == 'multiple_choice';

    bool isButtonEnabled = _isAnswered ||
        (isMultipleChoice ? selectedOption != null : _selectedWords.isNotEmpty);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0),
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
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE8E3DA))),
                          child: const Icon(Icons.close_rounded, color: Color(0xFF8C8A87), size: 24),
                        ),
                      ),
                      Text(
                        isTestMode ? "UNIT TEST" : "MIRAIKU - ${widget.difficulty.toUpperCase()}",
                        style: const TextStyle(color: Color(0xFFCC6633), fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.5),
                      ),

                      // ==========================================
                      // 🔁 LOGIKA UI KANAN ATAS (TIMER VS NYAWA)
                      // ==========================================
                      if (isTestMode)
                      // UI TIMER KHUSUS UNIT TEST
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: _timeLeft <= 30 ? Colors.red.withValues(alpha: 0.15) : const Color(0xFFCC6633).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _timeLeft <= 30 ? Colors.red : Colors.transparent),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.timer_rounded, color: _timeLeft <= 30 ? Colors.red : const Color(0xFFCC6633), size: 20),
                              const SizedBox(width: 6),
                              Text(
                                  _formattedTime,
                                  style: TextStyle(
                                      color: _timeLeft <= 30 ? Colors.red : const Color(0xFFCC6633),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16
                                  )
                              ),
                            ],
                          ),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("PROGRES BELAJAR", style: TextStyle(color: Color(0xFF8C8A87), fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1)),
                      Text("$_score/$_originalQuestionCount", style: const TextStyle(color: Color(0xFF4B4B4B), fontSize: 14, fontWeight: FontWeight.w900)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Stack(
                    children: [
                      Container(
                        height: 10,
                        width: double.infinity,
                        decoration: BoxDecoration(color: const Color(0xFFE8E3DA), borderRadius: BorderRadius.circular(10)),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutCubic,
                        height: 10,
                        width: MediaQuery.of(context).size.width * 0.85 * progressPercent,
                        decoration: BoxDecoration(color: const Color(0xFFCC6633), borderRadius: BorderRadius.circular(10)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // KONTEN SOAL & JAWABAN
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      currentQuestion['question'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: Color(0xFF4B4B4B), fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE8E3DA), width: 1.5),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFFCC6633).withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 8)),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          currentQuestion['japanese'],
                          style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w900, color: Color(0xFF333333)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    if (isMultipleChoice) ...[
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: currentQuestion['options'].length,
                        itemBuilder: (context, index) {
                          final option = currentQuestion['options'][index];
                          return _buildOption(index, option['code'], option['text'], option['romaji'], currentQuestion['correctIndex']);
                        },
                      ),
                    ] else ...[
                      _buildWordBankInput(),
                    ]
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: _buildBottomActionBar(isButtonEnabled, isMultipleChoice, currentQuestion),
    );
  }

  // WIDGET WORD BANK
  Widget _buildWordBankInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          constraints: const BoxConstraints(minHeight: 70),
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEFEBE1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE8E3DA), width: 2),
          ),
          child: _selectedWords.isEmpty
              ? const Center(child: Text("Ketuk pilihan di bawah untuk mengisi", style: TextStyle(color: Color(0xFFB5B0A8), fontStyle: FontStyle.italic)))
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
    bool isDisabled = _isAnswered;

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isDisabled ? const Color(0xFFE8E3DA).withValues(alpha: 0.5) : (isActive ? const Color(0xFFF6E7DC) : Colors.white),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
              color: isDisabled ? const Color(0xFFE8E3DA) : (isActive ? const Color(0xFFCC6633) : const Color(0xFFD6D1C4)),
              width: 1.5
          ),
        ),
        child: Text(
          word,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: isDisabled ? const Color(0xFFB5B0A8) : (isActive ? const Color(0xFFCC6633) : const Color(0xFF4B4B4B)),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActionBar(bool isButtonEnabled, bool isMultipleChoice, Map<String, dynamic> currentQuestion) {
    Color panelColor = Colors.white;
    if (_isAnswered) {
      panelColor = _isCurrentAnswerCorrect ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 20,
          bottom: MediaQuery.of(context).padding.bottom + 20
      ),
      decoration: BoxDecoration(
        color: panelColor,
        border: Border(top: BorderSide(color: _isAnswered ? Colors.transparent : const Color(0xFFE8E3DA), width: 1)),
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
                          style: const TextStyle(
                            color: Color(0xFFE53935),
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
                disabledBackgroundColor: const Color(0xFFE8E3DA),
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
                    color: isButtonEnabled ? Colors.white : const Color(0xFFAFAFAF),
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

  Widget _buildOption(int index, String code, String text, String romaji, int correctIndex) {
    bool isSelected = selectedOption == index;
    Color borderColor = const Color(0xFFE8E3DA);
    Color bgColor = Colors.white;
    Color letterBoxColor = const Color(0xFFF9F6F0);
    Color letterTextColor = const Color(0xFF8C8A87);
    Color mainTextColor = const Color(0xFF4B4B4B);

    if (_isAnswered) {
      if (index == correctIndex) {
        borderColor = const Color(0xFF4CAF50);
        bgColor = const Color(0xFFE8F5E9);
        letterBoxColor = const Color(0xFF4CAF50);
        letterTextColor = Colors.white;
        mainTextColor = const Color(0xFF2E7D32);
      } else if (isSelected && index != correctIndex) {
        borderColor = const Color(0xFFE53935);
        bgColor = const Color(0xFFFFEBEE);
        letterBoxColor = const Color(0xFFE53935);
        letterTextColor = Colors.white;
        mainTextColor = const Color(0xFFC62828);
      } else {
        bgColor = Colors.white.withValues(alpha: 0.5);
        borderColor = const Color(0xFFE8E3DA).withValues(alpha: 0.5);
        mainTextColor = const Color(0xFF8C8A87).withValues(alpha: 0.5);
      }
    } else if (isSelected) {
      borderColor = const Color(0xFFCC6633);
      bgColor = const Color(0xFFF6E7DC);
      letterBoxColor = const Color(0xFFCC6633);
      letterTextColor = Colors.white;
      mainTextColor = const Color(0xFFCC6633);
    }

    return GestureDetector(
      onTap: () => _selectOption(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
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
              duration: const Duration(milliseconds: 200),
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