import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:timezone/data/latest_all.dart' as tz;

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
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Lock orientation to Portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Timezones early
  tz.initializeTimeZones();

  try {
    // 📦 LOAD PERSISTENT SETTINGS
    final prefs = await SharedPreferences.getInstance();
    globalDarkMode.value = prefs.getBool('is_dark_mode') ?? false;
    globalLanguage.value = prefs.getString('app_language') ?? 'en';

    // 🔗 INISIALISASI SUPABASE
    await Supabase.initialize(
      url: 'https://zvtxkamtmkqsbgoijroc.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp2dHhrYW10bWtxc2Jnb2lqcm9jIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkyNDQyNjYsImV4cCI6MjA5NDgyMDI2Nn0.7aABG8Tk0JBjxzmtZtaq8kwITHTtQ9dpx0CZVwCwlnY',
    );

    await GameManager.init();
    
    final notificationService = NotificationService();
    await notificationService.init();
    await notificationService.requestPermissions(); // Request early for Android 13+ support

    final isReminderOn = prefs.getBool('is_daily_reminder_on') ?? false;
    if (isReminderOn) {
      await notificationService.scheduleDailyStudyReminder(globalLanguage.value);
    }
  } catch (e) {
    debugPrint("Startup Error: $e");
  } finally {
    FlutterNativeSplash.remove();
  }

  runApp(const MIRAIkuApp());
}

class MIRAIkuApp extends StatelessWidget {
  const MIRAIkuApp({super.key});

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
              title: 'MIRAIku',
              theme: ThemeData(
                useMaterial3: true,
                fontFamily: 'Nunito',
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFFCC6633),
                  primary: const Color(0xFFCC6633),
                  surface: const Color(0xFFF9F6F0),
                ),
                pageTransitionsTheme: const PageTransitionsTheme(
                  builders: {
                    TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                  },
                ),
                scaffoldBackgroundColor: const Color(0xFFF9F6F0),
                appBarTheme: const AppBarTheme(
                  backgroundColor: Color(0xFFF9F6F0),
                  elevation: 0,
                  centerTitle: true,
                  titleTextStyle: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF333333),
                  ),
                ),
                dialogTheme: DialogThemeData(
                  backgroundColor: const Color(0xFFFAF7F2),
                  surfaceTintColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                ),
                brightness: Brightness.light,
              ),
              darkTheme: ThemeData(
                useMaterial3: true,
                fontFamily: 'Nunito',
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFFCC6633),
                  primary: const Color(0xFFCC6633),
                  surface: const Color(0xFF121212),
                  brightness: Brightness.dark,
                ),
                pageTransitionsTheme: const PageTransitionsTheme(
                  builders: {
                    TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                  },
                ),
                scaffoldBackgroundColor: const Color(0xFF121212),
                appBarTheme: const AppBarTheme(
                  backgroundColor: Color(0xFF121212),
                  elevation: 0,
                  centerTitle: true,
                  titleTextStyle: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                dialogTheme: DialogThemeData(
                  backgroundColor: const Color(0xFF1E1E1E),
                  surfaceTintColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                ),
                brightness: Brightness.dark,
              ),
              themeMode: isDark ? ThemeMode.dark : ThemeMode.light,

              home: StreamBuilder<AuthState>(
                stream: Supabase.instance.client.auth.onAuthStateChange,
                builder: (context, snapshot) {
                  // Handle loading state
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(
                        child: CircularProgressIndicator(color: Color(0xFFCC6633)),
                      ),
                    );
                  }

                  // Auth session check
                  final session = snapshot.data?.session;
                  
                  if (session != null) {
                    return const MainNavigationScreen();
                  }
                  
                  // Default fallback for null session or during sign-out transition
                  return const WelcomeScreen();
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
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _initScreens();
  }

  void _initScreens() {
    _screens = [
      LearnScreen(
        isUnit1Completed: _isUnit1Completed,
        onUnit1Completed: _handleUnit1Completed,
      ),
      const SimulationScreen(),
      const KanaScreen(),
      const ProfileScreen(),
    ];
  }

  void _handleUnit1Completed() {
    setState(() {
      _isUnit1Completed = true;
      // Re-initialize LearnScreen with the new completion status
      _screens[0] = LearnScreen(
        isUnit1Completed: _isUnit1Completed,
        onUnit1Completed: _handleUnit1Completed,
      );
    });
  }

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
              child: IndexedStack(
                index: _selectedIndex,
                children: _screens,
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
