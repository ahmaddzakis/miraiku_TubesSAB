import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // IMPORT WAJIB UNTUK SUPABASE

import 'widgets/custom_bottom_nav.dart';
import 'widgets/top_status_bar.dart';

import 'features/learn/screen_learn.dart';
import 'features/simulation/screen_simulation.dart';
import 'features/kana/screen_kana.dart';
import 'features/profile/screen_profile.dart';
import 'features/login/screen_auth.dart';
import 'core/game_manager.dart';

// ==========================================
// 🌍 VARIABEL GLOBAL (STATE MANAGEMENT)
// ==========================================
final ValueNotifier<bool> globalDarkMode = ValueNotifier<bool>(false);
final ValueNotifier<String> globalLanguage = ValueNotifier<String>('en');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔗 INISIALISASI SUPABASE
  await Supabase.initialize(
    url: 'https://zvtxkamtmkqsbgoijroc.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp2dHhrYW10bWtxc2Jnb2lqcm9jIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkyNDQyNjYsImV4cCI6MjA5NDgyMDI2Nn0.7aABG8Tk0JBjxzmtZtaq8kwITHTtQ9dpx0CZVwCwlnY', // PASTIKAN INI DIGANTI DENGAN KEY ASLI DARI DASHBOARD YA
  );

  final prefs = await SharedPreferences.getInstance();
  globalDarkMode.value = prefs.getBool('setting_dark') ?? false;
  globalLanguage.value = prefs.getString('setting_lang') ?? 'en';
  await GameManager.init();

  runApp(const MiraikuApp());
}

class MiraikuApp extends StatelessWidget {
  const MiraikuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: globalDarkMode,
      builder: (context, isDark, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Miraiku',
          // ========================================================
          // --- PERUBAHAN FONT GLOBAL KE NUNITO DI SINI ---
          // ========================================================
          theme: ThemeData(
            fontFamily: 'Nunito', // <-- DIUBAH MENJADI NUNITO
            scaffoldBackgroundColor: const Color(0xFFF9F6F0),
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            fontFamily: 'Nunito', // <-- DIUBAH MENJADI NUNITO
            scaffoldBackgroundColor: const Color(0xFF121212),
            brightness: Brightness.dark,
          ),
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,

          // 🚪 GERBANG UTAMA: Mendeteksi Session Login secara Real-Time
          home: StreamBuilder<AuthState>(
            stream: Supabase.instance.client.auth.onAuthStateChange,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFFCC6633))));
              }

              final session = snapshot.data?.session;
              if (session != null) {
                // Jika sudah login, arahkan ke menu utama
                return const MainNavigationScreen();
              } else {
                // Jika belum login, kurung di halaman Auth
                return const AuthScreen();
              }
            },
          ),
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