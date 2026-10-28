import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';
import 'matchday_screen.dart';
import 'progress_screen.dart';
import 'reflect_screen.dart';
import 'session_builder_screen.dart';
import 'sessions_screen.dart';

/// Bottom-nav shell wiring the five main tabs together: Dashboard, Sessions,
/// Reflect, Matchday, Progress. Matches the app-wide bottom navigation in
/// the design.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  static const _tabs = [
    _TabInfo(icon: Icons.space_dashboard_rounded, label: 'Dashboard'),
    _TabInfo(icon: Icons.calendar_month_rounded, label: 'Sessions'),
    _TabInfo(icon: Icons.menu_book_rounded, label: 'Reflect'),
    _TabInfo(icon: Icons.sports_soccer_rounded, label: 'Matchday'),
    _TabInfo(icon: Icons.trending_up_rounded, label: 'Progress'),
  ];

  void _openSessionBuilder() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SessionBuilderScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const DashboardScreen(),
      const SessionsScreen(),
      const ReflectScreen(),
      const MatchdayScreen(),
      const ProgressScreen(),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: _currentIndex, children: screens),
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: _openSessionBuilder,
              child: const Icon(Icons.add_rounded),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.accentGold,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        items: _tabs
            .map((t) => BottomNavigationBarItem(icon: Icon(t.icon), label: t.label))
            .toList(),
      ),
    );
  }
}

class _TabInfo {
  final IconData icon;
  final String label;
  const _TabInfo({required this.icon, required this.label});
}
