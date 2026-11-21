import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tz;

import 'core/config/app_config.dart';
import 'core/game_manager.dart';
import 'core/notification_service.dart';
import 'core/repository/local_repository.dart';
import 'core/settings_controller.dart';
import 'core/theme/app_theme.dart';

import 'features/common/screen_greeting_overlay.dart';
import 'features/kana/screen_kana.dart';
import 'features/learn/screen_learn.dart';
import 'features/login/screen_welcome.dart';
import 'features/profile/screen_profile.dart';
import 'features/simulation/screen_simulation.dart';

import 'widgets/custom_bottom_nav.dart';
import 'widgets/top_status_bar.dart';

// ==========================================
// 🌍 GLOBAL NAVIGATOR KEY
// ==========================================
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  final WidgetsBinding widgetsBinding =
      WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Lock orientation to Portrait only on mobile phones (allow desktop/tablet flexibility)
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  // 1. INITIALIZE TIMEZONES
  tz.initializeTimeZones();

  try {
    // 🔗 INITIALIZE SUPABASE
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );

    // 2. INITIALIZE GLOBAL SETTINGS (Theme & Language) - FORCE AWAIT
    await SettingsController.instance.init();

    await GameManager.init();

    // 🌐 START OFFLINE SYNC LISTENER
    LocalRepository.startSyncListener();

    // 3. INITIALIZE NOTIFICATION SERVICE
    final notificationService = NotificationService();
    await notificationService.init();
    await notificationService.requestPermissions();

    final prefs = await SharedPreferences.getInstance();
    final isReminderOn = prefs.getBool('is_daily_reminder_on') ?? false;
    if (isReminderOn) {
      await notificationService.scheduleDailyStudyReminder(
        globalLanguage.value,
      );
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
    final settings = SettingsController.instance;

    return ListenableBuilder(
      listenable: Listenable.merge([
        settings.themeMode,
        settings.locale,
        globalDarkMode,
        globalLanguage,
      ]),
      builder: (context, _) {
        final ThemeMode effectiveThemeMode =
            globalDarkMode.value ? ThemeMode.dark : ThemeMode.light;
        final Locale effectiveLocale = Locale(globalLanguage.value);

        return MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'MIRAIku',

          // 🌍 Localization
          locale: effectiveLocale,
          supportedLocales: const [
            Locale('en'),
            Locale('id'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          // 🎨 Centralized Material 3 Design System
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: effectiveThemeMode,

          home: StreamBuilder<AuthState>(
            stream: Supabase.instance.client.auth.onAuthStateChange,
            builder: (context, authSnapshot) {
              if (authSnapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                );
              }

              final session =
                  authSnapshot.data?.session ??
                  Supabase.instance.client.auth.currentSession;

              if (session != null) {
                return const GreetingOverlayScreen(
                  nextScreen: MainNavigationScreen(),
                );
              }

              return const WelcomeScreen();
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
