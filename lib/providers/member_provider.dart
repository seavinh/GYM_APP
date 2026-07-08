import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/member.dart';
import '../models/trainer.dart';
import 'auth_provider.dart';

class MemberProvider extends ChangeNotifier {
  List<Member> _members = [];
  int _currentPage = 1;
  int _lastPage = 1;
  bool _isLoading = false;

  List<Member> get members => _members;
  bool get isLoading => _isLoading;
  bool get hasMore => _currentPage <= _lastPage;

  Future<void> loadMembers(AuthProvider auth, {String? search, bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _members = [];
    }

    _isLoading = true;
    notifyListeners();

    try {
      final queryParams = <String, String>{'page': _currentPage.toString()};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final uri = Uri.parse('${ApiConfig.baseUrl}/members').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: auth.headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newMembers = (data['data'] as List).map((m) => Member.fromJson(m)).toList();

        if (refresh) {
          _members = newMembers;
        } else {
          _members.addAll(newMembers);
        }

        _currentPage = data['current_page'] + 1;
        _lastPage = data['last_page'];
      }
    } catch (e) {
      debugPrint('Error loading members: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Member?> createMember(AuthProvider auth, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/members'),
        headers: auth.headers,
        body: json.encode(data),
      );

      if (response.statusCode == 201) {
        final member = Member.fromJson(json.decode(response.body));
        _members.insert(0, member);
        notifyListeners();
        return member;
      }
    } catch (e) {
      debugPrint('Error creating member: $e');
    }
    return null;
  }

  Future<bool> updateMember(AuthProvider auth, int id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/members/$id'),
        headers: auth.headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final updated = Member.fromJson(json.decode(response.body));
        final index = _members.indexWhere((m) => m.memberId == id);
        if (index != -1) _members[index] = updated;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error updating member: $e');
    }
    return false;
  }

  Future<bool> deleteMember(AuthProvider auth, int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/members/$id'),
        headers: auth.headers,
      );

      if (response.statusCode == 200) {
        _members.removeWhere((m) => m.memberId == id);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error deleting member: $e');
    }
    return false;
  }

  Future<bool> assignTrainer(AuthProvider auth, int memberId, int trainerId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/members/$memberId/assign-trainer'),
        headers: auth.headers,
        body: json.encode({'trainer_id': trainerId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final index = _members.indexWhere((m) => m.memberId == memberId);
        if (index != -1) {
          final member = _members[index];
          _members[index] = Member(
            memberId: member.memberId,
            userId: member.userId,
            fullName: member.fullName,
            gender: member.gender,
            dob: member.dob,
            phone: member.phone,
            email: member.email,
            address: member.address,
            joinDate: member.joinDate,
            trainers: (data['trainers'] as List).map((t) => Trainer.fromJson(t)).toList(),
          );
        }
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error assigning trainer: $e');
    }
    return false;
  }

}
