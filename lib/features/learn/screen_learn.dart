import 'package:flutter/material.dart';
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
  int _u1BasicStars = 0;
  int _u1MediumStars = 0;
  int _u1NumbersStars = 0;
  int _u1VerbsStars = 0;
  int _u1TestStars = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const UnitHeaderCard(),
            const SizedBox(height: 50),

            // ==================== TAHAP 1: BASIC ====================
            _buildClickableNode(
              context: context,
              title: "Hiragana Basics",
              stars: _u1BasicStars, // Bintang muncul & bertambah di halaman depan
              // MODIFIKASI LOGIKA STATUS:
              // Node diganti tetap menjadi .completed / .current agar visual node terbuka & bisa diklik ulang meraih bintang selanjutnya.
              status: _u1BasicStars >= 3 ? NodeStatus.completed : NodeStatus.current,
              alignment: Alignment.center,
              unit: 1,
              difficulty: 'basic',
              onSuccess: () {
                setState(() {
                  if (_u1BasicStars < 3) {
                    _u1BasicStars++;
                  }
                });
              },
            ),
            _buildConnector(),

            // ==================== TAHAP 2: MEDIUM ====================
            _buildClickableNode(
              context: context,
              title: "Daily Greetings",
              stars: _u1MediumStars,
              status: _u1MediumStars >= 3
                  ? NodeStatus.completed
                  : (_u1BasicStars >= 3 ? NodeStatus.current : NodeStatus.locked),
              alignment: const Alignment(-0.5, 0),
              unit: 1,
              difficulty: 'medium',
              onSuccess: () {
                setState(() {
                  if (_u1MediumStars < 3) _u1MediumStars++;
                });
              },
            ),
            _buildConnector(),

            // ==================== TAHAP 3: NUMBERS ====================
            _buildClickableNode(
              context: context,
              title: "Numbers & Time",
              stars: _u1NumbersStars,
              status: _u1NumbersStars >= 3
                  ? NodeStatus.completed
                  : (_u1MediumStars >= 3 ? NodeStatus.current : NodeStatus.locked),
              alignment: const Alignment(0.5, 0),
              unit: 1,
              difficulty: 'medium',
              onSuccess: () {
                setState(() {
                  if (_u1NumbersStars < 3) _u1NumbersStars++;
                });
              },
            ),
            _buildConnector(),

            // ==================== TAHAP 4: VERBS ====================
            _buildClickableNode(
              context: context,
              title: "JLPT N5 Verbs",
              stars: _u1VerbsStars,
              status: _u1VerbsStars >= 3
                  ? NodeStatus.completed
                  : (_u1NumbersStars >= 3 ? NodeStatus.current : NodeStatus.locked),
              alignment: Alignment.center,
              unit: 1,
              difficulty: 'medium',
              onSuccess: () {
                setState(() {
                  if (_u1VerbsStars < 3) _u1VerbsStars++;
                });
              },
            ),
            _buildConnector(),

            // ==================== TAHAP 5: HARD (UNIT TEST) ====================
            _buildClickableNode(
              context: context,
              title: "Unit Test\n30 min",
              stars: _u1TestStars,
              status: _u1TestStars >= 3
                  ? NodeStatus.completed
                  : (_u1VerbsStars >= 3 ? NodeStatus.current : NodeStatus.locked),
              alignment: const Alignment(-0.5, 0),
              unit: 1,
              difficulty: 'hard',
              onSuccess: () {
                setState(() {
                  if (_u1TestStars < 3) {
                    _u1TestStars++;
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
              alignment: Alignment.center,
              unit: 2,
              difficulty: 'basic',
              onSuccess: () {},
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildConnector() {
    return Container(
      width: 10,
      height: 45,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E5E5),
        borderRadius: BorderRadius.circular(5),
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExerciseScreen(
              unit: unit,
              difficulty: difficulty,
              currentStars: stars,
              onQuizPassed: onSuccess,
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
                    widget.isUnit1Completed ? 'Mari pelajari sistem alfabet kedua!' : 'Selesaikan 3 bintang pada seluruh tahapan Unit 1 untuk membuka',
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