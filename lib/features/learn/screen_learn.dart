import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/game_manager.dart';
import '../../widgets/path_node.dart';
import 'widget_learn.dart';
import 'screen_exercise.dart';

class LearnScreen extends StatefulWidget {
  final bool isUnit1Completed;
  final VoidCallback onUnit1Completed;

  const LearnScreen({
    super.key,
    required this.isUnit1Completed,
    required this.onUnit1Completed,
  });

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  // --- STATE UNIT 1 ---
  int _u1Hira1Stars = 0, _u1Hira2Stars = 0, _u1Hira3Stars = 0, _u1Hira4Stars = 0;
  int _u1GreetStars = 0, _u1NumStars = 0, _u1TestCompleted = 0;

  // --- STATE UNIT 2 (DIPERLUAS 4 Katakana, 2 Kata) ---
  int _u2Kata1Stars = 0, _u2Kata2Stars = 0, _u2Kata3Stars = 0, _u2Kata4Stars = 0;
  int _u2Words1Stars = 0, _u2Words2Stars = 0, _u2TestCompleted = 0;

  int _userHearts = 5;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _u1Hira1Stars = prefs.getInt('u1_hira1_stars') ?? 0;
      _u1Hira2Stars = prefs.getInt('u1_hira2_stars') ?? 0;
      _u1Hira3Stars = prefs.getInt('u1_hira3_stars') ?? 0;
      _u1Hira4Stars = prefs.getInt('u1_hira4_stars') ?? 0;
      _u1GreetStars = prefs.getInt('u1_greet_stars') ?? 0;
      _u1NumStars = prefs.getInt('u1_num_stars') ?? 0;
      _u1TestCompleted = prefs.getInt('u1_test_stars') ?? 0;

      // Katakana States
      _u2Kata1Stars = prefs.getInt('u2_kata1_stars') ?? 0;
      _u2Kata2Stars = prefs.getInt('u2_kata2_stars') ?? 0;
      _u2Kata3Stars = prefs.getInt('u2_kata3_stars') ?? 0;
      _u2Kata4Stars = prefs.getInt('u2_kata4_stars') ?? 0;
      _u2Words1Stars = prefs.getInt('u2_words1_stars') ?? 0;
      _u2Words2Stars = prefs.getInt('u2_words2_stars') ?? 0;
      _u2TestCompleted = prefs.getInt('u2_test_stars') ?? 0;

