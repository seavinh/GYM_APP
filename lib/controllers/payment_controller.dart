import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/payment.dart';
import 'auth_controller.dart';

class PaymentController extends GetxController {
  List<Payment> _payments = [];
  int _currentPage = 1;
  int _lastPage = 1;
  bool _isLoading = false;

  List<Payment> get payments => _payments;
  bool get isLoading => _isLoading;
  bool get hasMore => _currentPage <= _lastPage;

  Future<void> loadPayments(AuthController auth, {int? memberId, bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _payments = [];
    }

    _isLoading = true;
    update();

    try {
      final queryParams = <String, String>{'page': _currentPage.toString()};
      if (memberId != null) queryParams['member_id'] = memberId.toString();

      final uri = Uri.parse('${ApiConfig.baseUrl}/payments').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: auth.headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newPayments = (data['data'] as List).map((p) => Payment.fromJson(p)).toList();

        if (refresh) {
          _payments = newPayments;
        } else {
          _payments.addAll(newPayments);
        }

        _currentPage = data['current_page'] + 1;
        _lastPage = data['last_page'];
      }
    } catch (e) {
      Get.printError(info: 'Error loading payments: $e');
    }

    _isLoading = false;
    update();
  }

  Future<Payment?> createPayment(AuthController auth, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/payments'),
        headers: auth.headers,
        body: json.encode(data),
      );

      if (response.statusCode == 201) {
        final payment = Payment.fromJson(json.decode(response.body));
        _payments.insert(0, payment);
        update();
        return payment;
      }
    } catch (e) {
      Get.printError(info: 'Error creating payment: $e');
    }
    return null;
  }

  Future<bool> updatePayment(AuthController auth, int id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/payments/$id'),
        headers: auth.headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final updated = Payment.fromJson(json.decode(response.body));
        final index = _payments.indexWhere((p) => p.paymentId == id);
        if (index != -1) _payments[index] = updated;
        update();
        return true;
      }
    } catch (e) {
      Get.printError(info: 'Error updating payment: $e');
    }
    return false;
  }

  Future<bool> deletePayment(AuthController auth, int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/payments/$id'),
        headers: auth.headers,
      );

      if (response.statusCode == 200) {
        _payments.removeWhere((p) => p.paymentId == id);
        update();
        return true;
      }
    } catch (e) {
      Get.printError(info: 'Error deleting payment: $e');
    }
    return false;
  }

  Future<Map<String, dynamic>?> getReceipt(AuthController auth, int paymentId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/payments/$paymentId/receipt'),
        headers: auth.headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body)['receipt'];
      }
    } catch (e) {
      Get.printError(info: 'Error fetching receipt: $e');
    }
    return null;
  }
}
