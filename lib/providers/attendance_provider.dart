import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/attendance.dart';
import 'auth_provider.dart';

class AttendanceProvider extends ChangeNotifier {
  List<Attendance> _records = [];
  bool _isLoading = false;
  int _todayCheckIns = 0;
  int _activeNow = 0;
  String? _error;
  Set<int> _activeMemberIds = {};

  List<Attendance> get records => _records;
  bool get isLoading => _isLoading;
  int get todayCheckIns => _todayCheckIns;
  int get activeNow => _activeNow;
  String? get error => _error;
  Set<int> get activeMemberIds => _activeMemberIds;

  Future<void> loadAttendance(AuthProvider auth, {String? date, int? memberId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final queryParams = <String, String>{};
      if (date != null) queryParams['date'] = date;
      if (memberId != null) queryParams['member_id'] = memberId.toString();

      final uri = Uri.parse('${ApiConfig.baseUrl}/attendance').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: auth.headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _records = (data['data'] as List).map((a) => Attendance.fromJson(a)).toList();
      } else {
        _records = [];
        _error = 'Failed to load attendance (HTTP ${response.statusCode})';
      }
    } catch (e) {
      _records = [];
      _error = 'Connection error: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<String?> checkIn(AuthProvider auth, int memberId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/attendance/check-in'),
        headers: auth.headers,
        body: json.encode({'member_id': memberId}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        await loadTodayReport(auth);
        notifyListeners();
        return null;
      } else {
        return data['message'];
      }
    } catch (e) {
      return 'Connection error: $e';
    }
  }

  Future<String?> checkOut(AuthProvider auth, int memberId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/attendance/check-out'),
        headers: auth.headers,
        body: json.encode({'member_id': memberId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final updated = Attendance.fromJson(data['attendance']);
        final index = _records.indexWhere((a) => a.attendanceId == updated.attendanceId);
        if (index != -1) _records[index] = updated;
        await loadTodayReport(auth);
        notifyListeners();
        return null;
      } else {
        final data = json.decode(response.body);
        return data['message'];
      }
    } catch (e) {
      return 'Connection error: $e';
    }
  }

  Future<void> loadTodayReport(AuthProvider auth) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/attendance/today'),
        headers: auth.headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _todayCheckIns = data['total_check_ins'] ?? 0;
        _activeNow = data['active_now'] ?? 0;
        notifyListeners();
      } else {
        _error = 'Failed to load today report (HTTP ${response.statusCode})';
      }
    } catch (e) {
      _error = 'Connection error loading report: $e';
    }
  }

  Future<void> loadActiveAttendance(AuthProvider auth) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/attendance').replace(
        queryParameters: {'active': '1'},
      );
      final response = await http.get(uri, headers: auth.headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final records = (data['data'] as List).map((a) => Attendance.fromJson(a)).toList();
        _activeMemberIds = records.map((r) => r.memberId).toSet();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading active attendance: $e');
    }
  }
}
