import 'package:flutter/material.dart';
import 'widgets/custom_bottom_nav.dart';
import 'widgets/top_status_bar.dart';

import 'features/learn/screen_learn.dart';
import 'features/simulation/screen_simulation.dart';
import 'features/kana/screen_kana.dart';
import 'features/profile/screen_profile.dart';
import 'features/login/screen_login.dart'; // Import halaman login

void main() {
  runApp(const MiraikuApp());
}

class MiraikuApp extends StatelessWidget {
  const MiraikuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Miraiku',
      theme: ThemeData(
        fontFamily: 'Serif',
        scaffoldBackgroundColor: const Color(0xFFF9F6F0),
      ),
      // Jalankan halaman login pertama kali
      home: const ScreenLogin(),
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
  bool _isUnit1Completed = false; // State global pengunci Unit

  void _handleUnit1Completed() {
    setState(() {
      _isUnit1Completed = true;
    });
  }

  // Menggunakan getter agar widget rebuild dengan state terbaru
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