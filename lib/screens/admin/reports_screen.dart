import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../config/api_config.dart';
import '../../controllers/auth_controller.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime _from = DateTime.now().subtract(const Duration(days: 30));
  DateTime _to = DateTime.now();
  Map<String, dynamic>? _revenueData;
  Map<String, dynamic>? _attendanceData;
  String? _error;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final auth = Get.find<AuthController>();
    final headers = auth.headers;

    try {
      final fromStr = _from.toIso8601String().substring(0, 10);
      final toStr = _to.toIso8601String().substring(0, 10);

      final revenueRes = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/reports/revenue?from=$fromStr&to=$toStr'),
        headers: headers,
      );

      final attendanceRes = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/reports/attendance?from=$fromStr&to=$toStr'),
        headers: headers,
      );

      if (revenueRes.statusCode == 200) {
        _revenueData = json.decode(revenueRes.body);
      } else {
        final body = json.decode(revenueRes.body);
        _error = 'Revenue (${revenueRes.statusCode}): ${body['message'] ?? 'Unknown error'}';
      }

      if (attendanceRes.statusCode == 200) {
        _attendanceData = json.decode(attendanceRes.body);
      } else {
        final body = json.decode(attendanceRes.body);
        _error = '${_error ?? ''}\nAttendance (${attendanceRes.statusCode}): ${body['message'] ?? 'Unknown error'}';
      }
    } catch (e) {
      _error = 'Connection error: $e';
    }

    setState(() => _isLoading = false);
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _from, end: _to),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(primary: AppTheme.accentTeal),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _from = picked.start;
        _to = picked.end;
      });
      _loadReports();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range_rounded),
            onPressed: _selectDateRange,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.accentTeal))
          : RefreshIndicator(
              onRefresh: _loadReports,
              color: AppTheme.accentTeal,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.accentTeal.withAlpha(10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 16, color: AppTheme.accentTeal),
                        const SizedBox(width: 8),
                        Text(
                          '${DateFormat('MMM d').format(_from)} - ${DateFormat('MMM d, yyyy').format(_to)}',
                          style: const TextStyle(color: AppTheme.accentTeal, fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.error.withAlpha(15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.error.withAlpha(40), width: 0.5),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, color: AppTheme.error, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(_error!, style: const TextStyle(color: AppTheme.error, fontSize: 13)),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  if (_revenueData != null) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: AppTheme.glassCard,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [AppTheme.accentYellow.withAlpha(20), AppTheme.accentYellow.withAlpha(5)],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.attach_money_rounded, color: AppTheme.accentYellow, size: 20),
                              ),
                              const SizedBox(width: 12),
                              const Text('Revenue', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${double.parse((_revenueData!['total_revenue'] ?? 0).toString()).toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppTheme.accentYellow),
                              ),
                              const SizedBox(width: 6),
                              const Padding(
                                padding: EdgeInsets.only(bottom: 4),
                                child: Text('total', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                              ),
                            ],
                          ),
                          if (_revenueData!['daily_revenue'] != null && (_revenueData!['daily_revenue'] as List).isNotEmpty) ...[
                            const SizedBox(height: 18),
                            const Text('Daily Breakdown', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            const SizedBox(height: 10),
                            ...(_revenueData!['daily_revenue'] as List).map((d) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(DateFormat('MMM d').format(DateTime.parse(d['payment_date'])), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                                  Text('\$${double.parse(d['total'].toString()).toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                ],
                              ),
                            )),
                          ] else
                            const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text('No revenue data', style: TextStyle(color: AppTheme.textSecondary)),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  if (_attendanceData != null) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: AppTheme.glassCard,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [AppTheme.accentTeal.withAlpha(20), AppTheme.accentTeal.withAlpha(5)],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.people_rounded, color: AppTheme.accentTeal, size: 20),
                              ),
                              const SizedBox(width: 12),
                              const Text('Attendance', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${_attendanceData!['unique_members'] ?? 0}',
                                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppTheme.accentTeal),
                              ),
                              const SizedBox(width: 6),
                              const Padding(
                                padding: EdgeInsets.only(bottom: 4),
                                child: Text('unique members', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                              ),
                            ],
                          ),
                          if (_attendanceData!['daily_attendance'] != null && (_attendanceData!['daily_attendance'] as List).isNotEmpty) ...[
                            const SizedBox(height: 18),
                            const Text('Daily Check-ins', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            const SizedBox(height: 10),
                            ...(_attendanceData!['daily_attendance'] as List).map((d) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(DateFormat('MMM d').format(DateTime.parse(d['date'])), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                                  Text('${d['check_ins']}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                ],
                              ),
                            )),
                          ] else
                            const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text('No attendance data', style: TextStyle(color: AppTheme.textSecondary)),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
