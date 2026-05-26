import 'package:flutter/material.dart';
import '../core/game_manager.dart'; // Wajib ditambahkan untuk memanggil global state

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  // --- FUNGSI TRANSLATE OTOMATIS ---
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
            final Color navBgColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF9F6F0);
            final Color shadowColor = isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.05);
            final Color inactiveColor = isDark ? Colors.white54 : const Color(0xFF8C8A87);

            return Container(
              padding: const EdgeInsets.only(top: 8, bottom: 16, left: 8, right: 8),
              decoration: BoxDecoration(
                color: navBgColor,
                boxShadow: [
                  BoxShadow(color: shadowColor, blurRadius: 10, offset: const Offset(0, -5)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, _t("LEARN", "BELAJAR"), inactiveColor, iconData: Icons.menu_book_rounded),
                  _buildNavItem(1, _t("SIMULATION", "SIMULASI"), inactiveColor, iconData: Icons.edit_note_rounded),
                  _buildNavItem(2, _t("ALPHABET", "ALFABET"), inactiveColor, textIcon: "あ"),
                  _buildNavItem(3, _t("PROFILE", "PROFIL"), inactiveColor, iconData: Icons.account_circle_outlined),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNavItem(int index, String label, Color inactiveColor, {IconData? iconData, String? textIcon}) {
    bool isActive = selectedIndex == index;
    Color itemColor = isActive ? Colors.white : inactiveColor;
    double iconSize = isActive ? 24.0 : 28.0;

    Widget iconWidget;
    if (textIcon != null) {
      iconWidget = Text(
        textIcon,
        style: TextStyle(
          color: itemColor,
          fontSize: iconSize,
          fontWeight: FontWeight.bold,
          height: 1.0,
        ),
      );
    } else {
      iconWidget = Icon(iconData, color: itemColor, size: iconSize);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(12),
        splashColor: const Color(0xFFCC6633).withValues(alpha: 0.2), // Menggunakan withValues agar tidak warning
        highlightColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFCC6633) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              iconWidget,
              const SizedBox(height: 4),
              Text(
                  label,
                  style: TextStyle(
                      color: itemColor, // Mengikuti warna item (putih saat aktif, abu-abu/putih transparan saat nonaktif)
                      fontSize: 10,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w600
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }
}