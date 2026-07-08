import 'package:flutter/material.dart';
import '../../config/theme.dart';
import 'dashboard_screen.dart';
import 'member_list_screen.dart';
import 'trainer_list_screen.dart';
import 'plan_list_screen.dart';
import 'payment_record_screen.dart';
import 'reports_screen.dart';
import 'equipment_list_screen.dart';
import 'attendance_screen.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _currentIndex = 0;

  final _screens = const [
    DashboardScreen(),
    MemberListScreen(),
    TrainerListScreen(),
    PlanListScreen(),
    PaymentRecordScreen(),
    EquipmentListScreen(),
    AttendanceScreen(),
    ReportsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.divider, width: 0.5)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          backgroundColor: AppTheme.surfaceDark,
          indicatorColor: AppTheme.accentTeal.withAlpha(25),
          height: 70,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined, size: 22),
              selectedIcon: Icon(Icons.dashboard_rounded, color: AppTheme.accentTeal, size: 22),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outlined, size: 22),
              selectedIcon: Icon(Icons.people_rounded, color: AppTheme.accentTeal, size: 22),
              label: 'Members',
            ),
            NavigationDestination(
              icon: Icon(Icons.sports_martial_arts_outlined, size: 22),
              selectedIcon: Icon(Icons.sports_martial_arts_rounded, color: AppTheme.accentTeal, size: 22),
              label: 'Trainers',
            ),
            NavigationDestination(
              icon: Icon(Icons.card_membership_outlined, size: 22),
              selectedIcon: Icon(Icons.card_membership_rounded, color: AppTheme.accentTeal, size: 22),
              label: 'Plans',
            ),
            NavigationDestination(
              icon: Icon(Icons.payments_outlined, size: 22),
              selectedIcon: Icon(Icons.payments_rounded, color: AppTheme.accentTeal, size: 22),
              label: 'Payments',
            ),
            NavigationDestination(
              icon: Icon(Icons.fitness_center_outlined, size: 22),
              selectedIcon: Icon(Icons.fitness_center_rounded, color: AppTheme.accentTeal, size: 22),
              label: 'Equipment',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined, size: 22),
              selectedIcon: Icon(Icons.calendar_month_rounded, color: AppTheme.accentTeal, size: 22),
              label: 'Attendance',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined, size: 22),
              selectedIcon: Icon(Icons.bar_chart_rounded, color: AppTheme.accentTeal, size: 22),
              label: 'Reports',
            ),
          ],
        ),
      ),
    );
  }
}
