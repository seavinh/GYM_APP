import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/member_provider.dart';
import '../../providers/attendance_provider.dart';

class ReceptionistShell extends StatefulWidget {
  const ReceptionistShell({super.key});

  @override
  State<ReceptionistShell> createState() => _ReceptionistShellState();
}

class _ReceptionistShellState extends State<ReceptionistShell> {
  int _currentIndex = 0;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      context.read<MemberProvider>().loadMembers(auth, refresh: true);
      context.read<AttendanceProvider>().loadTodayReport(auth);
      context.read<AttendanceProvider>().loadActiveAttendance(auth);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value, AuthProvider auth) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      context.read<MemberProvider>().loadMembers(auth, search: value.isEmpty ? null : value, refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receptionist'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              final auth = context.read<AuthProvider>();
              context.read<MemberProvider>().loadMembers(auth, refresh: true);
              context.read<AttendanceProvider>().loadTodayReport(auth);
              context.read<AttendanceProvider>().loadActiveAttendance(auth);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: _currentIndex == 0 ? _buildQuickActions() : _buildCheckInCheckOut(),
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
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.speed_outlined, size: 22),
              selectedIcon: Icon(Icons.speed_rounded, color: AppTheme.accentTeal, size: 22),
              label: 'Quick Actions',
            ),
            NavigationDestination(
              icon: Icon(Icons.how_to_reg_outlined, size: 22),
              selectedIcon: Icon(Icons.how_to_reg_rounded, color: AppTheme.accentTeal, size: 22),
              label: 'Check In/Out',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Consumer<AttendanceProvider>(
      builder: (context, attendance, _) {
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                _QuickStat(label: 'Check-ins Today', value: '${attendance.todayCheckIns}', color: AppTheme.accentTeal),
                const SizedBox(width: 14),
                _QuickStat(label: 'Active Now', value: '${attendance.activeNow}', color: AppTheme.success),
              ],
            ),
            const SizedBox(height: 28),
            const Text('Quick Actions', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    icon: Icons.person_add_outlined,
                    label: 'Register\nMember',
                    color: AppTheme.accentTeal,
                    onTap: () => _showRegisterDialog(),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _ActionCard(
                    icon: Icons.login_rounded,
                    label: 'Quick\nCheck-in',
                    color: AppTheme.accentYellow,
                    onTap: () => _showCheckInDialog(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    icon: Icons.logout_rounded,
                    label: 'Quick\nCheck-out',
                    color: AppTheme.accentPink,
                    onTap: () => _showCheckOutDialog(),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _ActionCard(
                    icon: Icons.search_rounded,
                    label: 'Search\nMembers',
                    color: AppTheme.accentPurple,
                    onTap: () => _showSearchDialog(),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildCheckInCheckOut() {
    return Consumer2<MemberProvider, AttendanceProvider>(
      builder: (context, memberProvider, attendanceProvider, _) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search member by name...',
                  prefixIcon: Icon(Icons.search_rounded, size: 20),
                ),
                onChanged: (v) => _onSearchChanged(v, context.read<AuthProvider>()),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                itemCount: memberProvider.members.length,
                itemBuilder: (context, index) {
                  final member = memberProvider.members[index];
                  final isActive = attendanceProvider.activeMemberIds.contains(member.memberId);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: AppTheme.glassCard,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(14),
                      leading: CircleAvatar(
                        radius: 22,
                        backgroundColor: isActive ? AppTheme.success.withAlpha(15) : AppTheme.accentTeal.withAlpha(15),
                        child: Text(
                          member.fullName.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            color: isActive ? AppTheme.success : AppTheme.accentTeal,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(member.fullName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                          ),
                          if (isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.success.withAlpha(15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('ACTIVE', style: TextStyle(color: AppTheme.success, fontSize: 10, fontWeight: FontWeight.w700)),
                            ),
                        ],
                      ),
                      subtitle: Text(member.email, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.login_rounded, color: AppTheme.success, size: 22),
                            onPressed: isActive ? null : () async {
                              final error = await attendanceProvider.checkIn(context.read<AuthProvider>(), member.memberId);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(error ?? 'Check-in successful'),
                                    backgroundColor: error != null ? AppTheme.error : AppTheme.success,
                                  ),
                                );
                                if (error == null) {
                                  attendanceProvider.loadActiveAttendance(context.read<AuthProvider>());
                                }
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.logout_rounded, color: isActive ? AppTheme.accentPink : AppTheme.textMuted, size: 22),
                            onPressed: isActive ? () async {
                              final error = await attendanceProvider.checkOut(context.read<AuthProvider>(), member.memberId);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(error ?? 'Check-out successful'),
                                    backgroundColor: error != null ? AppTheme.error : AppTheme.success,
                                  ),
                                );
                                if (error == null) {
                                  attendanceProvider.loadActiveAttendance(context.read<AuthProvider>());
                                }
                              }
                            } : null,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showRegisterDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.person_add_rounded, color: AppTheme.accentTeal, size: 22),
            const SizedBox(width: 8),
            const Text('Quick Register'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline_rounded))),
            const SizedBox(height: 10),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone', prefixIcon: Icon(Icons.phone_outlined))),
            const SizedBox(height: 10),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty && emailController.text.isNotEmpty) {
                await context.read<MemberProvider>().createMember(
                  context.read<AuthProvider>(),
                  {
                    'full_name': nameController.text.trim(),
                    'phone': phoneController.text.trim(),
                    'email': emailController.text.trim(),
                    'gender': 'male',
                    'dob': '2000-01-01',
                    'join_date': DateTime.now().toIso8601String().substring(0, 10),
                  },
                );
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Register'),
          ),
        ],
      ),
    );
  }

  void _showCheckInDialog() async {
    final members = context.read<MemberProvider>().members;
    if (members.isEmpty) return;

    final selected = await showDialog<int>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Select Member'),
        children: members.map((m) => SimpleDialogOption(
          onPressed: () => Navigator.pop(ctx, m.memberId),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.accentTeal.withAlpha(15),
                child: Text(m.fullName.substring(0, 1).toUpperCase(), style: const TextStyle(color: AppTheme.accentTeal, fontWeight: FontWeight.w700, fontSize: 13)),
              ),
              const SizedBox(width: 10),
              Text(m.fullName),
            ],
          ),
        )).toList(),
      ),
    );

    if (selected != null && mounted) {
      final auth = context.read<AuthProvider>();
      final attendanceProvider = context.read<AttendanceProvider>();
      final error = await attendanceProvider.checkIn(auth, selected);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error ?? 'Check-in successful'), backgroundColor: error != null ? AppTheme.error : AppTheme.success),
        );
        if (error == null) {
          attendanceProvider.loadActiveAttendance(auth);
        }
      }
    }
  }

  void _showCheckOutDialog() async {
    final attendanceProvider = context.read<AttendanceProvider>();
    final auth = context.read<AuthProvider>();
    await attendanceProvider.loadActiveAttendance(auth);

    final activeIds = attendanceProvider.activeMemberIds;
    if (activeIds.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No members currently checked in'), backgroundColor: AppTheme.warning),
        );
      }
      return;
    }

    final members = context.read<MemberProvider>().members.where((m) => activeIds.contains(m.memberId)).toList();
    if (members.isEmpty) return;

    final selected = await showDialog<int>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Select Member to Check Out'),
        children: members.map((m) => SimpleDialogOption(
          onPressed: () => Navigator.pop(ctx, m.memberId),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.accentPink.withAlpha(15),
                child: Text(m.fullName.substring(0, 1).toUpperCase(), style: const TextStyle(color: AppTheme.accentPink, fontWeight: FontWeight.w700, fontSize: 13)),
              ),
              const SizedBox(width: 10),
              Text(m.fullName),
            ],
          ),
        )).toList(),
      ),
    );

    if (selected != null && mounted) {
      final error = await attendanceProvider.checkOut(auth, selected);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error ?? 'Check-out successful'), backgroundColor: error != null ? AppTheme.error : AppTheme.success),
        );
        if (error == null) {
          attendanceProvider.loadActiveAttendance(auth);
        }
      }
    }
  }

  void _showSearchDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.search_rounded, color: AppTheme.accentTeal, size: 22),
            const SizedBox(width: 8),
            const Text('Search Members'),
          ],
        ),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter name or email', prefixIcon: Icon(Icons.search_rounded, size: 20)),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<MemberProvider>().loadMembers(
                context.read<AuthProvider>(),
                search: controller.text,
                refresh: true,
              );
              setState(() => _currentIndex = 1);
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _QuickStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: AppTheme.glassCard,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.bar_chart_rounded, color: color, size: 20),
            ),
            const SizedBox(height: 10),
            Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: AppTheme.glassCard,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withAlpha(20), color.withAlpha(5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 14),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, height: 1.3)),
          ],
        ),
      ),
    );
  }
}
