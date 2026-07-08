import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/trainer.dart';
import 'auth_provider.dart';

class TrainerProvider extends ChangeNotifier {
  List<Trainer> _trainers = [];
  bool _isLoading = false;

  List<Trainer> get trainers => _trainers;
  bool get isLoading => _isLoading;

  Future<void> loadTrainers(AuthProvider auth, {String? search}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final queryParams = <String, String>{};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final uri = Uri.parse('${ApiConfig.baseUrl}/trainers').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: auth.headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _trainers = (data['data'] as List).map((t) => Trainer.fromJson(t)).toList();
      }
    } catch (e) {
      debugPrint('Error loading trainers: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Trainer?> createTrainer(AuthProvider auth, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/trainers'),
        headers: auth.headers,
        body: json.encode(data),
      );

      if (response.statusCode == 201) {
        final trainer = Trainer.fromJson(json.decode(response.body));
        _trainers.insert(0, trainer);
        notifyListeners();
        return trainer;
      }
    } catch (e) {
      debugPrint('Error creating trainer: $e');
    }
    return null;
  }

  Future<bool> updateTrainer(AuthProvider auth, int id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/trainers/$id'),
        headers: auth.headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final updated = Trainer.fromJson(json.decode(response.body));
        final index = _trainers.indexWhere((t) => t.trainerId == id);
        if (index != -1) _trainers[index] = updated;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error updating trainer: $e');
    }
    return false;
  }

  Future<bool> deleteTrainer(AuthProvider auth, int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/trainers/$id'),
        headers: auth.headers,
      );

      if (response.statusCode == 200) {
        _trainers.removeWhere((t) => t.trainerId == id);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error deleting trainer: $e');
    }
    return false;
  }
}
