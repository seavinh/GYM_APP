import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/membership.dart';
import 'auth_controller.dart';

class MembershipController extends GetxController {
  List<Membership> _memberships = [];
  bool _isLoading = false;

  List<Membership> get memberships => _memberships;
  bool get isLoading => _isLoading;

  Future<void> loadMemberships(AuthController auth) async {
    _isLoading = true;
    update();

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/memberships'),
        headers: auth.headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _memberships = (data as List).map((m) => Membership.fromJson(m)).toList();
      }
    } catch (e) {
      Get.printError(info: 'Error loading memberships: $e');
    }

    _isLoading = false;
    update();
  }

  Future<Membership?> createMembership(AuthController auth, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/memberships'),
        headers: auth.headers,
        body: json.encode(data),
      );

      if (response.statusCode == 201) {
        final membership = Membership.fromJson(json.decode(response.body));
        _memberships.insert(0, membership);
        update();
        return membership;
      }
    } catch (e) {
      Get.printError(info: 'Error creating membership: $e');
    }
    return null;
  }

  Future<bool> updateMembership(AuthController auth, int id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/memberships/$id'),
        headers: auth.headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final updated = Membership.fromJson(json.decode(response.body));
        final index = _memberships.indexWhere((m) => m.membershipId == id);
        if (index != -1) _memberships[index] = updated;
        update();
        return true;
      }
    } catch (e) {
      Get.printError(info: 'Error updating membership: $e');
    }
    return false;
  }

  Future<bool> deleteMembership(AuthController auth, int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/memberships/$id'),
        headers: auth.headers,
      );

      if (response.statusCode == 200) {
        _memberships.removeWhere((m) => m.membershipId == id);
        update();
        return true;
      }
    } catch (e) {
      Get.printError(info: 'Error deleting membership: $e');
    }
    return false;
  }
}
