import 'package:flutter/material.dart';
import '../../core/game_manager.dart';
import '../../data/simulation_data.dart';

class SimulationReviewScreen extends StatefulWidget {
  final List<int?> userAnswers;

  const SimulationReviewScreen({
    super.key,
    required this.userAnswers,
  });

  @override
  State<SimulationReviewScreen> createState() => _SimulationReviewScreenState();
}

class _SimulationReviewScreenState extends State<SimulationReviewScreen> {
  int _currentIndex = 0;
  final List<SimulationQuestion> _questions = SimulationData.n5Questions;

  String _t(String en, String id) {
    return globalLanguage.value == 'id' ? id : en;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: globalDarkMode,
      builder: (context, isDark, _) {
        final Color bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F2EE);
        final Color cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
        final Color accentColor = const Color(0xFFCC6633);
        final question = _questions[_currentIndex];
        final userAnswer = widget.userAnswers[_currentIndex];
        final isCorrect = userAnswer == question.correctAnswerIndex;

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white70 : Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              _t("Exam Review", "Tinjau Ujian"),
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF2D2622),
                fontWeight: FontWeight.w900,
              ),
            ),
            centerTitle: true,
          ),
          body: Column(
            children: [
              // Progress indicator for review
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: (_currentIndex + 1) / _questions.length,
                          minHeight: 8,
                          backgroundColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                          valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      "${_currentIndex + 1}/${_questions.length}",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: subTextColor(isDark),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Question Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE8E3DA)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: accentColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    question.section.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: accentColor,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: (isCorrect ? Colors.green : Colors.red).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    isCorrect ? _t("CORRECT", "BENAR") : _t("WRONG", "SALAH"),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: isCorrect ? Colors.green : Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              question.question,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: textColor(isDark),
                                height: 1.4,
                              ),
                            ),
                            if (question.romaji != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                question.romaji!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: subTextColor(isDark),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                            if (question.subQuestion != null) ...[
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Divider(),
                              ),
                              Text(
                                question.subQuestion!,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: textColor(isDark).withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Options
                      ...List.generate(question.options.length, (index) {
                        final isCorrectOption = index == question.correctAnswerIndex;
                        final isUserSelected = index == userAnswer;

                        Color optionBorderColor = isDark ? Colors.white10 : const Color(0xFFE8E3DA);
                        Color optionBgColor = cardColor;
                        IconData? icon;
                        Color? iconColor;

                        if (isCorrectOption) {
                          optionBorderColor = Colors.green;
                          optionBgColor = Colors.green.withValues(alpha: isDark ? 0.1 : 0.05);
                          icon = Icons.check_circle_rounded;
                          iconColor = Colors.green;
                        } else if (isUserSelected && !isCorrectOption) {
                          optionBorderColor = Colors.red;
                          optionBgColor = Colors.red.withValues(alpha: isDark ? 0.1 : 0.05);
                          icon = Icons.cancel_rounded;
                          iconColor = Colors.red;
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: optionBgColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: optionBorderColor, width: (isCorrectOption || isUserSelected) ? 2 : 1),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    String.fromCharCode(65 + index),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: subTextColor(isDark),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  question.options[index],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: (isCorrectOption || isUserSelected) ? FontWeight.w800 : FontWeight.w500,
                                    color: textColor(isDark),
                                  ),
                                ),
                              ),
                              if (icon != null) Icon(icon, color: iconColor, size: 24),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 12),

                      // Explanation
                      if (question.explanation != null) ...[
                        Text(
                          _t("EXPLANATION", "PENJELASAN"),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: subTextColor(isDark),
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: accentColor.withValues(alpha: 0.1)),
                          ),
                          child: Text(
                            question.explanation!,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.6,
                              color: textColor(isDark).withValues(alpha: 0.9),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),

              // Navigation Buttons
              Container(
                padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
                decoration: BoxDecoration(
                  color: cardColor,
                  border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _currentIndex > 0 ? () => setState(() => _currentIndex--) : null,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          side: BorderSide(color: accentColor),
                        ),
                        child: Text(
                          _t("PREVIOUS", "SEBELUMNYA"),
                          style: TextStyle(fontWeight: FontWeight.w900, color: accentColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _currentIndex < _questions.length - 1 ? () => setState(() => _currentIndex++) : () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: Text(
                          _currentIndex < _questions.length - 1 ? _t("NEXT", "SELANJUTNYA") : _t("DONE", "SELESAI"),
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color textColor(bool isDark) => isDark ? Colors.white : const Color(0xFF2D2622);
  Color subTextColor(bool isDark) => isDark ? Colors.white70 : const Color(0xFF8C8A87);
}
