import 'package:flutter/material.dart';
import '../../core/game_manager.dart';
import '../../main.dart'; // To navigate to MainScreen or Home

class LoginSuccessScreen extends StatefulWidget {
  const LoginSuccessScreen({super.key});

  @override
  State<LoginSuccessScreen> createState() => _LoginSuccessScreenState();
}

class _LoginSuccessScreenState extends State<LoginSuccessScreen> {
  @override
  void initState() {
    super.initState();
    _startNavigationTimer();
  }

  void _startNavigationTimer() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        // Navigate to the main/home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        );
      }
    });
  }

  String _t(String en, String id) {
    return globalLanguage.value == 'id' ? id : en;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: globalDarkMode,
      builder: (context, isDark, _) {
        final Color bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF9F6F0);
        final Color textColor = isDark ? Colors.white : const Color(0xFF2D2622);

        return Scaffold(
          backgroundColor: bgColor,
          body: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              builder: (context, opacity, child) {
                return Opacity(
                  opacity: opacity,
                  child: child,
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      'assets/images/iconUtama.png',
                      width: 150,
                      height: 150,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    _t("Welcome to MIRAIku", "Selamat Datang di MIRAIku"),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _t("Preparing your journey...", "Menyiapkan perjalananmu..."),
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
