import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/equipment.dart';
import 'auth_provider.dart';

class EquipmentProvider extends ChangeNotifier {
  List<Equipment> _equipment = [];
  bool _isLoading = false;

  List<Equipment> get equipment => _equipment;
  bool get isLoading => _isLoading;

  Future<void> loadEquipment(AuthProvider auth, {String? search, String? status}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final queryParams = <String, String>{};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (status != null && status.isNotEmpty) queryParams['status'] = status;

      final uri = Uri.parse('${ApiConfig.baseUrl}/equipment').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: auth.headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _equipment = (data['data'] as List).map((e) => Equipment.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Error loading equipment: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Equipment?> createEquipment(AuthProvider auth, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/equipment'),
        headers: auth.headers,
        body: json.encode(data),
      );

      if (response.statusCode == 201) {
        final item = Equipment.fromJson(json.decode(response.body));
        _equipment.insert(0, item);
        notifyListeners();
        return item;
      }
    } catch (e) {
      debugPrint('Error creating equipment: $e');
    }
    return null;
  }

  Future<bool> updateEquipment(AuthProvider auth, int id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/equipment/$id'),
        headers: auth.headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final updated = Equipment.fromJson(json.decode(response.body));
        final index = _equipment.indexWhere((e) => e.equipmentId == id);
        if (index != -1) _equipment[index] = updated;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error updating equipment: $e');
    }
    return false;
  }

  Future<bool> deleteEquipment(AuthProvider auth, int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/equipment/$id'),
        headers: auth.headers,
      );

      if (response.statusCode == 200) {
        _equipment.removeWhere((e) => e.equipmentId == id);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error deleting equipment: $e');
    }
    return false;
  }
}
