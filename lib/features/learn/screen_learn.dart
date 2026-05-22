import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/path_node.dart';
import 'widget_learn.dart'; // Pastikan path ini sesuai dengan struktur projek Anda
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
  int _u1BasicStars = 0;
  int _u1MediumStars = 0;
  int _u1NumbersStars = 0;
  int _u1VerbsStars = 0;
  int _u1TestStars = 0;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F6F0),
        elevation: 0,
        title: const Text(
          "MIRAIKU",
          style: TextStyle(color: Color(0xFFCC6633), fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        actions: [
          Row(
            children: [
              const Icon(Icons.local_fire_department_rounded, color: Colors.orange),
              const SizedBox(width: 2),
              const Text("7", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
              const Icon(Icons.stars_rounded, color: Colors.amber),
              const SizedBox(width: 2),
              const Text("450", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
              const SizedBox(width: 16),

              // ==================== INDIKATOR NYAWA ====================
              Row(
                children: [
                  const Icon(Icons.favorite, color: Colors.red, size: 22),
                  const SizedBox(width: 4),
                  Text(
                    "$_userHearts",
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(width: 20),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const UnitHeaderCard(),
              const SizedBox(height: 40),

              // ==================== TAHAP 1: BASIC ====================
              _buildClickableNode(
                context: context,
                title: "Hiragana Basics",
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
              _buildLeftConnector(),

              // ==================== TAHAP 2: MEDIUM ====================
              _buildClickableNode(
                context: context,
                title: "Daily Greetings",
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
              _buildLeftConnector(),

              // ==================== TAHAP 3: NUMBERS ====================
              _buildClickableNode(
                context: context,
                title: "Numbers & Time",
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
              _buildLeftConnector(),

              // ==================== TAHAP 4: VERBS ====================
              _buildClickableNode(
                context: context,
                title: "JLPT N5 Verbs",
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
              _buildLeftConnector(),

              // ==================== TAHAP 5: HARD (UNIT TEST) ====================
              _buildClickableNode(
                context: context,
                title: "Unit Test\n30 min",
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
              const Divider(thickness: 2, color: Color(0xFFE8E3DA)),
              const SizedBox(height: 20),

              _buildUnit2Header(),
              const SizedBox(height: 40),

              _buildClickableNode(
                context: context,
                title: "Katakana Basics",
                stars: 0,
                status: widget.isUnit1Completed ? NodeStatus.current : NodeStatus.locked,
                alignment: Alignment.centerLeft,
                unit: 2,
                difficulty: 'basic',
                onSuccess: () {},
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeftConnector() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 28),
      child: Container(
        width: 6,
        height: 35,
        decoration: BoxDecoration(
          color: const Color(0xFFE8E3DA),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFFF9F6F0),
        title: const Text(
          '💔 Nyawa Anda Habis!',
          style: TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'Anda tidak dapat memulai latihan baru. Silakan tunggu beberapa saat atau pulihkan nyawa di menu utama.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('MENGERTI', style: TextStyle(color: Color(0xFFCC6633), fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildUnit2Header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.isUnit1Completed ? const Color(0xFFCC6633) : const Color(0xFFDCD8CF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E3DA)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                    'Unit 2: Katakana Expansion',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 4),
                Text(
                    widget.isUnit1Completed ? 'Mari pelajari sistem alfabet kedua!' : 'Selesaikan seluruh tahapan Unit 1 untuk membuka',
                    style: const TextStyle(color: Colors.white70, fontSize: 12)
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Icon(
              widget.isUnit1Completed ? Icons.lock_open_rounded : Icons.lock_rounded,
              color: Colors.white,
              size: 26
          ),
        ],
      ),
    );
  }
}