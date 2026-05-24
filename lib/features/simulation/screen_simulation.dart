import 'package:flutter/material.dart';
import '../../main.dart'; // Wajib ditambahkan untuk memanggil global state

class SimulationScreen extends StatelessWidget {
  const SimulationScreen({super.key});

  // --- FUNGSI TRANSLATE OTOMATIS ---
  String _t(String en, String id) {
    return globalLanguage.value == 'id' ? id : en;
  }

  @override
  Widget build(BuildContext context) {
    // --- VARIABEL WARNA DINAMIS ---
    final bool isDark = globalDarkMode.value;
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
            onPressed: () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_t("Unlock & Start Test", "Buka & Mulai Ujian"), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(width: 8),
                const Icon(Icons.rocket_launch, size: 20, color: Colors.white),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(_t("Price: 150 XP or Free with Premium", "Harga: 150 XP atau Gratis dengan Premium"), style: TextStyle(color: subTextColor, fontSize: 12)),
      ],
    );
  }
}