import 'package:flutter/foundation.dart';

/// Base URL configuration driven by compile-time dart-define.
abstract final class ApiConfig {
  static const String productionBaseUrl = 'https://api.hocmeo.io.vn';
  static const String localAndroidBaseUrl = 'http://10.0.2.2:3000';
  static const String localDefaultBaseUrl = 'http://localhost:3000';

  static const String apiVersion = '/api/v1';

  static String defaultBaseUrl() {
    const configured = String.fromEnvironment('API_BASE_URL');
    if (configured.isNotEmpty) {
      return configured;
    }

    if (kDebugMode) {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        return localAndroidBaseUrl;
      }
      return localDefaultBaseUrl;
    }

    return productionBaseUrl;
  }
}
