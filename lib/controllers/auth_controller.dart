import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/user.dart';

class AuthController extends GetxController {
  User? _user;
  String? _token;
  String? _memberName;
  int? _memberId;
  bool _isLoading = false;

  User? get user => _user;
  String? get token => _token;
  String? get memberName => _memberName;
  int? get memberId => _memberId;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;

  @override
  void onInit() {
    super.onInit();
    init();
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    final userJson = prefs.getString('user');
    _memberName = prefs.getString('member_name');
    _memberId = prefs.getInt('member_id');

    if (userJson != null && _token != null) {
      _user = User.fromJson(json.decode(userJson));
      update();
    }
  }

  Future<String?> login(String username, String password) async {
    _isLoading = true;
    update();

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/login'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: json.encode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _token = data['token'];
        _user = User.fromJson(data['user']);
        _memberName = data['member']?['full_name'];
        _memberId = data['member']?['member_id'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        await prefs.setString('user', json.encode(data['user']));
        if (_memberName != null) await prefs.setString('member_name', _memberName!);
        if (_memberId != null) await prefs.setInt('member_id', _memberId!);

        _isLoading = false;
        update();
        return null;
      } else {
        final data = json.decode(response.body);
        _isLoading = false;
        update();
        return data['message'] ?? data['errors']?.values.first?.first ?? 'Login failed';
      }
    } catch (e) {
      _isLoading = false;
      update();
      return 'Connection error: $e';
    }
  }

  Future<String?> register(String username, String password, String role) async {
    _isLoading = true;
    update();

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/register'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
          'password_confirmation': password,
          'role': role,
        }),
      );

      _isLoading = false;
      update();

      if (response.statusCode == 201) {
        return null;
      } else {
        final data = json.decode(response.body);
        return data['message'] ?? data['errors']?.values.first?.first ?? 'Registration failed';
      }
    } catch (e) {
      _isLoading = false;
      update();
      return 'Connection error: $e';
    }
  }

  Future<void> logout() async {
    if (_token != null) {
      try {
        await http.post(
          Uri.parse('${ApiConfig.baseUrl}/logout'),
          headers: {
            'Authorization': 'Bearer $_token',
            'Accept': 'application/json',
          },
        );
      } catch (_) {}
    }

    _user = null;
    _token = null;
    _memberName = null;
    _memberId = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    update();
  }

  Map<String, String> get headers => {
    'Authorization': 'Bearer $_token',
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
