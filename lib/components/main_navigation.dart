import 'package:cashtrack/features/account/presentation/account_screen.dart';
import 'package:cashtrack/features/dashboard/presentation/dashboard_screen.dart';
import 'package:cashtrack/features/dashboard/presentation/expenses_dashboard.dart';
import 'package:cashtrack/features/dashboard/presentation/incomes_dashboard.dart';
import 'package:flutter/material.dart';

class MainNavigation extends StatefulWidget {
  final int initialIndex;

  const MainNavigation({super.key, this.initialIndex = 0});

  @override
  State<MainNavigation> createState() => MainNavigationState();
}

class MainNavigationState extends State<MainNavigation> {
  late int _currentIndex;

  final List<Widget> _screens = const [
    DashboardScreen(),
    IncomesDashboardScreen(),
    ExpensesDashboardScreen(),
    AccountScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void switchTab(int index) => _onTabTapped(index);

  @override
  Widget build(BuildContext context) {
    const darkMainBg = Color(0xFF2A2728);
    const darkSecondaryHighlight = Color(0xFF8E6E53);
    const darkFontColor = Color(0xFFC0B7B1);

    return Scaffold(
      backgroundColor: darkMainBg,
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        backgroundColor: darkMainBg,
        selectedItemColor: darkSecondaryHighlight,
        unselectedItemColor: darkFontColor.withValues(alpha: .6),
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 13,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Entradas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_down),
            label: 'Despesas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
