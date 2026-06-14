import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screen_auth.dart';
import 'package:miraiku/core/game_manager.dart';
import 'package:miraiku/core/notification_service.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Set defaults to light and english as requested
    WidgetsBinding.instance.addPostFrameCallback((_) {
      globalDarkMode.value = false;
      globalLanguage.value = 'en';
    });
  }

  String _t(String en, String id) {
    return globalLanguage.value == 'id' ? id : en;
  }

  final List<Map<String, String>> _onboardingData = [
    {
      "title_en": "Learn Japanese",
      "title_id": "Belajar Bahasa Jepang",
      "subtitle_en": "Master Hiragana, Katakana, and Kanji with interactive and fun learning modules.",
      "subtitle_id": "Kuasai Hiragana, Katakana, dan Kanji dengan modul pembelajaran yang interaktif dan menyenangkan.",
      "image": "assets/images/belajar.png",
    },
    {
      "title_en": "Interactive Simulation",
      "title_id": "Simulasi Interaktif",
      "subtitle_en": "Test your skills with JLPT N5 exam simulations designed according to official standards.",
      "subtitle_id": "Uji kemampuan Anda dengan simulasi ujian JLPT N5 yang dirancang sesuai standar resmi.",
      "image": "assets/images/simulasi.png",
    },
    {
      "title_en": "Track Your Progress",
      "title_id": "Pantau Progresmu",
      "subtitle_en": "See your achievements and learning history in real-time to keep motivating yourself.",
      "subtitle_id": "Lihat pencapaian dan riwayat belajar Anda secara real-time untuk terus memotivasi diri.",
      "image": "assets/images/progres.png",
    },
  ];

  Future<void> _completeOnboarding() async {
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: globalDarkMode,
      builder: (context, isDark, _) {
        return ValueListenableBuilder<String>(
          valueListenable: globalLanguage,
          builder: (context, lang, _) {
            final Color bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF9F6F0);
            final Color textColor = isDark ? Colors.white : const Color(0xFF2D2622);

            return Scaffold(
              backgroundColor: bgColor,
              body: SafeArea(
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Expanded(
                          flex: 3,
                          child: PageView.builder(
                            controller: _pageController,
                            onPageChanged: (value) => setState(() => _currentPage = value),
                            itemCount: _onboardingData.length,
                            itemBuilder: (context, index) => _buildPageContent(
                              title: _t(_onboardingData[index]["title_en"]!, _onboardingData[index]["title_id"]!),
                              subtitle: _t(_onboardingData[index]["subtitle_en"]!, _onboardingData[index]["subtitle_id"]!),
                              image: _onboardingData[index]["image"]!,
                              textColor: textColor,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    _onboardingData.length,
                                    (index) => _buildDotIndicator(index),
                                  ),
                                ),
                                const Spacer(),
                                _currentPage == _onboardingData.length - 1
                                    ? _buildGetStartedButton()
                                    : _buildNavigationButtons(),
                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Theme and Language Toggle (Same as AuthScreen)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                final newLang = globalLanguage.value == 'en' ? 'id' : 'en';
                                globalLanguage.value = newLang;
                                final prefs = await SharedPreferences.getInstance();
                                if (prefs.getBool('is_daily_reminder_on') ?? false) {
                                  NotificationService().scheduleDailyStudyReminder(newLang);
                                }
                                await prefs.setString('app_language', newLang);
                                await prefs.setString('setting_lang', newLang);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFCC6633).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  lang.toUpperCase(),
                                  style: const TextStyle(
                                    color: Color(0xFFCC6633),
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(width: 1, height: 16, color: isDark ? Colors.white38 : Colors.black26),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () async {
                                final newDark = !globalDarkMode.value;
                                globalDarkMode.value = newDark;
                                final prefs = await SharedPreferences.getInstance();
                                await prefs.setBool('is_dark_mode', newDark);
                                await prefs.setBool('setting_dark', newDark);
                              },
                              child: Icon(
                                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                                color: isDark ? Colors.amberAccent : const Color(0xFF5D4037),
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPageContent({
    required String title,
    required String subtitle,
    required String image,
    required Color textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // New Circular Design: Outer Red Ring with White Gap
          Container(
            width: 200,
            height: 200,
            padding: const EdgeInsets.all(6), // The "white gap"
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.redAccent, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Image.asset(
                image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported_rounded, size: 100, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF8C8A87),
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDotIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? const Color(0xFFCC6633) : const Color(0xFFE8E3DA),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildGetStartedButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: _completeOnboarding,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFCC6633),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 0,
        ),
        child: Text(
          _t("GET STARTED", "MULAI SEKARANG"),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: _completeOnboarding,
          child: Text(
            _t("SKIP", "LEWATI"),
            style: const TextStyle(color: Color(0xFF8C8A87), fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCC6633),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_t("NEXT", "LANJUT"), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_rounded, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
