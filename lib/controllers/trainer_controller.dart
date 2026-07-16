import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/trainer.dart';
import 'auth_controller.dart';

class TrainerController extends GetxController {
  List<Trainer> _trainers = [];
  bool _isLoading = false;

  List<Trainer> get trainers => _trainers;
  bool get isLoading => _isLoading;

  Future<void> loadTrainers(AuthController auth, {String? search}) async {
    _isLoading = true;
    update();

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
      Get.printError(info: 'Error loading trainers: $e');
    }

    _isLoading = false;
    update();
  }

  Future<Trainer?> createTrainer(AuthController auth, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/trainers'),
        headers: auth.headers,
        body: json.encode(data),
      );

      if (response.statusCode == 201) {
        final trainer = Trainer.fromJson(json.decode(response.body));
        _trainers.insert(0, trainer);
        update();
        return trainer;
      }
    } catch (e) {
      Get.printError(info: 'Error creating trainer: $e');
    }
    return null;
  }

  Future<bool> updateTrainer(AuthController auth, int id, Map<String, dynamic> data) async {
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
        update();
        return true;
      }
    } catch (e) {
      Get.printError(info: 'Error updating trainer: $e');
    }
    return false;
  }

  Future<bool> deleteTrainer(AuthController auth, int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/trainers/$id'),
        headers: auth.headers,
      );

      if (response.statusCode == 200) {
        _trainers.removeWhere((t) => t.trainerId == id);
        update();
        return true;
      }
    } catch (e) {
      Get.printError(info: 'Error deleting trainer: $e');
    }
    return false;
  }
}
