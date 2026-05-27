import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/game_manager.dart';
import 'screen_simulation_test.dart';

class SimulationScreen extends StatefulWidget {
  const SimulationScreen({super.key});

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen> {
  bool _isUnlocked = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkUnlockStatus();
  }

  void _checkUnlockStatus() {
    final user = Supabase.instance.client.auth.currentUser;
    final meta = user?.userMetadata ?? {};
    setState(() {
      _isUnlocked = meta['unlocked_sim_n5'] ?? false;
      _isLoading = false;
    });
  }

  Future<void> _handleUnlock() async {
    if (_isUnlocked) {
      _startTest();
      return;
    }

    final bool isDark = globalDarkMode.value;
    final Color modalBg = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFAF7F2);
    final Color textColor = isDark ? Colors.white : const Color(0xFF2D2622);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: modalBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(_t("Unlock Simulation", "Buka Simulasi"), style: TextStyle(fontWeight: FontWeight.w900, color: textColor)),
        content: Text(
          globalIsPremium.value 
            ? _t("You have Premium access! Unlock JLPT N5 Simulation for free?", "Kamu memiliki akses Premium! Buka Simulasi JLPT N5 secara gratis?")
            : _t("Unlock JLPT N5 Simulation for 150 XP? This will give you permanent access.", "Buka Simulasi JLPT N5 seharga 150 XP? Kamu akan mendapatkan akses permanen."),
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(_t("Cancel", "Batal"), style: const TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFCC6633), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () async {
              Navigator.pop(context);
              if (globalIsPremium.value) {
                // Free for premium
                await Supabase.instance.client.auth.updateUser(UserAttributes(data: {'unlocked_sim_n5': true}));
                setState(() => _isUnlocked = true);
                _showSuccessUnlock();
              } else if (globalXP.value >= 150) {
                globalXP.value -= 150;
                await GameManager.syncToCloud();
                
                // Update specific metadata for unlock
                await Supabase.instance.client.auth.updateUser(UserAttributes(data: {'unlocked_sim_n5': true}));
                
                setState(() => _isUnlocked = true);
                _showSuccessUnlock();
              } else {
                _showInsufficientXP();
              }
            },
            child: Text(_t("Unlock", "Buka"), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSuccessUnlock() {
    _showCustomDialog(
      title: _t("Simulation Unlocked!", "Simulasi Terbuka!"),
      message: _t("You now have permanent access to JLPT N5 Simulation. 🎉", "Kamu sekarang memiliki akses permanen ke Simulasi JLPT N5. 🎉"),
      icon: Icons.check_circle_outline_rounded,
      iconColor: Colors.green,
    );
  }

  void _showInsufficientXP() {
    _showCustomDialog(
      title: _t("Insufficient XP", "XP Tidak Cukup"),
      message: _t("Keep learning and completing lessons to earn more XP!", "Teruslah belajar dan selesaikan pelajaran untuk mengumpulkan lebih banyak XP!"),
      icon: Icons.error_outline_rounded,
      iconColor: Colors.red,
    );
  }

  void _showCustomDialog({
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = globalDarkMode.value;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 48, color: iconColor),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF2D2622),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCC6633),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text("OK"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _startTest() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SimulationTestScreen()),
    );
  }

  String _t(String en, String id) {
    return globalLanguage.value == 'id' ? id : en;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: Color(0xFFCC6633)));

    return ValueListenableBuilder<bool>(
      valueListenable: globalDarkMode,
      builder: (context, isDark, _) {
        final Color bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFAF7F2);
        final Color textColor = isDark ? Colors.white : const Color(0xFF3E362E);
        final Color subTextColor = isDark ? Colors.white70 : Colors.black54;

        return Scaffold(
          backgroundColor: bgColor,
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  Text(
                    _t("JAPANESE PROFICIENCY", "KEMAMPUAN BAHASA JEPANG"),
                    style: const TextStyle(color: Color(0xFFCC6633), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _t("JLPT N5 Full\nMock", "Simulasi Penuh\nJLPT N5"),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600, height: 1.2, color: textColor),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _t(
                        "Experience the complete standardized test environment. This simulation follows the official JLPT structure and timing to prepare you for success.",
                        "Rasakan lingkungan ujian berstandar yang sesungguhnya. Simulasi ini mengikuti struktur dan waktu JLPT resmi untuk mempersiapkan kelulusanmu."
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: subTextColor, fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 30),

                  _buildExamStructureCard(isDark, textColor, subTextColor),
                  const SizedBox(height: 20),
                  _buildOneAttemptCard(isDark, textColor, subTextColor),
                  const SizedBox(height: 20),
                  _buildRequirementNote(isDark, textColor),
                  const SizedBox(height: 30),
                  _buildUnlockButtonSection(subTextColor),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExamStructureCard(bool isDark, Color textColor, Color subTextColor) {
    final Color cardColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF2EBE1);
    final Color tileColor = isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF9F6F0);
    final Color iconBgColor = isDark ? const Color(0xFF3D3D3D) : const Color(0xFFEBE5DB);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF333333) : Colors.transparent),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insert_chart_outlined, color: textColor),
              const SizedBox(width: 10),
              Text(_t("Exam Structure", "Struktur Ujian"), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textColor)),
            ],
          ),
          const SizedBox(height: 20),
          _buildStatRow(_t("DURATION", "DURASI"), "105", _t(" min", " mnt"), textColor),
          const SizedBox(height: 16),
          _buildStatRow(_t("QUESTIONS", "PERTANYAAN"), "80", _t(" total", " total"), textColor),
          const SizedBox(height: 16),
          _buildStatRow(_t("DIFFICULTY", "KESULITAN"), "N5", _t(" entry", " dasar"), textColor),
          const SizedBox(height: 24),
          _buildSectionTile(Icons.translate, _t("Vocabulary", "Kosakata"), _t("Language Knowledge", "Pengetahuan Bahasa"), _t("25 Min", "25 Mnt"), tileColor, iconBgColor, textColor, subTextColor),
          const SizedBox(height: 10),
          _buildSectionTile(Icons.menu_book, _t("Grammar & Reading", "Tata Bahasa & Membaca"), _t("Structure and Comprehension", "Struktur dan Pemahaman"), _t("50 Min", "50 Mnt"), tileColor, iconBgColor, textColor, subTextColor),
          const SizedBox(height: 10),
          _buildSectionTile(Icons.hearing, _t("Listening", "Mendengarkan"), _t("Audio Section", "Bagian Audio"), _t("30 Min", "30 Mnt"), tileColor, iconBgColor, textColor, subTextColor),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, String unit, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.grey)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(value, style: const TextStyle(color: Color(0xFFCC6633), fontSize: 24, fontWeight: FontWeight.w600)),
            Text(unit, style: TextStyle(color: textColor, fontSize: 14)),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTile(IconData icon, String title, String subtitle, String time, Color tileColor, Color iconBgColor, Color textColor, Color subTextColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: tileColor, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
            child: Icon(icon, color: textColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: textColor)),
                Text(subtitle, style: TextStyle(color: subTextColor, fontSize: 11)),
              ],
            ),
          ),
          Text(time, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: textColor)),
        ],
      ),
    );
  }

  Widget _buildOneAttemptCard(bool isDark, Color textColor, Color subTextColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFEBE5DB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF333333) : Colors.transparent),
      ),
      child: Column(
        children: [
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(12),
              image: const DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1596484552834-6a58f850e0a1?auto=format&fit=crop&q=80&w=400'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(_t("One Attempt Only", "Hanya Satu Kali Percobaan"), style: const TextStyle(color: Color(0xFFCC6633), fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(
              _t("Finish in one sitting. Timer cannot be paused once the listening section begins.", "Selesaikan dalam satu sesi. Waktu tidak dapat dijeda setelah bagian mendengarkan dimulai."),
              textAlign: TextAlign.center,
              style: TextStyle(color: subTextColor, fontSize: 13, fontStyle: FontStyle.italic)
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementNote(bool isDark, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: isDark ? const Color(0xFF3A2415) : const Color(0xFFF0DEC9),
          borderRadius: BorderRadius.circular(12)
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Color(0xFFCC6633), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_t("REQUIREMENT", "PERSYARATAN"), style: const TextStyle(color: Color(0xFFCC6633), fontSize: 10, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(_t("Headphones recommended for the listening portion.", "Disarankan menggunakan *headphone* untuk bagian mendengarkan."), style: TextStyle(color: textColor, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnlockButtonSection(Color subTextColor) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCC6633),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: _handleUnlock,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _isUnlocked ? _t("Start Simulation", "Mulai Simulasi") : _t("Unlock & Start Test", "Buka & Mulai Ujian"), 
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)
                ),
                const SizedBox(width: 8),
                Icon(_isUnlocked ? Icons.play_arrow_rounded : Icons.rocket_launch, size: 20, color: Colors.white),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (!_isUnlocked)
          Text(_t("Price: 150 XP or Free with Premium", "Harga: 150 XP atau Gratis dengan Premium"), style: TextStyle(color: subTextColor, fontSize: 12)),
      ],
    );
  }
}
