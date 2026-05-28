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
                await Supabase.instance.client.auth.updateUser(UserAttributes(data: {'unlocked_sim_n5': true}));
                setState(() => _isUnlocked = true);
                _showSuccessUnlock();
              } else if (globalXP.value >= 150) {
                globalXP.value -= 150;
                await GameManager.syncToCloud();
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
        final Color textColor = isDark ? Colors.white : const Color(0xFF2D2622);
        final Color subTextColor = isDark ? Colors.white70 : const Color(0xFF666666);

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
              _t("SIMULATION", "SIMULASI UJIAN"),
              style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCC6633).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Text(
                      "OFFICIAL JLPT N5 STANDARD",
                      style: TextStyle(color: Color(0xFFCC6633), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _t("JLPT N5 Mock Exam", "Simulasi Ujian JLPT N5"),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: textColor, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _t(
                      "Professional simulation covering Language Knowledge and Reading. Test your skills under official timing constraints.",
                      "Simulasi profesional mencakup Pengetahuan Bahasa dan Membaca. Uji kemampuanmu dalam batasan waktu resmi."
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: subTextColor, fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 32),

                  _buildExamStructureCard(isDark, textColor, subTextColor),
                  const SizedBox(height: 20),
                  _buildGradingSystemCard(isDark, textColor, subTextColor),
                  const SizedBox(height: 20),
                  _buildOneAttemptCard(isDark, textColor, subTextColor),
                  const SizedBox(height: 32),
                  _buildUnlockButtonSection(subTextColor),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExamStructureCard(bool isDark, Color textColor, Color subTextColor) {
    final Color cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color sectionColor = isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF8F9FA);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFCC6633).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.assignment_rounded, color: Color(0xFFCC6633), size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                _t("Test Modules", "Modul Ujian"),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSessionDetail(
            title: _t("Language Knowledge", "Pengetahuan Bahasa"),
            subtitle: "Moji, Goi, Bunpou",
            duration: "25",
            description: _t(
              "Kanji reading, vocabulary context, and grammar particles.",
              "Cara baca Kanji, kosakata sesuai konteks, dan partikel tata bahasa."
            ),
            isDark: isDark,
            textColor: textColor,
            subTextColor: subTextColor,
            bgColor: sectionColor,
          ),
          const SizedBox(height: 16),
          _buildSessionDetail(
            title: _t("Reading", "Membaca"),
            subtitle: "Dokkai",
            duration: "50",
            description: _t(
              "Short sentences, paragraphs, and informational texts.",
              "Kalimat pendek, paragraf, dan teks informasi (email/pengumuman)."
            ),
            isDark: isDark,
            textColor: textColor,
            subTextColor: subTextColor,
            bgColor: sectionColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSessionDetail({
    required String title,
    required String subtitle,
    required String duration,
    required String description,
    required bool isDark,
    required Color textColor,
    required Color subTextColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                  Text(subtitle, style: const TextStyle(color: Color(0xFFCC6633), fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFCC6633),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text("$duration mnt", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(description, style: TextStyle(color: subTextColor, fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildGradingSystemCard(bool isDark, Color textColor, Color subTextColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFF2D2622),
        borderRadius: BorderRadius.circular(24),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: const Color(0xFF2D2622).withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics_rounded, color: Color(0xFFCC6633), size: 24),
              const SizedBox(width: 12),
              Text(
                _t("Grading System", "Sistem Penilaian"),
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildGradeStat(_t("MAX SCORE", "SKOR MAKS"), "180", Colors.white),
              Container(width: 1, height: 40, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 24)),
              _buildGradeStat(_t("PASSING GRADE", "BATAS LULUS"), "80", const Color(0xFFCC6633)),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _t(
                "Pass criteria: Total score ≥ 80 AND meet minimum sectional standard. Zero score in any section results in failure.",
                "Kriteria lulus: Skor total ≥ 80 DAN memenuhi standar minimum tiap sesi. Skor nol pada sesi mana pun dianggap tidak lulus."
              ),
              style: const TextStyle(color: Colors.white60, fontSize: 11, fontStyle: FontStyle.italic, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeStat(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: valueColor, fontSize: 28, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildOneAttemptCard(bool isDark, Color textColor, Color subTextColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFCC6633).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFCC6633).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.gavel_rounded, color: Color(0xFFCC6633), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _t("Strict Exam Rules", "Aturan Ujian Ketat"),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
                ),
                const SizedBox(height: 4),
                Text(
                  _t("Continuous timer. No pauses. Result is final.", "Waktu berjalan terus. Tanpa jeda. Hasil bersifat final."),
                  style: TextStyle(fontSize: 12, color: subTextColor),
                ),
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
          height: 60,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCC6633),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            onPressed: _handleUnlock,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _isUnlocked ? _t("START SIMULATION", "MULAI SIMULASI") : _t("UNLOCK ACCESS", "BUKA AKSES UJIAN"), 
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)
                ),
                const SizedBox(width: 12),
                Icon(_isUnlocked ? Icons.play_arrow_rounded : Icons.lock_open_rounded, size: 22),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (!_isUnlocked)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.flash_on_rounded, color: Color(0xFFCC6633), size: 14),
              const SizedBox(width: 4),
              Text(
                _t("Cost: 150 XP (Free for Premium)", "Biaya: 150 XP (Gratis untuk Premium)"), 
                style: TextStyle(color: subTextColor, fontSize: 12, fontWeight: FontWeight.w500)
              ),
            ],
          ),
      ],
    );
  }
}
