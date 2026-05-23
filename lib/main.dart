import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Tambahan untuk memuat memori
import 'widgets/custom_bottom_nav.dart';
import 'widgets/top_status_bar.dart';

import 'features/learn/screen_learn.dart';
import 'features/simulation/screen_simulation.dart';
import 'features/kana/screen_kana.dart';
import 'features/profile/screen_profile.dart';

// ==========================================
// 🌍 VARIABEL GLOBAL (STATE MANAGEMENT)
// ==========================================
final ValueNotifier<bool> globalDarkMode = ValueNotifier<bool>(false);
final ValueNotifier<String> globalLanguage = ValueNotifier<String>('en');

void main() async {
  // Wajib ditambahkan karena kita mengakses SharedPreferences sebelum runApp berjalan
  WidgetsFlutterBinding.ensureInitialized();

  // Memuat pengaturan terakhir dari HP user saat aplikasi baru dibuka
  final prefs = await SharedPreferences.getInstance();
  globalDarkMode.value = prefs.getBool('setting_dark') ?? false;
  globalLanguage.value = prefs.getString('setting_lang') ?? 'en';

  runApp(const MiraikuApp());
}

class MiraikuApp extends StatelessWidget {
  const MiraikuApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Membungkus MaterialApp agar bereaksi setiap kali globalDarkMode berubah
    return ValueListenableBuilder<bool>(
      valueListenable: globalDarkMode,
      builder: (context, isDark, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Miraiku',

          // Konfigurasi Tema Terang
          theme: ThemeData(
            fontFamily: 'Serif',
            scaffoldBackgroundColor: const Color(0xFFF9F6F0),
            brightness: Brightness.light,
          ),

          // Konfigurasi Tema Gelap
          darkTheme: ThemeData(
            fontFamily: 'Serif',
            scaffoldBackgroundColor: const Color(0xFF121212),
            brightness: Brightness.dark,
          ),

          // Mengubah tema sesuai nilai switch di Settings
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,

          home: const MainNavigationScreen(),
        );
      },
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  bool _isUnit1Completed = false;

  void _handleUnit1Completed() {
    setState(() {
      _isUnit1Completed = true;
    });
  }

  List<Widget> get _screens => [
    LearnScreen(
      isUnit1Completed: _isUnit1Completed,
      onUnit1Completed: _handleUnit1Completed,
    ),
    const SimulationScreen(),
    const KanaScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Warna background scaffold otomatis mengikuti ThemeMode sekarang!
      body: SafeArea(
        child: Column(
          children: [
            const TopStatusBar(),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, 0.05),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey<int>(_selectedIndex),
                  child: _screens[_selectedIndex],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}