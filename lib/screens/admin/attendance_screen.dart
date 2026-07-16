import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/theme.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/attendance_controller.dart';
import '../../controllers/member_controller.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    final auth = Get.find<AuthController>();
    Get.find<MemberController>().loadMembers(auth, refresh: true);
    Get.find<AttendanceController>().loadAttendance(auth, date: _formatDate(_selectedDate));
    Get.find<AttendanceController>().loadTodayReport(auth);
  }

  String _formatDate(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance')),
      body: Column(
        children: [
          GetBuilder<AttendanceController>(
            builder: (provider) {
              return Container(
                margin: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.glassCard,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(icon: Icons.login_rounded, label: 'Check-ins', value: '${provider.todayCheckIns}', color: AppTheme.accentTeal),
                    Container(
                      height: 40,
                      width: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.divider.withAlpha(0), AppTheme.divider, AppTheme.divider.withAlpha(0)],
                        ),
                      ),
                    ),
                    _StatItem(icon: Icons.person_rounded, label: 'Active Now', value: '${provider.activeNow}', color: AppTheme.success),
                  ],
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Records for ${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.calendar_today_rounded, size: 16),
                  label: const Text('Change Date'),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2024),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => _selectedDate = date);
                      Get.find<AttendanceController>().loadAttendance(
                        Get.find<AuthController>(),
                        date: _formatDate(date),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: GetBuilder<AttendanceController>(
              builder: (provider) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator(color: AppTheme.accentTeal));
                }

                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppTheme.error.withAlpha(15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.error_outline_rounded, size: 48, color: AppTheme.error),
                        ),
                        const SizedBox(height: 16),
                        Text(provider.error!, style: const TextStyle(color: AppTheme.error, fontSize: 14), textAlign: TextAlign.center),
                      ],
                    ),
                  );
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
                        const Text('No attendance records for this date', style: TextStyle(color: AppTheme.textSecondary, fontSize: 15)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  itemCount: provider.records.length,
                  itemBuilder: (context, index) {
                    final record = provider.records[index];
                    final memberName = record.member?.fullName ?? 'Member #${record.memberId}';
                    final isActive = record.checkOut == null;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: AppTheme.glassCard,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(14),
                        leading: CircleAvatar(
                          radius: 22,
                          backgroundColor: isActive ? AppTheme.success.withAlpha(15) : AppTheme.textMuted.withAlpha(15),
                          child: Icon(
                            isActive ? Icons.check_circle_rounded : Icons.logout_rounded,
                            color: isActive ? AppTheme.success : AppTheme.textMuted,
                            size: 20,
                          ),
                        ),
                        title: Text(memberName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'In: ${_formatTime(record.checkIn)}${record.checkOut != null ? '  →  Out: ${_formatTime(record.checkOut!)}' : '  (Active)'}',
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                          ),
                        ),
                        trailing: isActive
                            ? TextButton(
                                onPressed: () => _checkOut(record.memberId),
                                child: const Text('Check Out', style: TextStyle(color: AppTheme.accentPink, fontWeight: FontWeight.w700)),
                              )
                            : Icon(Icons.check_circle_rounded, color: AppTheme.success.withAlpha(60), size: 20),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCheckInDialog,
        child: const Icon(Icons.login_rounded, size: 26),
      ),
    );
  }

  void _showCheckInDialog() async {
    final members = Get.find<MemberController>().members;
    if (members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No members available'), backgroundColor: AppTheme.error),
      );
      return;
    }

    final selected = await showDialog<int>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Quick Check-in'),
        children: members.map((m) => SimpleDialogOption(
          onPressed: () => Navigator.pop(ctx, m.memberId),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.accentTeal.withAlpha(15),
                child: Text(m.fullName.substring(0, 1).toUpperCase(), style: const TextStyle(color: AppTheme.accentTeal, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 12),
              Text(m.fullName),
            ],
          ),
        )).toList(),
      ),
    );

    if (selected != null && mounted) {
      final auth = Get.find<AuthController>();
      final provider = Get.find<AttendanceController>();
      final error = await provider.checkIn(auth, selected);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Check-in successful'),
            backgroundColor: error != null ? AppTheme.error : AppTheme.success,
          ),
        );
        if (error == null) {
          provider.loadAttendance(auth, date: _formatDate(_selectedDate));
        }
      }
    }
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _checkOut(int memberId) async {
    final auth = Get.find<AuthController>();
    final provider = Get.find<AttendanceController>();
    final error = await provider.checkOut(auth, memberId);
    if (mounted) {
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppTheme.error),
        );
      }
      provider.loadAttendance(auth, date: _formatDate(_selectedDate));
    }
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha(15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
      ],
    );
  }
}
