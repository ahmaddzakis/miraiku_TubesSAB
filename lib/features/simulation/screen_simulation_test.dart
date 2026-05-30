import 'dart:async';


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/game_manager.dart';
import '../../data/simulation_data.dart';
import 'simulation_result_screen.dart';

class SimulationTestScreen extends StatefulWidget {
  const SimulationTestScreen({super.key});

  @override
  State<SimulationTestScreen> createState() => _SimulationTestScreenState();
}

class _SimulationTestScreenState extends State<SimulationTestScreen> {
  int _currentQuestionIndex = 0;
  int _languageScore = 0;
  int _readingScore = 0;
  int _languageTotal = 0;
  int _readingTotal = 0;
  int? _selectedOption;
  bool _isAnswered = false;
  bool _isCurrentAnswerCorrect = false;
  late List<SimulationQuestion> _questions;
  late List<int?> _userAnswers;
  
  Timer? _timer;
  int _timeLeft = 50 * 60; // 50 mins total (25 Language + 25 Reading)

  @override
  void initState() {
    super.initState();
    _questions = List.from(SimulationData.n5Questions);
    _userAnswers = List.filled(_questions.length, null);
    _languageTotal = _questions.where((q) => q.section == 'Language Knowledge').length;
    _readingTotal = _questions.where((q) => q.section == 'Reading').length;
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
    int minutes = _timeLeft ~/ 60;
    int seconds = _timeLeft % 60;
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
    setState(() {
      _isAnswered = true;
      _userAnswers[_currentQuestionIndex] = _selectedOption;
      _isCurrentAnswerCorrect = _selectedOption == currentQuestion.correctAnswerIndex;
      
      if (_isCurrentAnswerCorrect) {
        if (currentQuestion.section == 'Language Knowledge') {
          _languageScore++;
        } else if (currentQuestion.section == 'Reading') {
          _readingScore++;
        }
        HapticFeedback.mediumImpact();
      } else {
        HapticFeedback.heavyImpact();
      }
    });

    // Auto next after selection in simulation (optional, but requested no immediate feedback)
    // If we want to show it's answered but not if it's correct/wrong:
    // Actually, "hasil benar atau salahnya itu tidak langsung ditampilkan ke user" 
    // means we should probably just move to next or record it and move on.
    
    // Modification: Don't show correct/wrong state in _buildOptionTile during test
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
    double langPoints = (_languageScore / (_languageTotal == 0 ? 1 : _languageTotal)) * 60;
    double readingPoints = (_readingScore / (_readingTotal == 0 ? 1 : _readingTotal)) * 120;
    double totalPoints = langPoints + readingPoints;
    bool isPassed = totalPoints >= 80;
    int timeSpent = (75 * 60) - _timeLeft;

    // Save Result to History via GameManager
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
    };

    List<dynamic> history = List.from(globalSimulationHistory.value);
    history.insert(0, newResult);
    
    // Keep only last 10 attempts
    if (history.length > 10) history = history.sublist(0, 10);
    
    globalSimulationHistory.value = history;
    await GameManager.syncToCloud();

