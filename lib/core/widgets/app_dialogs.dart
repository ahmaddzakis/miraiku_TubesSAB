import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../game_manager.dart';

class AppDialogs {
  static String _t(String en, String id) {
    return globalLanguage.value == 'id' ? id : en;
  }

  static void showAboutApp(BuildContext context) async {
    final info = await PackageInfo.fromPlatform();
    final String version = 'v${info.version}';

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return ValueListenableBuilder<bool>(
          valueListenable: globalDarkMode,
          builder: (context, isDark, _) {
            return ValueListenableBuilder<String>(
              valueListenable: globalLanguage,
              builder: (context, lang, _) {
                final Color bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
                final Color textColor = isDark ? Colors.white : const Color(0xFF333333);
                final Color subTextColor = isDark ? Colors.white70 : const Color(0xFF666666);
                final Color primaryColor = const Color(0xFFCC6633);

                return Dialog(
                  backgroundColor: bgColor,
                  insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 32,
                        top: 32,
                        right: 32,
                        bottom: MediaQuery.of(context).padding.bottom + 32,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header Row
                          Row(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF1EFE8),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    if (!isDark)
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 15,
                                        offset: const Offset(0, 8),
                                      ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: Image.asset(
                                    'assets/images/iconUtama.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "MIRAIku",
                                      style: TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w900,
                                        color: textColor,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    Text(
                                      version,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: subTextColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Description
                          Text(
                            _t(
                              "MIRAIku is an interactive Japanese language learning platform designed to help users efficiently master Hiragana, Katakana, and essential vocabulary. Built with engaging gamification elements, MIRAIku makes the journey to Japanese fluency enjoyable, structured, and effective.",
                              "MIRAIku adalah platform pembelajaran bahasa Jepang interaktif yang dirancang untuk membantu pengguna menguasai Hiragana, Katakana, dan kosakata penting secara efisien. Dibangun dengan elemen gamifikasi yang menarik, MIRAIku membuat perjalanan menuju kemahiran bahasa Jepang menjadi menyenangkan, terstruktur, dan efektif."
                            ),
                            style: TextStyle(
                              fontSize: 15,
                              color: subTextColor,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Developed By Badge
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  primaryColor.withValues(alpha: 0.12),
                                  primaryColor.withValues(alpha: 0.05),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: primaryColor.withValues(alpha: 0.15),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.auto_awesome_rounded,
                                    size: 20,
                                    color: primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _t("Developed by", "Dikembangkan oleh"),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: primaryColor.withValues(alpha: 0.7),
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "Michibon Lab",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                          color: primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Actions
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  showLicensePage(
                                    context: context,
                                    applicationName: "MIRAIku",
                                    applicationVersion: version,
                                    applicationIcon: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image.asset('assets/images/iconUtama.png', width: 64),
                                      ),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: subTextColor,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                ),
                                child: Text(
                                  _t("VIEW LICENSES", "LIHAT LISENSI"),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  _t("CLOSE", "TUTUP"),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
