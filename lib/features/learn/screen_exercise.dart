import 'package:flutter/material.dart';
import '../../data/quiz_repository.dart'; // Pastikan path sesuai struktur projek Anda
import '../../core/sound_manager.dart';// IMPORT SOUND MANAGER DI SINI (Sesuaikan path-nya jika perlu)

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
    required this.currentHearts,
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
  late int _localHearts;

  late List<Map<String, dynamic>> _questions;
  final TextEditingController _essayController = TextEditingController();
  bool _isEssayCorrect = false;

  @override
  void initState() {
    super.initState();
    _localHearts = widget.currentHearts;
    _questions = QuizRepository.getQuestions(widget.unit, widget.difficulty, widget.currentStars);
  }

  @override
  void dispose() {
    _essayController.dispose();
    super.dispose();
  }

  void _selectOption(int index) {
    if (_isAnswered) return;
    setState(() {
      selectedOption = index;
    });
    // OPTIONAL: Bisa tambah efek suara klik tombol di sini
    // SoundManager.playSound('klik.mp3');
  }

  void _checkAnswer(bool isMultipleChoice) {
    if (_isAnswered) return;

    setState(() {
      _isAnswered = true;
      bool isCorrect = false;

      if (isMultipleChoice) {
        if (selectedOption == _questions[_currentQuestionIndex]['correctIndex']) {
          _score++;
          isCorrect = true;
        }
      } else {
        String userAnswer = _essayController.text.trim().toLowerCase();
        String correctAnswer = _questions[_currentQuestionIndex]['answer'].toString().toLowerCase();
        if (userAnswer == correctAnswer) {
          _isEssayCorrect = true;
          _score++;
          isCorrect = true;
        }
      }

      // ========================================================
      // 🎶 LOGIKA AUDIO: JAWABAN BENAR / SALAH
      // ========================================================
      if (isCorrect) {
        SoundManager.playSound('benar.mp3'); // Panggil file benar.mp3
      } else {
        SoundManager.playSound('salah.mp3'); // Panggil file salah.mp3
        _localHearts--;
        if (widget.onHeartDecreased != null) {
          widget.onHeartDecreased!(_localHearts);
        }
      }
    });
  }

  void _nextQuestion() {
    // Jika jawaban salah terakhir membuat nyawa habis
    if (_localHearts <= 0) {
      Navigator.pop(context);
      return;
    }

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        selectedOption = null;
        _isAnswered = false;
        _essayController.clear();
        _isEssayCorrect = false;
      });
    } else {
      // Kelulusan kuis: Minimal benar 8 dari 10 soal (> 7)
      bool isPassed = _score > 7;

      if (isPassed && widget.onQuizPassed != null) {
        widget.onQuizPassed!();
      }
      _showResultDialog(isPassed);
    }
  }

  void _showResultDialog(bool isPassed) {
    int newStarsCount = isPassed ? (widget.currentStars + 1).clamp(0, 3) : widget.currentStars;

    // ========================================================
    // 🎶 LOGIKA AUDIO: HASIL AKHIR KUIS (LULUS/GAGAL)
    // ========================================================
    if (isPassed) {
      // Anda bisa mengganti 'sukses_level.mp3' dengan file suara tepuk tangan/fanfare
      SoundManager.playSound('benar.mp3'); // Sementara pakai benar.mp3
    } else {
      // Anda bisa mengganti dengan suara game over
      SoundManager.playSound('salah.mp3'); // Sementara pakai salah.mp3
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFFF9F6F0),
        title: Text(
          isPassed ? '🎉 Latihan Berhasil!' : '😢 Anda Gagal',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF333333)),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Skor Anda: $_score / ${_questions.length}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF4B4B4B), fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Icon(
                  index < newStarsCount ? Icons.star_rounded : Icons.star_border_rounded,
                  color: const Color(0xFFCC6633),
                  size: 36,
                );
              }),
            ),
            const SizedBox(height: 16),
            Text(
              isPassed
                  ? (newStarsCount >= 3
                  ? "Selamat! Anda telah menguasai tahapan ini dengan total 3 bintang penuh."
                  : "Anda berhasil mendapatkan bintang ke-$newStarsCount! Masuk kembali untuk menyelesaikan kuis berikutnya.")
                  : "Skor kelulusan harus lebih besar dari 7 (>7). Ayo coba lagi untuk meraih bintang berikutnya!",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF666666), fontSize: 13),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCC6633),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context); // Tutup dialog
              Navigator.pop(context); // Keluar dari kuis
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text('KEMBALI KE PETA BELAJAR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentQuestionIndex];
    double progressPercent = (_currentQuestionIndex + 1) / _questions.length;
    bool isMultipleChoice = currentQuestion['type'] == 'multiple_choice';

    bool isButtonEnabled = _isAnswered ||
        (isMultipleChoice ? selectedOption != null : _essayController.text.isNotEmpty);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Color(0xFF333333), size: 28),
                  ),
                  Text(
                    "MIRAIKU - ${widget.difficulty.toUpperCase()}",
                    style: const TextStyle(
                      color: Color(0xFFCC6633),
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      letterSpacing: 1,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.favorite, color: Colors.red, size: 22),
                      const SizedBox(width: 4),
                      Text("$_localHearts", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("SOAL KE-${_currentQuestionIndex + 1}", style: const TextStyle(color: Color(0xFF8C8A87), fontSize: 12, fontWeight: FontWeight.w600)),
                  Text("${_currentQuestionIndex + 1}/${_questions.length}", style: const TextStyle(color: Color(0xFF4B4B4B), fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              Stack(
                children: [
                  Container(
                    height: 6,
                    width: double.infinity,
                    decoration: BoxDecoration(color: const Color(0xFFE8E3DA), borderRadius: BorderRadius.circular(4)),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 6,
                    width: MediaQuery.of(context).size.width * 0.85 * progressPercent,
                    decoration: BoxDecoration(color: const Color(0xFFCC6633), borderRadius: BorderRadius.circular(4)),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              Center(
                child: Text(
                  currentQuestion['question'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: Color(0xFF4B4B4B)),
                ),
              ),
              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 30),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFEBE1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE8E3DA)),
                ),
                child: Center(
                  child: Text(
                    currentQuestion['japanese'],
                    style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Expanded(
                child: isMultipleChoice
                    ? Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: currentQuestion['options'].length,
                        itemBuilder: (context, index) {
                          final option = currentQuestion['options'][index];
                          return _buildOption(index, option['code'], option['text'], option['romaji'], currentQuestion['correctIndex']);
                        },
                      ),
                    ),
                    if (_isAnswered) _buildFeedbackBanner(selectedOption == currentQuestion['correctIndex'], "Kunci Jawaban: ${currentQuestion['options'][currentQuestion['correctIndex']]['text']}"),
                  ],
                )
                    : _buildEssayInput(),
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 20.0, top: 10),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFCC6633),
                      disabledBackgroundColor: const Color(0xFFE8E3DA),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                          color: isButtonEnabled ? Colors.white : const Color(0xFF8C8A87),
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackBanner(bool isCorrect, String correctKeyText) {
    Color feedbackColor = isCorrect ? Colors.green : Colors.red;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: isCorrect ? Colors.green[50] : Colors.red[50], borderRadius: BorderRadius.circular(8)),
      child: Text(
        isCorrect ? "Keren! Jawaban Anda Tepat." : "Salah! $correctKeyText",
        style: TextStyle(color: feedbackColor, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildEssayInput() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Jawaban Anda (Romaji):", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF333333))),
          const SizedBox(height: 8),
          TextField(
            controller: _essayController,
            enabled: !_isAnswered,
            onChanged: (text) => setState(() {}),
            decoration: InputDecoration(
              hintText: "Contoh: hitotsu",
              filled: true,
              fillColor: Colors.white,
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCC6633), width: 2)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE8E3DA))),
              disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _isAnswered ? (_isEssayCorrect ? Colors.green : Colors.red) : Colors.grey, width: 2)),
            ),
          ),
          if (_isAnswered) ...[
            const SizedBox(height: 16),
            _buildFeedbackBanner(_isEssayCorrect, "Kunci Jawaban: ${_questions[_currentQuestionIndex]['answer']}"),
          ]
        ],
      ),
    );
  }

  Widget _buildOption(int index, String code, String text, String romaji, int correctIndex) {
    bool isSelected = selectedOption == index;
    Color borderColor = const Color(0xFFE8E3DA);
    Color bgColor = Colors.white;
    Color letterBoxColor = const Color(0xFFE8E3DA);
    Color letterTextColor = const Color(0xFF4B4B4B);

    if (_isAnswered) {
      if (index == correctIndex) {
        borderColor = Colors.green[400]!;
        bgColor = Colors.green[50]!;
        letterBoxColor = Colors.green[400]!;
        letterTextColor = Colors.white;
      } else if (isSelected && index != correctIndex) {
        borderColor = Colors.red[400]!;
        bgColor = Colors.red[50]!;
        letterBoxColor = Colors.red[400]!;
        letterTextColor = Colors.white;
      }
    } else if (isSelected) {
      borderColor = const Color(0xFFCC6633);
      bgColor = const Color(0xFFF6E7DC);
      letterBoxColor = const Color(0xFFCC6633);
      letterTextColor = Colors.white;
    }

    return GestureDetector(
      onTap: () => _selectOption(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor, width: 2)),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: letterBoxColor, borderRadius: BorderRadius.circular(6)),
              child: Center(child: Text(code, style: TextStyle(color: letterTextColor, fontWeight: FontWeight.bold))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                  const SizedBox(height: 2),
                  Text(romaji, style: const TextStyle(fontSize: 11, color: Color(0xFF8C8A87))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}