    final prefs = await SharedPreferences.getInstance();
    int currentCount = prefs.getInt('simulation_completed_count') ?? 0;
    await prefs.setInt('simulation_completed_count', currentCount + 1);

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
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: globalDarkMode,
      builder: (context, isDark, _) {
        return ValueListenableBuilder<String>(
          valueListenable: globalLanguage,
          builder: (context, lang, _) {
            final question = _questions[_currentQuestionIndex];
            final progress = (_currentQuestionIndex + 1) / _questions.length;
            final Color accentColor = const Color(0xFFCC6633);
            final Color bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F2EE);
            final Color cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

            return Scaffold(
              backgroundColor: bgColor,
              body: SafeArea(
                child: Column(
                  children: [
                    // Synchronized Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () => _showExitConfirmation(),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: cardColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                                  ),
                                  child: Icon(Icons.close_rounded, color: isDark ? Colors.white70 : Colors.black45, size: 24),
                                ),
                              ),
                              Text(
                                "JLPT N5 • SIMULATION",
                                style: TextStyle(
                                  color: accentColor,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11,
                                  letterSpacing: 2.2,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: accentColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.timer_outlined, size: 18, color: accentColor),
                                    const SizedBox(width: 6),
                                    Text(
                                      _formattedTime,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: accentColor,
                                        fontWeight: FontWeight.w900,
                                        fontFeatures: const [FontFeature.tabularFigures()],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Stack(
                            children: [
                              Container(
                                height: 8,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                                height: 8,
                                width: (MediaQuery.of(context).size.width - 48) * progress,
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: accentColor.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        switchInCurve: Curves.easeInOut,
                        switchOutCurve: Curves.easeInOut,
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          var offsetAnimation = Tween<Offset>(
                            begin: const Offset(0.0, 0.05), // Sedikit bergeser dari bawah
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
                          padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Section Header
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: accentColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  question.section.toUpperCase(),
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: accentColor, letterSpacing: 1.2),
                                ),
                              ),
                              const SizedBox(height: 20),
                              
                              // Question Card
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(28),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(32),
                                  border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE8E3DA), width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFCC6633).withValues(alpha: 0.08),
                                      blurRadius: 24,
                                      offset: const Offset(0, 12),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      question.question,
                                      style: TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w900,
                                        color: isDark ? Colors.white : const Color(0xFF2D2622),
                                        height: 1.4,
                                      ),
                                    ),
                                    if (question.romaji != null) ...[
                                      const SizedBox(height: 12),
                                      Text(
                                        question.romaji!,
                                        style: TextStyle(
                                          fontSize: 15, 
                                          color: isDark ? Colors.white38 : Colors.grey[700],
                                          fontStyle: FontStyle.italic,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                    if (question.subQuestion != null) ...[
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 20),
                                        child: Divider(color: accentColor.withValues(alpha: 0.1), thickness: 2),
                                      ),
                                      Text(
                                        question.subQuestion!,
                                        style: TextStyle(
                                          fontSize: 18, 
                                          fontWeight: FontWeight.w700,
                                          color: isDark ? Colors.white70 : Colors.black87, 
                                          height: 1.6,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              
                              // Options List
                              ...List.generate(question.options.length, (index) {
                                return _buildOptionTile(index, question.options[index], isDark);
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
            );
          },
        );
      },
    );
  }

  String _t(String en, String id) {
    return globalLanguage.value == 'id' ? id : en;
  }

  Widget _buildOptionTile(int index, String text, bool isDark) {
    final bool isSelected = _selectedOption == index;
    final Color accentColor = const Color(0xFFCC6633);
    
    
    // Skema warna yang diperbaiki untuk visibilitas maksimal
    Color borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFE8E3DA);
    Color bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    Color textColor = isDark ? Colors.white : const Color(0xFF4B4B4B);
    Color letterBoxColor = isDark ? Colors.white.withValues(alpha: 0.07) : const Color(0xFFF5F5F5);
    Color letterTextColor = isDark ? Colors.white70 : const Color(0xFF8C8A87);
    
    if (_isAnswered) {
      // In simulation, we don't show correct/wrong immediately
      if (isSelected) {
        borderColor = accentColor;
        bgColor = isDark ? const Color(0xFF4A2B18) : const Color(0xFFF6E7DC);
        letterBoxColor = accentColor;
        letterTextColor = Colors.white;
        textColor = isDark ? Colors.white : accentColor;
      }
    } else if (isSelected) {
      borderColor = accentColor;
      bgColor = isDark ? const Color(0xFF4A2B18) : const Color(0xFFF6E7DC);
      letterBoxColor = accentColor;
      letterTextColor = Colors.white;
      textColor = isDark ? Colors.white : accentColor;
    }

    return GestureDetector(
      onTap: () => _handleOptionSelect(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: borderColor,
            width: (isSelected || _isAnswered) ? 2.5 : 1.5,
          ),
          boxShadow: isSelected && !_isAnswered ? [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ] : [],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: letterBoxColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + index),
                  style: TextStyle(
                    color: letterTextColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: textColor,
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
    final Color accentColor = const Color(0xFFCC6633);
    
    Color btnColor = canConfirm ? accentColor : (isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE0E0E0));

    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).padding.bottom + 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121212) : const Color(0xFFF5F2EE),
        border: Border(top: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05))),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: btnColor,
            foregroundColor: Colors.white,
            disabledBackgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFE0E0E0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          onPressed: canConfirm 
            ? (_isAnswered ? _nextQuestion : _submitAnswer)
            : null,
          child: Text(
            _isAnswered 
              ? (_currentQuestionIndex == _questions.length - 1 ? _t("FINISH", "SELESAI") : _t("CONTINUE", "LANJUTKAN")) 
              : _t("SUBMIT ANSWER", "KONFIRMASI"),
            style: TextStyle(
              color: canConfirm ? Colors.white : (isDark ? Colors.white24 : Colors.black26),
              fontWeight: FontWeight.w900,
              fontSize: 16,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  void _showExitConfirmation() {
    final isDark = globalDarkMode.value;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(_t("Exit Simulation?", "Keluar Simulasi?"), style: const TextStyle(fontWeight: FontWeight.w900)),
        content: Text(_t("Your progress will be lost. You will need to start over.", "Semua kemajuan akan hilang. Kamu harus mengulang dari awal.")),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text(_t("CONTINUE", "LANJUTKAN"), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(_t("EXIT", "KELUAR"), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
