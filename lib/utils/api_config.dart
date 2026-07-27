import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String productionBaseUrl = 'http://10.0.2.2:5001';
  // static const String productionBaseUrl = 'https://api.hocmeo.io.vn';

  static const String apiVersion = '/api/v1';

  static String defaultBaseUrl() {
    const configured = String.fromEnvironment('API_BASE_URL');
    if (configured.isNotEmpty) {
      return configured;
    }
    return productionBaseUrl;
  }
}

class ApiEndpoints {
  // Auth
  static const String login = '${ApiConfig.apiVersion}/auth/login';
  static const String register = '${ApiConfig.apiVersion}/auth/register';
  static const String me = '${ApiConfig.apiVersion}/auth/me';
  static String userDetail(String id) => '${ApiConfig.apiVersion}/users/$id';

  // Topics, Lessons, Steps
  static const String topics = '${ApiConfig.apiVersion}/topics';
  static String topicDetail(String id) => '${ApiConfig.apiVersion}/topics/$id';
  static String stepDetail(String id) => '${ApiConfig.apiVersion}/steps/$id';
  static String stepProgress(String id) =>
      '${ApiConfig.apiVersion}/steps/$id/progress';
  static String stepQuiz(String id) => '${ApiConfig.apiVersion}/steps/$id/quiz';
}
