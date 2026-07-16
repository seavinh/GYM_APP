import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/theme.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/attendance_controller.dart';
import '../../controllers/payment_controller.dart';
import '../../controllers/member_controller.dart';

class MemberShell extends StatefulWidget {
  const MemberShell({super.key});

  @override
  State<MemberShell> createState() => _MemberShellState();
}

class _MemberShellState extends State<MemberShell> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  void _loadData() {
    final auth = Get.find<AuthController>();
    final memberId = auth.memberId;
    if (memberId == null) return;

    Get.find<AttendanceController>().loadAttendance(auth, memberId: memberId);
    Get.find<PaymentController>().loadPayments(auth, memberId: memberId);
    Get.find<MemberController>().loadMembers(auth, refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildHome(),
      _buildAttendance(),
      _buildPayments(),
      _buildProfile(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
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
              icon: Icon(Icons.home_outlined, size: 22),
              selectedIcon: Icon(Icons.home_rounded, color: AppTheme.accentTeal, size: 22),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.how_to_reg_outlined, size: 22),
              selectedIcon: Icon(Icons.how_to_reg_rounded, color: AppTheme.accentTeal, size: 22),
              label: 'Attendance',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined, size: 22),
              selectedIcon: Icon(Icons.receipt_long_rounded, color: AppTheme.accentTeal, size: 22),
              label: 'Payments',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded, size: 22),
              selectedIcon: Icon(Icons.person_rounded, color: AppTheme.accentTeal, size: 22),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHome() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Gym'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () => Get.find<AuthController>().logout(),
          ),
        ],
      ),
      body: GetBuilder<AuthController>(
        builder: (auth) {
          return GetBuilder<AttendanceController>(
            builder: (attendance) {
              final myRecords = attendance.records;
              final isCheckedIn = myRecords.any((r) => r.checkOut == null);
              final totalCheckIns = myRecords.length;

              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: AppTheme.glassCard,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: AppTheme.accentTeal.withAlpha(15),
                          child: Text(
                            (auth.memberName ?? 'U').substring(0, 1).toUpperCase(),
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppTheme.accentTeal),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(auth.memberName ?? 'Member', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text(auth.user?.username ?? '', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickStat(
                          icon: Icons.login_rounded,
                          label: 'My Check-ins',
                          value: '$totalCheckIns',
                          color: AppTheme.accentTeal,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _QuickStat(
                          icon: Icons.circle,
                          label: isCheckedIn ? 'Checked In' : 'Not Checked In',
                          value: isCheckedIn ? 'YES' : 'NO',
                          color: isCheckedIn ? AppTheme.success : AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionCard(
                          icon: Icons.login_rounded,
                          label: isCheckedIn ? 'Already In' : 'Check In',
                          color: isCheckedIn ? AppTheme.textMuted : AppTheme.success,
                          onTap: isCheckedIn ? null : () => _checkIn(),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _ActionCard(
                          icon: Icons.logout_rounded,
                          label: isCheckedIn ? 'Check Out' : 'Not In Gym',
                          color: isCheckedIn ? AppTheme.accentPink : AppTheme.textMuted,
                          onTap: isCheckedIn ? () => _checkOut() : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _ActionCard(
                    icon: Icons.card_membership_rounded,
                    label: 'My Membership Status',
                    color: AppTheme.accentYellow,
                    onTap: () => _showMembershipStatus(),
                    wide: true,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAttendance() {
    return Scaffold(
      appBar: AppBar(title: const Text('My Attendance')),
      body: GetBuilder<AttendanceController>(
        builder: (provider) {
          if (provider.isLoading && provider.records.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.accentTeal));
          }
          if (provider.records.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.textMuted.withAlpha(15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.event_busy_outlined, size: 48, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 16),
                  const Text('No attendance records', style: TextStyle(color: AppTheme.textSecondary, fontSize: 15)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: provider.records.length,
            itemBuilder: (context, index) {
              final record = provider.records[index];
              final isActive = record.checkOut == null;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: AppTheme.glassCard,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(14),
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundColor: isActive ? AppTheme.success.withAlpha(15) : AppTheme.textMuted.withAlpha(15),
                    child: Icon(
                      isActive ? Icons.check_circle_rounded : Icons.logout_rounded,
                      color: isActive ? AppTheme.success : AppTheme.textMuted,
                      size: 18,
                    ),
                  ),
                  title: Text(
                    '${record.checkIn.day}/${record.checkIn.month}/${record.checkIn.year}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'In: ${_formatTime(record.checkIn)}${record.checkOut != null ? ' → Out: ${_formatTime(record.checkOut!)}' : ' (Active)'}',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPayments() {
    return Scaffold(
      appBar: AppBar(title: const Text('My Payments')),
      body: GetBuilder<PaymentController>(
        builder: (provider) {
          if (provider.isLoading && provider.payments.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.accentTeal));
          }
          if (provider.payments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.textMuted.withAlpha(15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.receipt_long_outlined, size: 48, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 16),
                  const Text('No payment records', style: TextStyle(color: AppTheme.textSecondary, fontSize: 15)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: provider.payments.length,
            itemBuilder: (context, index) {
              final payment = provider.payments[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: AppTheme.glassCard,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(14),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.accentYellow.withAlpha(15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.payment_rounded, color: AppTheme.accentYellow, size: 20),
                  ),
                  title: Text(
                    payment.membership?.membershipName ?? 'Plan #${payment.membershipId}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${payment.paymentDate.day}/${payment.paymentDate.month}/${payment.paymentDate.year}',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                  trailing: Text(
                    '\$${payment.amount.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.accentYellow, fontSize: 16),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProfile() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () => Get.find<AuthController>().logout(),
          ),
        ],
      ),
      body: GetBuilder<AuthController>(
        builder: (auth) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: AppTheme.glassCard,
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppTheme.accentTeal.withAlpha(15),
                      child: Text(
                        (auth.memberName ?? 'U').substring(0, 1).toUpperCase(),
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: AppTheme.accentTeal),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(auth.memberName ?? 'Member', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.accentTeal.withAlpha(15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        auth.user?.role.toUpperCase() ?? 'MEMBER',
                        style: const TextStyle(color: AppTheme.accentTeal, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.glassCard,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Account Details', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 16),
                    _DetailRow(label: 'Member ID', value: '${auth.memberId ?? "N/A"}'),
                    const Divider(color: AppTheme.divider),
                    _DetailRow(label: 'Username', value: auth.user?.username ?? 'N/A'),
                    const Divider(color: AppTheme.divider),
                    _DetailRow(label: 'Role', value: auth.user?.role ?? 'N/A'),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _checkIn() async {
    final auth = Get.find<AuthController>();
    final memberId = auth.memberId;
    if (memberId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No member ID found'), backgroundColor: AppTheme.error),
        );
      }
      return;
    }
    final error = await Get.find<AttendanceController>().checkIn(auth, memberId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Check-in successful'),
          backgroundColor: error != null ? AppTheme.error : AppTheme.success,
        ),
      );
    }
  }

  Future<void> _checkOut() async {
    final auth = Get.find<AuthController>();
    final memberId = auth.memberId;
    if (memberId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No member ID found'), backgroundColor: AppTheme.error),
        );
      }
      return;
    }
    final error = await Get.find<AttendanceController>().checkOut(auth, memberId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Check-out successful'),
          backgroundColor: error != null ? AppTheme.error : AppTheme.success,
        ),
      );
    }
  }

  void _showMembershipStatus() {
    final payments = Get.find<PaymentController>().payments;

    if (payments.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Membership Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.accentYellow.withAlpha(15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.info_outline, color: AppTheme.accentYellow, size: 40),
              ),
              const SizedBox(height: 16),
              const Text('No active membership', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              const Text('Please visit reception to sign up for a plan.', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textSecondary)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          ],
        ),
      );
      return;
    }

    final latest = payments.first;
    final planName = latest.membership?.membershipName ?? 'Unknown';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Membership Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.success.withAlpha(15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.card_membership_rounded, color: AppTheme.success, size: 40),
            ),
            const SizedBox(height: 16),
            _DetailRow(label: 'Plan', value: planName),
            const SizedBox(height: 8),
            _DetailRow(label: 'Amount', value: '\$${latest.amount.toStringAsFixed(0)}'),
            const SizedBox(height: 8),
            _DetailRow(label: 'Last Payment', value: '${latest.paymentDate.day}/${latest.paymentDate.month}/${latest.paymentDate.year}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _QuickStat({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final bool wide;

  const _ActionCard({required this.icon, required this.label, required this.color, this.onTap, this.wide = false});

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onTap == null;
    final Color effectiveColor = isDisabled ? AppTheme.textMuted : color;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(wide ? 20 : 18),
        decoration: BoxDecoration(
          color: isDisabled
              ? AppTheme.surfaceDark.withAlpha(100)
              : AppTheme.cardDark.withAlpha(200),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDisabled ? AppTheme.divider.withAlpha(80) : AppTheme.divider,
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: wide ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: effectiveColor.withAlpha(isDisabled ? 10 : 15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: effectiveColor, size: 22),
            ),
            if (wide) const SizedBox(width: 14),
            if (wide) Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: isDisabled ? AppTheme.textMuted : AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }
}
