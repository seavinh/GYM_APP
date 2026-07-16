import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/theme.dart';
import '../../controllers/auth_controller.dart';
import 'dashboard_screen.dart';
import 'member_list_screen.dart';
import 'trainer_list_screen.dart';
import 'plan_list_screen.dart';
import 'payment_record_screen.dart';
import 'equipment_list_screen.dart';
import 'attendance_screen.dart';
import 'reports_screen.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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

  static const List<_NavItem> _navItems = [
    _NavItem(label: 'Dashboard', icon: Icons.dashboard_outlined, selectedIcon: Icons.dashboard_rounded),
    _NavItem(label: 'Members', icon: Icons.people_outlined, selectedIcon: Icons.people_rounded),
    _NavItem(label: 'Trainers', icon: Icons.sports_martial_arts_outlined, selectedIcon: Icons.sports_martial_arts_rounded),
    _NavItem(label: 'Plans', icon: Icons.card_membership_outlined, selectedIcon: Icons.card_membership_rounded),
    _NavItem(label: 'Payments', icon: Icons.payments_outlined, selectedIcon: Icons.payments_rounded),
    _NavItem(label: 'Equipment', icon: Icons.fitness_center_outlined, selectedIcon: Icons.fitness_center_rounded),
    _NavItem(label: 'Attendance', icon: Icons.calendar_month_outlined, selectedIcon: Icons.calendar_month_rounded),
    _NavItem(label: 'Reports', icon: Icons.bar_chart_outlined, selectedIcon: Icons.bar_chart_rounded),
  ];

  int get _bottomBarSelectedIndex {
    if (_currentIndex == 0) return 0;
    if (_currentIndex == 1) return 1;
    if (_currentIndex == 4) return 2; // Payments
    if (_currentIndex == 5) return 3; // Equipment
    return 4; // Everything else (Trainers, Plans, Attendance, Reports) falls under "More"
  }

  void _onBottomBarSelected(int index) {
    if (index == 0) {
      setState(() => _currentIndex = 0);
    } else if (index == 1) {
      setState(() => _currentIndex = 1);
    } else if (index == 2) {
      setState(() => _currentIndex = 4); // Payments
    } else if (index == 3) {
      setState(() => _currentIndex = 5); // Equipment
    } else if (index == 4) {
      _scaffoldKey.currentState?.openDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth >= 900;

        if (isWide) {
          return Scaffold(
            body: Row(
              children: [
                _buildSidebar(context),
                const VerticalDivider(width: 1, color: AppTheme.divider),
                Expanded(
                  child: ClipRect(
                    child: _screens[_currentIndex],
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          key: _scaffoldKey,
          body: _screens[_currentIndex],
          drawer: _buildDrawer(context),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppTheme.divider, width: 0.5)),
            ),
            child: NavigationBar(
              selectedIndex: _bottomBarSelectedIndex,
              onDestinationSelected: _onBottomBarSelected,
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
                  icon: Icon(Icons.menu_rounded, size: 22),
                  selectedIcon: Icon(Icons.menu_rounded, color: AppTheme.accentTeal, size: 22),
                  label: 'More',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 260,
      color: AppTheme.surfaceDark,
      child: Column(
        children: [
          // Sidebar Header (Logo and User Profile)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.accentTeal.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.accentTeal.withAlpha(30)),
                      ),
                      child: const Icon(Icons.bolt_rounded, color: AppTheme.accentTeal, size: 24),
                    ),
                    const SizedBox(width: 14),
                    const Text(
                      'GYM ADMIN',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Admin User Card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.cardDark.withAlpha(150),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.divider, width: 0.5),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppTheme.accentTeal.withAlpha(20),
                        child: const Text('A', style: TextStyle(color: AppTheme.accentTeal, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Admin User',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Administrator',
                              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.divider),
          const SizedBox(height: 12),
          // Sidebar Nav Items List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: _navItems.length,
              itemBuilder: (context, index) {
                final item = _navItems[index];
                final bool isSelected = _currentIndex == index;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => setState(() => _currentIndex = index),
                      borderRadius: BorderRadius.circular(12),
                      hoverColor: AppTheme.divider.withAlpha(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.accentTeal.withAlpha(20) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(color: AppTheme.accentTeal.withAlpha(40), width: 0.5)
                              : null,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? item.selectedIcon : item.icon,
                              color: isSelected ? AppTheme.accentTeal : AppTheme.textSecondary,
                              size: 20,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              item.label,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Sidebar Footer (Log out)
          const Divider(height: 1, color: AppTheme.divider),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Get.find<AuthController>().logout(),
                borderRadius: BorderRadius.circular(12),
                hoverColor: AppTheme.error.withAlpha(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: const Row(
                    children: [
                      Icon(Icons.logout_rounded, color: AppTheme.error, size: 20),
                      const SizedBox(width: 16),
                      Text(
                        'Log Out',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.error),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.surfaceDark,
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.accentTeal.withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.bolt_rounded, color: AppTheme.accentTeal, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'GYM FEATURES',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.5),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppTheme.divider),
            const SizedBox(height: 12),
            // Navigation items list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                itemCount: _navItems.length,
                itemBuilder: (context, index) {
                  final item = _navItems[index];
                  final bool isSelected = _currentIndex == index;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context); // Close Drawer
                          setState(() => _currentIndex = index);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.accentTeal.withAlpha(20) : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected ? item.selectedIcon : item.icon,
                                color: isSelected ? AppTheme.accentTeal : AppTheme.textSecondary,
                                size: 20,
                              ),
                              const SizedBox(width: 16),
                              Text(
                                item.label,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1, color: AppTheme.divider),
            // Drawer Footer (Logout)
            Padding(
              padding: const EdgeInsets.all(16),
              child: ListTile(
                onTap: () {
                  Navigator.pop(context);
                  Get.find<AuthController>().logout();
                },
                leading: const Icon(Icons.logout_rounded, color: AppTheme.error, size: 20),
                title: const Text(
                  'Log Out',
                  style: TextStyle(color: AppTheme.error, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  const _NavItem({required this.label, required this.icon, required this.selectedIcon});
}
