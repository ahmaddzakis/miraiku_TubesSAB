import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // IMPORT WAJIB UNTUK SUPABASE
import 'package:shared_preferences/shared_preferences.dart';

import 'widgets/custom_bottom_nav.dart';
import 'widgets/top_status_bar.dart';

import 'features/learn/screen_learn.dart';
import 'features/simulation/screen_simulation.dart';
import 'features/kana/screen_kana.dart';
import 'features/profile/screen_profile.dart';
import 'features/login/screen_welcome.dart';
import 'core/game_manager.dart';
import 'core/notification_service.dart';

// ==========================================
// 🌍 GLOBAL NAVIGATOR KEY
// ==========================================
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 📦 LOAD PERSISTENT SETTINGS
  final prefs = await SharedPreferences.getInstance();
  globalDarkMode.value = prefs.getBool('is_dark_mode') ?? false;
  globalLanguage.value = prefs.getString('app_language') ?? 'en';

  // 🔗 INISIALISASI SUPABASE
  await Supabase.initialize(
    url: 'https://zvtxkamtmkqsbgoijroc.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp2dHhrYW10bWtxc2Jnb2lqcm9jIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkyNDQyNjYsImV4cCI6MjA5NDgyMDI2Nn0.7aABG8Tk0JBjxzmtZtaq8kwITHTtQ9dpx0CZVwCwlnY', // PASTIKAN INI DIGANTI DENGAN KEY ASLI DARI DASHBOARD YA
  );

  await GameManager.init();
  
  final notificationService = NotificationService();
  await notificationService.init();
  // Don't request permissions or schedule here on every boot, 
  // do it only when the user enables it in Settings/Notifications
  // to avoid annoying the user on first launch unless it's a returning user with preference ON.
  final isReminderOn = prefs.getBool('is_daily_reminder_on') ?? false;
  if (isReminderOn) {
    await notificationService.requestPermissions();
    await notificationService.scheduleDailyStudyReminder(globalLanguage.value);
  }

  runApp(const MiraikuApp());
}

class MiraikuApp extends StatelessWidget {
  const MiraikuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: globalDarkMode,
      builder: (context, isDark, _) {
        return ValueListenableBuilder<String>(
          valueListenable: globalLanguage,
          builder: (context, language, _) {
            return MaterialApp(
              navigatorKey: navigatorKey,
              debugShowCheckedModeBanner: false,
              title: 'Miraiku',
              theme: ThemeData(
                fontFamily: 'Nunito',
                scaffoldBackgroundColor: const Color(0xFFF9F6F0),
                brightness: Brightness.light,
              ),
              darkTheme: ThemeData(
                fontFamily: 'Nunito',
                scaffoldBackgroundColor: const Color(0xFF121212),
                brightness: Brightness.dark,
              ),
              themeMode: isDark ? ThemeMode.dark : ThemeMode.light,

              home: StreamBuilder<AuthState>(
                stream: Supabase.instance.client.auth.onAuthStateChange,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFFCC6633))));
                  }

                  final session = snapshot.data?.session;
                  if (session != null) {
                    return const MainNavigationScreen();
                  } else {
                    return const WelcomeScreen();
                  }
                },
              ),
            );
          },
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
                duration: const Duration(milliseconds: 400),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
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
