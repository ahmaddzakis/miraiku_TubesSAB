import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/game_manager.dart';
import '../../data/simulation_data.dart';
import 'simulation_result_screen.dart';

class SimulationHistoryScreen extends StatefulWidget {
  const SimulationHistoryScreen({super.key});

  @override
  State<SimulationHistoryScreen> createState() => _SimulationHistoryScreenState();
}

class _SimulationHistoryScreenState extends State<SimulationHistoryScreen> {
  List<dynamic> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    // Gunakan globalSimulationHistory dari GameManager agar data tersinkronisasi
    final List<dynamic> history = List.from(globalSimulationHistory.value);
    
    // Sort by date descending (newest first)
    history.sort((a, b) => DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));

    setState(() {
      _history = history;
      _isLoading = false;
    });
  }

  String _t(String en, String id) {
    return globalLanguage.value == 'id' ? id : en;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: globalLanguage,
      builder: (context, lang, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: globalDarkMode,
          builder: (context, isDark, _) {
            final Color bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFAF7F2);
            final Color textColor = isDark ? Colors.white : const Color(0xFF2D2622);

            return Scaffold(
              backgroundColor: bgColor,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  _t("EXAM HISTORY", "RIWAYAT UJIAN"),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                centerTitle: true,
              ),
              body: ValueListenableBuilder<List<dynamic>>(
                valueListenable: globalSimulationHistory,
                builder: (context, historyList, _) {
                  if (historyList.isEmpty) {
                    return _buildEmptyState(textColor);
                  }

                  // Sort by date descending (newest first)
                  final sortedHistory = List.from(historyList);
                  sortedHistory.sort((a, b) => DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    itemCount: sortedHistory.length,
                    itemBuilder: (context, index) {
                      final item = sortedHistory[index];
                      final date = DateTime.parse(item['date']);
                      final bool passed = item['isPassed'] ?? false;
                      final double score = (item['totalPoints'] as num).toDouble();

                      return _buildHistoryItem(item, date, passed, score, isDark, textColor);
                    },
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(Color textColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 80, color: textColor.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          Text(
            _t("No history available", "Belum ada riwayat"),
            style: TextStyle(color: textColor.withValues(alpha: 0.5), fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(dynamic item, DateTime date, bool passed, double score, bool isDark, Color textColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _navigateToDetails(item, score, passed),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (passed ? Colors.green : Colors.red).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  passed ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  color: passed ? Colors.green : Colors.red,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${date.day}/${date.month}/${date.year} - ${date.hour}:${date.minute.toString().padLeft(2, '0')}",
                      style: TextStyle(fontWeight: FontWeight.w900, color: textColor, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _t("Score: ${score.toInt()}/180", "Skor: ${score.toInt()}/180"),
                      style: TextStyle(color: textColor.withValues(alpha: 0.6), fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: textColor.withValues(alpha: 0.3)),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDetails(dynamic item, double score, bool passed) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SimulationResultScreen(
          languageScore: item['languageScore'],
          languageTotal: item['languageTotal'],
          readingScore: item['readingScore'],
          readingTotal: item['readingTotal'],
          timeSpentSeconds: item['timeSpentSeconds'],
          totalPoints: score,
          isPassed: passed,
          userAnswers: item['userAnswers'] != null 
              ? List<int?>.from(item['userAnswers']) 
              : List.filled(SimulationData.n5Questions.length, null),
        ),
      ),
    );
  }
}