      _userHearts = prefs.getInt('user_hearts') ?? 5;
    });
  }

  Future<void> _saveStarProgress(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  Future<void> _saveHearts(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_hearts', value);
  }

  String _t(String en, String id) {
    return globalLanguage.value == 'id' ? id : en;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: globalDarkMode,
      builder: (context, isDark, _) {
        return ValueListenableBuilder(
          valueListenable: globalLanguage,
          builder: (context, lang, _) {
            final Color bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF9F6F0);
            final Color borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFE8E3DA);

            // Kunci Pembuka Unit 2
            bool isUnit2Unlocked = widget.isUnit1Completed || _u1TestCompleted >= 1;

            return Scaffold(
              backgroundColor: bgColor,
              body: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const UnitHeaderCard(),
              const SizedBox(height: 40),

              // ==================== UNIT 1 ====================
              _buildClickableNode(context, _t("Hiragana Basics 1", "Hiragana Dasar 1"), _u1Hira1Stars, _u1Hira1Stars >= 3 ? NodeStatus.completed : NodeStatus.current, 1, 'hiragana_1', () {
                setState(() { if (_u1Hira1Stars < 3) { _u1Hira1Stars++; _saveStarProgress('u1_hira1_stars', _u1Hira1Stars); } });
              }),
              _buildLeftConnector(borderColor),
              _buildClickableNode(context, _t("Hiragana Basics 2", "Hiragana Dasar 2"), _u1Hira2Stars, _u1Hira2Stars >= 3 ? NodeStatus.completed : (_u1Hira1Stars >= 3 ? NodeStatus.current : NodeStatus.locked), 1, 'hiragana_2', () {
                setState(() { if (_u1Hira2Stars < 3) { _u1Hira2Stars++; _saveStarProgress('u1_hira2_stars', _u1Hira2Stars); } });
              }),
              _buildLeftConnector(borderColor),
              _buildClickableNode(context, _t("Hiragana Basics 3", "Hiragana Dasar 3"), _u1Hira3Stars, _u1Hira3Stars >= 3 ? NodeStatus.completed : (_u1Hira2Stars >= 3 ? NodeStatus.current : NodeStatus.locked), 1, 'hiragana_3', () {
                setState(() { if (_u1Hira3Stars < 3) { _u1Hira3Stars++; _saveStarProgress('u1_hira3_stars', _u1Hira3Stars); } });
              }),
              _buildLeftConnector(borderColor),
              _buildClickableNode(context, _t("Hiragana Basics 4", "Hiragana Dasar 4"), _u1Hira4Stars, _u1Hira4Stars >= 3 ? NodeStatus.completed : (_u1Hira3Stars >= 3 ? NodeStatus.current : NodeStatus.locked), 1, 'hiragana_4', () {
                setState(() { if (_u1Hira4Stars < 3) { _u1Hira4Stars++; _saveStarProgress('u1_hira4_stars', _u1Hira4Stars); } });
              }),
              _buildLeftConnector(borderColor),
              _buildClickableNode(context, _t("Daily Greetings", "Salam Sehari-hari"), _u1GreetStars, _u1GreetStars >= 3 ? NodeStatus.completed : (_u1Hira4Stars >= 3 ? NodeStatus.current : NodeStatus.locked), 1, 'greetings', () {
                setState(() { if (_u1GreetStars < 3) { _u1GreetStars++; _saveStarProgress('u1_greet_stars', _u1GreetStars); } });
              }),
              _buildLeftConnector(borderColor),
              _buildClickableNode(context, _t("Numbers & Time", "Angka & Waktu"), _u1NumStars, _u1NumStars >= 3 ? NodeStatus.completed : (_u1GreetStars >= 3 ? NodeStatus.current : NodeStatus.locked), 1, 'numbers', () {
                setState(() { if (_u1NumStars < 3) { _u1NumStars++; _saveStarProgress('u1_num_stars', _u1NumStars); } });
              }),
              _buildLeftConnector(borderColor),

              // UNIT TEST 1 (Tanpa Bintang, Langsung Tamat 1x Main)
              _buildClickableNode(
                context, _t("Unit Test\n20 min", "Ujian Unit\n20 mnt"), 0,
                _u1TestCompleted >= 1 ? NodeStatus.completed : (_u1NumStars >= 3 ? NodeStatus.current : NodeStatus.locked),
                1, 'test', () {
                setState(() {
                  if (_u1TestCompleted == 0) {
                    _u1TestCompleted = 1;
                    _saveStarProgress('u1_test_stars', 1);
                    widget.onUnit1Completed(); // Buka gembok Unit 2
                  }
                });
              },
              ),

              const SizedBox(height: 40),
              Divider(thickness: 2, color: borderColor),
              const SizedBox(height: 20),

              // ==================== UNIT 2 (DESAIN KONSISTEN) ====================
              _buildUnit2HeaderCard(isDark, isUnit2Unlocked), // 🔥 Desain Header Baru!
              const SizedBox(height: 40),

              _buildClickableNode(context, _t("Katakana Basics 1", "Katakana Dasar 1"), _u2Kata1Stars, _u2Kata1Stars >= 3 ? NodeStatus.completed : (isUnit2Unlocked ? NodeStatus.current : NodeStatus.locked), 2, 'katakana_1', () {
                setState(() { if (_u2Kata1Stars < 3) { _u2Kata1Stars++; _saveStarProgress('u2_kata1_stars', _u2Kata1Stars); } });
              }),
              _buildLeftConnector(borderColor),
              _buildClickableNode(context, _t("Katakana Basics 2", "Katakana Dasar 2"), _u2Kata2Stars, _u2Kata2Stars >= 3 ? NodeStatus.completed : (_u2Kata1Stars >= 3 ? NodeStatus.current : NodeStatus.locked), 2, 'katakana_2', () {
                setState(() { if (_u2Kata2Stars < 3) { _u2Kata2Stars++; _saveStarProgress('u2_kata2_stars', _u2Kata2Stars); } });
              }),
              _buildLeftConnector(borderColor),
              _buildClickableNode(context, _t("Katakana Basics 3", "Katakana Dasar 3"), _u2Kata3Stars, _u2Kata3Stars >= 3 ? NodeStatus.completed : (_u2Kata2Stars >= 3 ? NodeStatus.current : NodeStatus.locked), 2, 'katakana_3', () {
                setState(() { if (_u2Kata3Stars < 3) { _u2Kata3Stars++; _saveStarProgress('u2_kata3_stars', _u2Kata3Stars); } });
              }),
              _buildLeftConnector(borderColor),
              _buildClickableNode(context, _t("Katakana Basics 4", "Katakana Dasar 4"), _u2Kata4Stars, _u2Kata4Stars >= 3 ? NodeStatus.completed : (_u2Kata3Stars >= 3 ? NodeStatus.current : NodeStatus.locked), 2, 'katakana_4', () {
                setState(() { if (_u2Kata4Stars < 3) { _u2Kata4Stars++; _saveStarProgress('u2_kata4_stars', _u2Kata4Stars); } });
              }),
              _buildLeftConnector(borderColor),
              _buildClickableNode(context, _t("Katakana Words 1", "Kosakata Katakana 1"), _u2Words1Stars, _u2Words1Stars >= 3 ? NodeStatus.completed : (_u2Kata4Stars >= 3 ? NodeStatus.current : NodeStatus.locked), 2, 'katakana_words_1', () {
                setState(() { if (_u2Words1Stars < 3) { _u2Words1Stars++; _saveStarProgress('u2_words1_stars', _u2Words1Stars); } });
              }),
              _buildLeftConnector(borderColor),
              _buildClickableNode(context, _t("Katakana Words 2", "Kosakata Katakana 2"), _u2Words2Stars, _u2Words2Stars >= 3 ? NodeStatus.completed : (_u2Words1Stars >= 3 ? NodeStatus.current : NodeStatus.locked), 2, 'katakana_words_2', () {
                setState(() { if (_u2Words2Stars < 3) { _u2Words2Stars++; _saveStarProgress('u2_words2_stars', _u2Words2Stars); } });
              }),
              _buildLeftConnector(borderColor),

              // UNIT TEST 2
              _buildClickableNode(
                context, _t("Unit 2 Test\n20 min", "Ujian Unit 2\n20 mnt"), 0,
                _u2TestCompleted >= 1 ? NodeStatus.completed : (_u2Words2Stars >= 3 ? NodeStatus.current : NodeStatus.locked),
                2, 'test', () {
                setState(() {
                  if (_u2TestCompleted == 0) {
                    _u2TestCompleted = 1;
                    _saveStarProgress('u2_test_stars', 1);
                  }
                });
              },
              ),

              const SizedBox(height: 100),
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

  // --- HELPER BUILDER ---
  Widget _buildLeftConnector(Color color) => Container(alignment: Alignment.centerLeft, padding: const EdgeInsets.only(left: 28), child: Container(width: 6, height: 35, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))));

  Widget _buildClickableNode(BuildContext context, String title, int stars, NodeStatus status, int unit, String diff, VoidCallback onSuccess) {
    return GestureDetector(
      onTap: status == NodeStatus.locked ? null : () {
        if (_userHearts <= 0) { _showNoHeartsDialog(); return; }
        Navigator.push(context, MaterialPageRoute(builder: (context) => ExerciseScreen(unit: unit, difficulty: diff, currentStars: stars, currentHearts: _userHearts, onQuizPassed: onSuccess, onHeartDecreased: (h) { setState(() { _userHearts = h; _saveHearts(_userHearts); }); })));
      },
      child: PathNode(title: title, status: status, stars: stars, alignment: Alignment.centerLeft, onReplaySelected: (selectedStarIndex) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ExerciseScreen(unit: unit, difficulty: diff, currentStars: selectedStarIndex)));
      }),
    );
  }

  // 🔥 FUNGSI HEADER BARU: DESAIN MIRIP UNIT 1 (KOTAK BESAR, TEKS BERTUMPUK)
  Widget _buildUnit2HeaderCard(bool isDark, bool unlocked) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        // Menggunakan hijau khas Duolingo/Miraiku jika terbuka
        color: unlocked ? const Color(0xFF58CC02) : (isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE8E3DA)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              'UNIT 2',
              style: TextStyle(color: unlocked ? Colors.white.withValues(alpha: 0.9) : Colors.grey, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.5)
          ),
          const SizedBox(height: 8),
          Text(
              _t('KATAKANA & LOANWORDS', 'KATAKANA & KATA SERAPAN'),
              style: TextStyle(color: unlocked ? Colors.white : (isDark ? Colors.white70 : Colors.black87), fontSize: 24, fontWeight: FontWeight.w900)
          ),
          const SizedBox(height: 12),
          Text(
              unlocked ? _t('Learn the second alphabet system for foreign words', 'Pelajari sistem alfabet kedua untuk kata serapan asing') : _t('Complete Unit 1 Test to unlock', 'Selesaikan Ujian Unit 1 untuk membuka akses'),
              style: TextStyle(color: unlocked ? Colors.white : (isDark ? Colors.white54 : Colors.black54), fontSize: 15, height: 1.4)
          ),
        ],
      ),
    );
  }

  void _showNoHeartsDialog() {
    final bool isDark = globalDarkMode.value;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF9F6F0),
        title: Text(_t('💔 Out of Hearts!', '💔 Nyawa Anda Habis!'), style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF2D2622)), textAlign: TextAlign.center),
        content: Text(_t('You cannot start a new lesson. Please wait or restore your hearts.', 'Anda tidak dapat memulai latihan baru. Silakan tunggu beberapa saat atau pulihkan nyawa.'), textAlign: TextAlign.center, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(_t('UNDERSTOOD', 'MENGERTI'), style: const TextStyle(color: Color(0xFFCC6633), fontWeight: FontWeight.bold)))],
      ),
    );
  }
}