import 'package:flutter/material.dart';
import '../../core/game_manager.dart'; // Wajib ditambahkan

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  // --- FUNGSI TRANSLATE ---
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
            // --- VARIABEL WARNA DINAMIS ---
            final Color bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF9F6F0);
            final Color cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
            final Color textColor = isDark ? Colors.white : const Color(0xFF2D2622);
            final Color subTextColor = isDark ? Colors.white70 : const Color(0xFF8C8A87);
            final Color readCardColor = isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF0EBE1).withValues(alpha: 0.3);

            return Scaffold(
              backgroundColor: bgColor,
              appBar: AppBar(
                backgroundColor: bgColor, elevation: 0, centerTitle: true,
                leading: IconButton(icon: Icon(Icons.arrow_back_ios_rounded, color: textColor), onPressed: () => Navigator.pop(context)),
                title: Text(_t("Notifications", "Notifikasi"), style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontFamily: 'Serif')),
              ),
              body: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: [
                  Text(_t("TODAY", "HARI INI"), style: const TextStyle(color: Color(0xFF8C8A87), fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                  const SizedBox(height: 16),
                  _buildNotifCard(
                    title: _t("Streak Saved!", "Rekor Terselamatkan!"),
                    message: _t("You practiced Hiragana today. Keep the fire burning tomorrow!", "Kamu berlatih Hiragana hari ini. Pertahankan semangatmu besok!"),
                    icon: Icons.local_fire_department_rounded, iconColor: const Color(0xFFCC6633), time: _t("2h ago", "2j lalu"), isUnread: true,
                    cardColor: cardColor, readCardColor: readCardColor, textColor: textColor, subTextColor: subTextColor,
                  ),
                  const SizedBox(height: 12),
                  _buildNotifCard(
                    title: _t("Achievement Unlocked 🏆", "Pencapaian Terbuka 🏆"),
                    message: _t("Congratulations! You've earned the 'Hiragana Master' badge.", "Selamat! Kamu mendapatkan lencana 'Master Hiragana'."),
                    icon: Icons.emoji_events_rounded, iconColor: const Color(0xFFE08B4B), time: _t("5h ago", "5j lalu"), isUnread: false,
                    cardColor: cardColor, readCardColor: readCardColor, textColor: textColor, subTextColor: subTextColor,
                  ),
                  const SizedBox(height: 32),
                  Text(_t("YESTERDAY", "KEMARIN"), style: const TextStyle(color: Color(0xFF8C8A87), fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                  const SizedBox(height: 16),
                  _buildNotifCard(
                    title: _t("New Lesson Available", "Pelajaran Baru Tersedia"),
                    message: _t("Unit 2: Katakana Expansion is now unlocked for you.", "Unit 2: Ekspansi Katakana sekarang terbuka untukmu."),
                    icon: Icons.menu_book_rounded, iconColor: const Color(0xFF558B2F), time: _t("1d ago", "1h lalu"), isUnread: false,
                    cardColor: cardColor, readCardColor: readCardColor, textColor: textColor, subTextColor: subTextColor,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNotifCard({required String title, required String message, required IconData icon, required Color iconColor, required String time, required bool isUnread, required Color cardColor, required Color readCardColor, required Color textColor, required Color subTextColor}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnread ? cardColor : readCardColor, borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isUnread ? const Color(0xFFCC6633).withValues(alpha: 0.3) : Colors.transparent),
        boxShadow: isUnread ? [BoxShadow(color: const Color(0xFFCC6633).withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))] : [],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(icon, color: iconColor, size: 24)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: isUnread ? textColor : subTextColor))),
                    Text(time, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFB5B0A8))),
                  ],
                ),
                const SizedBox(height: 6),
                Text(message, style: TextStyle(fontSize: 13, height: 1.4, color: isUnread ? subTextColor : const Color(0xFFB5B0A8))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}