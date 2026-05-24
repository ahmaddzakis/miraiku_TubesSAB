import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart'; // Wajib ditambahkan untuk memanggil global state
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
  int _u1BasicStars = 0;
  int _u1MediumStars = 0;
  int _u1NumbersStars = 0;
  int _u1VerbsStars = 0;
  int _u1TestStars = 0;

  // --- STATE UNIT 2 (Katakana) ---
  int _u2BasicStars = 0;
  int _u2WordsStars = 0;
  int _u2LoanwordsStars = 0;
  int _u2TestStars = 0;

  // Nyawa global pengguna (Default: 5)
  int _userHearts = 5;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _u1BasicStars = prefs.getInt('u1_basic_stars') ?? 0;
      _u1MediumStars = prefs.getInt('u1_medium_stars') ?? 0;
      _u1NumbersStars = prefs.getInt('u1_numbers_stars') ?? 0;
      _u1VerbsStars = prefs.getInt('u1_verbs_stars') ?? 0;
      _u1TestStars = prefs.getInt('u1_test_stars') ?? 0;

      _u2BasicStars = prefs.getInt('u2_basic_stars') ?? 0;
      _u2WordsStars = prefs.getInt('u2_words_stars') ?? 0;
      _u2LoanwordsStars = prefs.getInt('u2_loanwords_stars') ?? 0;
      _u2TestStars = prefs.getInt('u2_test_stars') ?? 0;

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

  // --- FUNGSI TRANSLATE OTOMATIS ---
  String _t(String en, String id) {
    return globalLanguage.value == 'id' ? id : en;
  }

  @override
  Widget build(BuildContext context) {
    // --- VARIABEL WARNA DINAMIS ---
    final bool isDark = globalDarkMode.value;
    final Color bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF9F6F0);
    final Color borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFE8E3DA);

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
              const UnitHeaderCard(), // Catatan: Widget ini mungkin perlu kamu update juga ke depannya agar mendukung Dark Mode
              const SizedBox(height: 40),

              // ==================== UNIT 1: HIRAGANA & BASICS ====================
              _buildClickableNode(
                context: context,
                title: _t("Hiragana Basics", "Dasar Hiragana"),
                stars: _u1BasicStars,
                status: _u1BasicStars >= 3 ? NodeStatus.completed : NodeStatus.current,
                alignment: Alignment.centerLeft,
                unit: 1,
                difficulty: 'basic',
                onSuccess: () {
                  setState(() {
                    if (_u1BasicStars < 3) {
                      _u1BasicStars++;
                      _saveStarProgress('u1_basic_stars', _u1BasicStars);
                    }
                  });
                },
              ),
              _buildLeftConnector(borderColor),

              _buildClickableNode(
                context: context,
                title: _t("Daily Greetings", "Salam Sehari-hari"),
                stars: _u1MediumStars,
                status: _u1MediumStars >= 3
                    ? NodeStatus.completed
                    : (_u1BasicStars >= 3 ? NodeStatus.current : NodeStatus.locked),
                alignment: Alignment.centerLeft,
                unit: 1,
                difficulty: 'medium',
                onSuccess: () {
                  setState(() {
                    if (_u1MediumStars < 3) {
                      _u1MediumStars++;
                      _saveStarProgress('u1_medium_stars', _u1MediumStars);
                    }
                  });
                },
              ),
              _buildLeftConnector(borderColor),

              _buildClickableNode(
                context: context,
                title: _t("Numbers & Time", "Angka & Waktu"),
                stars: _u1NumbersStars,
                status: _u1NumbersStars >= 3
                    ? NodeStatus.completed
                    : (_u1MediumStars >= 3 ? NodeStatus.current : NodeStatus.locked),
                alignment: Alignment.centerLeft,
                unit: 1,
                difficulty: 'medium',
                onSuccess: () {
                  setState(() {
                    if (_u1NumbersStars < 3) {
                      _u1NumbersStars++;
                      _saveStarProgress('u1_numbers_stars', _u1NumbersStars);
                    }
                  });
                },
              ),
              _buildLeftConnector(borderColor),

              _buildClickableNode(
                context: context,
                title: _t("JLPT N5 Verbs", "Kata Kerja N5"),
                stars: _u1VerbsStars,
                status: _u1VerbsStars >= 3
                    ? NodeStatus.completed
                    : (_u1NumbersStars >= 3 ? NodeStatus.current : NodeStatus.locked),
                alignment: Alignment.centerLeft,
                unit: 1,
                difficulty: 'medium',
                onSuccess: () {
                  setState(() {
                    if (_u1VerbsStars < 3) {
                      _u1VerbsStars++;
                      _saveStarProgress('u1_verbs_stars', _u1VerbsStars);
                    }
                  });
                },
              ),
              _buildLeftConnector(borderColor),

              _buildClickableNode(
                context: context,
                title: _t("Unit Test\n30 min", "Ujian Unit\n30 mnt"),
                stars: _u1TestStars,
                status: _u1TestStars >= 3
                    ? NodeStatus.completed
                    : (_u1VerbsStars >= 3 ? NodeStatus.current : NodeStatus.locked),
                alignment: Alignment.centerLeft,
                unit: 1,
                difficulty: 'hard',
                onSuccess: () {
                  setState(() {
                    if (_u1TestStars < 3) {
                      _u1TestStars++;
                      _saveStarProgress('u1_test_stars', _u1TestStars);
                      if (_u1TestStars == 3) {
                        widget.onUnit1Completed();
                      }
                    }
                  });
                },
              ),

              const SizedBox(height: 40),
              Divider(thickness: 2, color: borderColor),
              const SizedBox(height: 20),

              // ==================== UNIT 2: KATAKANA EXPANSION ====================
              _buildUnit2Header(isDark),
              const SizedBox(height: 40),

              _buildClickableNode(
                context: context,
                title: _t("Katakana Basics", "Dasar Katakana"),
                stars: _u2BasicStars,
                status: _u2BasicStars >= 3
                    ? NodeStatus.completed
                    : (widget.isUnit1Completed ? NodeStatus.current : NodeStatus.locked),
                alignment: Alignment.centerLeft,
                unit: 2,
                difficulty: 'basic',
                onSuccess: () {
                  setState(() {
                    if (_u2BasicStars < 3) {
                      _u2BasicStars++;
                      _saveStarProgress('u2_basic_stars', _u2BasicStars);
                    }
                  });
                },
              ),
              _buildLeftConnector(borderColor),

              _buildClickableNode(
                context: context,
                title: _t("Katakana Words", "Kosakata Katakana"),
                stars: _u2WordsStars,
                status: _u2WordsStars >= 3
                    ? NodeStatus.completed
                    : (_u2BasicStars >= 3 ? NodeStatus.current : NodeStatus.locked),
                alignment: Alignment.centerLeft,
                unit: 2,
                difficulty: 'medium',
                onSuccess: () {
                  setState(() {
                    if (_u2WordsStars < 3) {
                      _u2WordsStars++;
                      _saveStarProgress('u2_words_stars', _u2WordsStars);
                    }
                  });
                },
              ),
              _buildLeftConnector(borderColor),

              _buildClickableNode(
                context: context,
                title: _t("Foreign Loanwords", "Kata Serapan Asing"),
                stars: _u2LoanwordsStars,
                status: _u2LoanwordsStars >= 3
                    ? NodeStatus.completed
                    : (_u2WordsStars >= 3 ? NodeStatus.current : NodeStatus.locked),
                alignment: Alignment.centerLeft,
                unit: 2,
                difficulty: 'medium',
                onSuccess: () {
                  setState(() {
                    if (_u2LoanwordsStars < 3) {
                      _u2LoanwordsStars++;
                      _saveStarProgress('u2_loanwords_stars', _u2LoanwordsStars);
                    }
                  });
                },
              ),
              _buildLeftConnector(borderColor),

              _buildClickableNode(
                context: context,
                title: _t("Unit 2 Test\n30 min", "Ujian Unit 2\n30 mnt"),
                stars: _u2TestStars,
                status: _u2TestStars >= 3
                    ? NodeStatus.completed
                    : (_u2LoanwordsStars >= 3 ? NodeStatus.current : NodeStatus.locked),
                alignment: Alignment.centerLeft,
                unit: 2,
                difficulty: 'hard',
                onSuccess: () {
                  setState(() {
                    if (_u2TestStars < 3) {
                      _u2TestStars++;
                      _saveStarProgress('u2_test_stars', _u2TestStars);
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
  }

  Widget _buildLeftConnector(Color borderColor) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 28),
      child: Container(
        width: 6,
        height: 35,
        decoration: BoxDecoration(
          color: borderColor,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }

  Widget _buildClickableNode({
    required BuildContext context,
    required String title,
    required int stars,
    required NodeStatus status,
    required Alignment alignment,
    required int unit,
    required String difficulty,
    required VoidCallback onSuccess,
  }) {
    return GestureDetector(
      onTap: status == NodeStatus.locked
          ? null
          : () {
        if (_userHearts <= 0) {
          _showNoHeartsDialog();
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExerciseScreen(
              unit: unit,
              difficulty: difficulty,
              currentStars: stars,
              currentHearts: _userHearts,
              onQuizPassed: onSuccess,
              onHeartDecreased: (updatedHearts) {
                setState(() {
                  _userHearts = updatedHearts;
                  _saveHearts(_userHearts);
                });
              },
            ),
          ),
        );
      },
      child: PathNode(
        title: title,
        status: status,
        alignment: alignment,
        stars: stars,
      ),
    );
  }

  void _showNoHeartsDialog() {
    final bool isDark = globalDarkMode.value;
    final Color modalBg = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF9F6F0);
    final Color textColor = isDark ? Colors.white : const Color(0xFF2D2622);
    final Color subTextColor = isDark ? Colors.white70 : Colors.black87;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: modalBg,
        title: Text(
          _t('💔 Out of Hearts!', '💔 Nyawa Anda Habis!'),
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
          textAlign: TextAlign.center,
        ),
        content: Text(
          _t(
              'You cannot start a new lesson. Please wait or restore your hearts.',
              'Anda tidak dapat memulai latihan baru. Silakan tunggu beberapa saat atau pulihkan nyawa.'
          ),
          textAlign: TextAlign.center,
          style: TextStyle(color: subTextColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_t('UNDERSTOOD', 'MENGERTI'), style: const TextStyle(color: Color(0xFFCC6633), fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildUnit2Header(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.isUnit1Completed
            ? const Color(0xFF558B2F)
            : (isDark ? const Color(0xFF2D2D2D) : const Color(0xFFDCD8CF)), // Penyesuaian warna gembok terkunci saat Dark Mode
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFE8E3DA)),
        boxShadow: widget.isUnit1Completed ? [
          BoxShadow(
            color: const Color(0xFF558B2F).withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ] : [],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                    'UNIT 2',
                    style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)
                ),
                const SizedBox(height: 4),
                Text(
                    _t('KATAKANA & LOANWORDS', 'KATAKANA & KATA SERAPAN'),
                    style: TextStyle(color: widget.isUnit1Completed ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF2D2622)), fontSize: 18, fontWeight: FontWeight.w900)
                ),
                const SizedBox(height: 8),
                Text(
                    widget.isUnit1Completed
                        ? _t('Let\'s learn the second alphabet system!', 'Mari pelajari sistem alfabet untuk bahasa asing!')
                        : _t('Complete all Unit 1 stages to unlock', 'Selesaikan seluruh tahapan Unit 1 untuk membuka'),
                    style: TextStyle(color: widget.isUnit1Completed ? Colors.white : (isDark ? Colors.white54 : Colors.black54), fontSize: 12)
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Icon(
              widget.isUnit1Completed ? Icons.lock_open_rounded : Icons.lock_rounded,
              color: widget.isUnit1Completed ? Colors.white : (isDark ? Colors.white54 : Colors.black54),
              size: 32
          ),
        ],
      ),
    );
  }
}