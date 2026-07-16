import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/dashboard_data.dart';
import 'auth_controller.dart';

class DashboardController extends GetxController {
  DashboardData? _data;
  bool _isLoading = false;
  String? _error;

  DashboardData? get data => _data;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDashboard(AuthController auth) async {
    _isLoading = true;
    _error = null;
    update();

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/dashboard'),
        headers: auth.headers,
      );

      if (response.statusCode == 200) {
        _data = DashboardData.fromJson(json.decode(response.body));
      } else {
        final body = json.decode(response.body);
        _error = 'Failed to load dashboard (${response.statusCode}): ${body['message'] ?? body['errors']?.values.first?.first ?? 'Unknown error'}';
      }
    } catch (e) {
      _error = 'Connection error: $e';
    }

    _isLoading = false;
    update();
  }
}
