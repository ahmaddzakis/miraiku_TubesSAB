import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/game_manager.dart';
import '../../core/sound_manager.dart';
import '../../data/simulation_data.dart';

class SimulationTestScreen extends StatefulWidget {
  const SimulationTestScreen({super.key});

  @override
  State<SimulationTestScreen> createState() => _SimulationTestScreenState();
}

class _SimulationTestScreenState extends State<SimulationTestScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  int? _selectedOption;
  bool _isAnswered = false;
  late List<SimulationQuestion> _questions;
  
  Timer? _timer;
  int _timeLeft = 105 * 60; // 105 minutes in seconds

  @override
  void initState() {
    super.initState();
    _questions = List.from(SimulationData.n5Questions)..shuffle();
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
        setState(() => _timeLeft--);
      } else {
        _timer?.cancel();
        _finishTest();
      }
    });
  }

  String get _formattedTime {
    int hours = _timeLeft ~/ 3600;
    int minutes = (_timeLeft % 3600) ~/ 60;
    int seconds = _timeLeft % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _handleOptionSelect(int index) {
    if (_isAnswered) return;
    setState(() => _selectedOption = index);
  }

  void _submitAnswer() {
    if (_selectedOption == null || _isAnswered) return;

    setState(() {
      _isAnswered = true;
      if (_selectedOption == _questions[_currentQuestionIndex].correctAnswerIndex) {
        _score++;
        SoundManager.playSound('benar.mp3');
      } else {
        SoundManager.playSound('salah.mp3');
      }
    });

    // Auto move to next question after a short delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) _nextQuestion();
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOption = null;
        _isAnswered = false;
      });
    } else {
      _finishTest();
    }
  }

  void _finishTest() {
    _timer?.cancel();
    // Calculate results and show dialog
    final int totalQuestions = _questions.length;
    final double percentage = (_score / totalQuestions) * 100;
    final bool isPassed = percentage >= 60; // Standard JLPT N5 pass mark approx

    _showResultDialog(isPassed, percentage);
  }

  void _showResultDialog(bool isPassed, double percentage) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final isDark = globalDarkMode.value;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            isPassed ? "Congratulations! 🎉" : "Keep Practicing! 💪",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w900, color: isPassed ? Colors.green : Colors.orange),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "You scored $_score out of ${_questions.length}",
                style: TextStyle(fontSize: 18, color: isDark ? Colors.white : Colors.black87),
              ),
              const SizedBox(height: 8),
              Text(
                "${percentage.toStringAsFixed(1)}%",
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFFCC6633)),
              ),
              const SizedBox(height: 16),
              Text(
                isPassed 
                  ? "You have passed the JLPT N5 Mock Test!" 
                  : "You need at least 60% to pass. Don't give up!",
                textAlign: TextAlign.center,
                style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCC6633),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Exit test screen
                },
                child: const Text("CLOSE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = globalDarkMode.value;
    final question = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFFAF7F2),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black),
          onPressed: () => _showExitConfirmation(),
        ),
        title: Column(
          children: [
            Text(
              question.section.toUpperCase(),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFCC6633), letterSpacing: 1),
            ),
            Text(
              _formattedTime,
              style: TextStyle(fontSize: 16, color: isDark ? Colors.white70 : Colors.black87, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: progress,
            backgroundColor: isDark ? Colors.white10 : Colors.black12,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFCC6633)),
            minHeight: 6,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Question ${_currentQuestionIndex + 1} of ${_questions.length}",
                    style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (question.audioPath != null) 
                    _buildAudioPlayer(question.audioPath!),
                  const SizedBox(height: 16),
                  Text(
                    question.question,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87),
                  ),
                  if (question.subQuestion != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      question.subQuestion!,
                      style: TextStyle(fontSize: 16, color: isDark ? Colors.white70 : Colors.black54),
                    ),
                  ],
                  const SizedBox(height: 32),
                  ...List.generate(question.options.length, (index) {
                    return _buildOptionTile(index, question.options[index]);
                  }),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildAudioPlayer(String path) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFCC6633).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.play_circle_fill, size: 40, color: Color(0xFFCC6633)),
            onPressed: () => SoundManager.playSound(path),
          ),
          const SizedBox(width: 12),
          const Text("Listening Clip", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFCC6633))),
        ],
      ),
    );
  }

  Widget _buildOptionTile(int index, String text) {
    final isDark = globalDarkMode.value;
    final bool isSelected = _selectedOption == index;
    
    Color borderColor = isDark ? Colors.white12 : Colors.black12;
    Color bgColor = Colors.transparent;
    Color textColor = isDark ? Colors.white : Colors.black87;

    if (_isAnswered) {
      if (index == _questions[_currentQuestionIndex].correctAnswerIndex) {
        borderColor = Colors.green;
        bgColor = Colors.green.withValues(alpha: 0.1);
      } else if (isSelected) {
        borderColor = Colors.red;
        bgColor = Colors.red.withValues(alpha: 0.1);
      }
    } else if (isSelected) {
      borderColor = const Color(0xFFCC6633);
      bgColor = const Color(0xFFCC6633).withValues(alpha: 0.05);
    }

    return GestureDetector(
      onTap: () => _handleOptionSelect(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? const Color(0xFFCC6633) : Colors.grey),
                color: isSelected ? const Color(0xFFCC6633) : Colors.transparent,
              ),
              child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(fontSize: 16, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: textColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final isDark = globalDarkMode.value;
    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFCC6633),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            disabledBackgroundColor: Colors.grey.shade300,
          ),
          onPressed: (_selectedOption != null && !_isAnswered) ? _submitAnswer : null,
          child: const Text("CONFIRM ANSWER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ),
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Exit Test?"),
        content: const Text("Your progress in this simulation will be lost. Are you sure?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("EXIT", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
