import 'package:flutter/material.dart';

import '../../core/game_manager.dart';
import 'simulation_review_screen.dart';

class SimulationResultScreen extends StatefulWidget {
  final int languageScore;
  final int languageTotal;
  final int readingScore;
  final int readingTotal;
  final int timeSpentSeconds;
  final double totalPoints;
  final bool isPassed;
  final List<int?> userAnswers;

  const SimulationResultScreen({
    super.key,
    required this.languageScore,
    required this.languageTotal,
    required this.readingScore,
    required this.readingTotal,
    required this.timeSpentSeconds,
    required this.totalPoints,
    required this.isPassed,
    required this.userAnswers,
  });

  @override
  State<SimulationResultScreen> createState() => _SimulationResultScreenState();
}

class _SimulationResultScreenState extends State<SimulationResultScreen> {
  @override
  void initState() {
    super.initState();
    // Audio removed as requested
  }

  String _formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes}m ${remainingSeconds}s';
  }

  String _getMotivation(bool passed) {
    if (passed) {
      return _t(
          "Outstanding! You've proved your proficiency in JLPT N5. This is a huge milestone in your Japanese journey. The road ahead looks bright!",
          "Luar biasa! Kamu telah membuktikan kemampuanmu di level JLPT N5. Ini adalah pencapaian besar dalam perjalanan bahasa Jepangmu. Masa depan menantimu!"
      );
    } else {
      return _t(
          "Every master was once a beginner who didn't give up. Use this result as a map for your next study session. You're closer than you think!",
          "Setiap master dulunya adalah pemula yang tidak menyerah. Jadikan hasil ini sebagai peta untuk sesi belajarmu berikutnya. Kamu sudah lebih dekat dari yang kamu bayangkan!"
      );
    }
  }

  String _t(String en, String id) {
    return globalLanguage.value == 'id' ? id : en;
  }

  String _getGrade(double score) {
    double percent = (score / 180) * 100;
    if (percent >= 90) return "S";
    if (percent >= 80) return "A";
    if (percent >= 70) return "B";
    if (percent >= 44.5) return "C"; // JLPT N5 Pass mark is roughly 80/180
    return "D";
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: globalDarkMode,
      builder: (context, isDark, _) {
        final Color bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF9F6F0);
        final Color cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
        final Color accentColor = const Color(0xFFCC6633);
        final Color statusColor = widget.isPassed ? const Color(0xFF4CAF50) : const Color(0xFFE53935);

        final double langPoints = (widget.languageScore / (widget.languageTotal == 0 ? 1 : widget.languageTotal)) * 60;
        final double readingPoints = (widget.readingScore / (widget.readingTotal == 0 ? 1 : widget.readingTotal)) * 120;
        final String grade = _getGrade(widget.totalPoints);
        final int totalQuestions = widget.languageTotal + widget.readingTotal;
        final int totalCorrect = widget.languageScore + widget.readingScore;
        final int accuracy = totalQuestions > 0 ? ((totalCorrect / totalQuestions) * 100).round() : 0;

        return Scaffold(
          backgroundColor: bgColor,
          body: Stack(
            children: [
              // Decorative background patterns
              Positioned(
                top: -50,
                right: -50,
                child: Opacity(
                  opacity: 0.1,
                  child: Icon(Icons.star_rounded, size: 250, color: statusColor),
                ),
              ),

              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                    child: Column(
                      children: [
                        // Grade Badge & Status
                        Center(
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 160,
                                    height: 160,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: statusColor.withValues(alpha: 0.2), width: 2),
                                    ),
                                  ),
                                  Container(
                                    width: 130,
                                    height: 130,
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: statusColor.withValues(alpha: 0.15),
                                          blurRadius: 30,
                                          spreadRadius: 5,
                                        )
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        grade,
                                        style: TextStyle(
                                          fontSize: 72,
                                          fontWeight: FontWeight.w900,
                                          color: statusColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: statusColor,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: statusColor.withValues(alpha: 0.3),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          )
                                        ],
                                      ),
                                      child: Text(
                                        widget.isPassed ? "PASSED" : "FAILED",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 14,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              Text(
                                widget.isPassed ? "Omedetou Gozaimasu!" : "Ganbatte Kudasai!",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: textColor(isDark),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  _getMotivation(widget.isPassed),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: subTextColor(isDark),
                                    height: 1.5,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Score Card
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 24,
                                offset: const Offset(0, 12),
                              )
                            ],
                            border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE8E3DA)),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  children: [
                                    Text(
                                      _t("OVERALL PERFORMANCE", "PERFORMA KESELURUHAN"),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                        color: subTextColor(isDark),
                                        letterSpacing: 2,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        Text(
                                          "${widget.totalPoints.toInt()}",
                                          style: TextStyle(
                                            fontSize: 88,
                                            fontWeight: FontWeight.w900,
                                            color: accentColor,
                                            height: 1,
                                          ),
                                        ),
                                        Text(
                                          "/180",
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w900,
                                            color: subTextColor(isDark).withValues(alpha: 0.3),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Progress Bar
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 32),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: widget.totalPoints / 180,
                                    minHeight: 12,
                                    backgroundColor: isDark ? Colors.white10 : const Color(0xFFF0EBE0),
                                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 40),

                              // Sectional Breakdown
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 24),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white.withValues(alpha: 0.03) : const Color(0xFFFBF9F4),
                                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildDetailedScore(
                                        _t("Language", "Bahasa"),
                                        _t("(Vocabulary & Grammar)", "(Kosakata & Tata Bahasa)"),
                                        "${langPoints.toInt()}",
                                        "/60",
                                        Icons.translate_rounded,
                                        const Color(0xFF58CC02),
                                        isDark,
                                        _t("JLPT standard: Language max score is 60 points.", "Standar JLPT: Skor maksimal Bahasa adalah 60 poin.")
                                    ),
                                    Container(width: 1, height: 40, color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                                    _buildDetailedScore(
                                        _t("Reading", "Membaca"),
                                        _t("(Reading & Comprehension)", "(Membaca & Pemahaman)"),
                                        "${readingPoints.toInt()}",
                                        "/120",
                                        Icons.menu_book_rounded,
                                        const Color(0xFF1CB0F6),
                                        isDark,
                                        _t("JLPT standard: Reading max score is 120 points.", "Standar JLPT: Skor maksimal Membaca adalah 120 poin.")
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Stats Grid
                        Row(
                          children: [
                            Expanded(
                              child: _buildSmallStatCard(
                                  _t("Time", "Waktu"),
                                  _formatDuration(widget.timeSpentSeconds),
                                  Icons.timer_rounded,
                                  isDark, cardColor
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildSmallStatCard(
                                  _t("Accuracy", "Akurasi"),
                                  "$accuracy%",
                                  Icons.ads_click_rounded,
                                  isDark, cardColor
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 48),

                        // Action Buttons
                        Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SimulationReviewScreen(
                                        userAnswers: widget.userAnswers,
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accentColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 0,
                                ),
                                child: Text(
                                  _t("REVIEW EXAM", "TINJAU UJIAN"),
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                foregroundColor: subTextColor(isDark),
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                              ),
                              child: Text(
                                _t("BACK", "KEMBALI"),
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
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

  Widget _buildDetailedScore(String label, String subtitle, String value, String total, IconData icon, Color color, bool isDark, String tooltipMsg) {
    return Column(
      children: [
        Tooltip(
          message: tooltipMsg,
          triggerMode: TooltipTriggerMode.tap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: subTextColor(isDark))),
              const SizedBox(width: 4),
              Icon(Icons.info_outline_rounded, color: subTextColor(isDark).withValues(alpha: 0.5), size: 14),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Text(subtitle, style: TextStyle(fontSize: 10, color: subTextColor(isDark).withValues(alpha: 0.7))),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: textColor(isDark))),
            Text(total, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: subTextColor(isDark).withValues(alpha: 0.5))),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallStatCard(String label, String value, IconData icon, bool isDark, Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE8E3DA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFCC6633), size: 20),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: textColor(isDark))),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: subTextColor(isDark))),
        ],
      ),
    );
  }
}
