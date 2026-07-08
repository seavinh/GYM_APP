import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    if (kReleaseMode) return 'http://localhost:8000/api';
    if (kIsWeb) return 'http://localhost:8000/api';
    // Android emulator uses 10.0.2.2 to reach host machine
    return 'http://10.0.2.2:8000/api';
  }

  static const Duration timeout = Duration(seconds: 30);
}
