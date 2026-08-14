import 'api_config.dart';

/// All API endpoint paths, centralised in one place.
/// Never hardcode endpoint strings outside of this file.
abstract final class ApiEndpoints {
  // Auth
  static const String login = '${ApiConfig.apiVersion}/auth/login';
  static const String register = '${ApiConfig.apiVersion}/auth/register';
  static const String me = '${ApiConfig.apiVersion}/auth/me';
  static String userDetail(String id) =>
      '${ApiConfig.apiVersion}/users/$id';

  // Topics & Steps
  static const String topics = '${ApiConfig.apiVersion}/topics';
  static String topicDetail(String id) =>
      '${ApiConfig.apiVersion}/topics/$id';
  static String stepDetail(String id) =>
      '${ApiConfig.apiVersion}/steps/$id';
  static String stepProgress(String id) =>
      '${ApiConfig.apiVersion}/steps/$id/progress';
  static String stepQuiz(String id) =>
      '${ApiConfig.apiVersion}/steps/$id/quiz';

  // Categories
  static const String categories = '${ApiConfig.apiVersion}/categories';

  // Explore
  static String exploreSearch(String query) =>
      '${ApiConfig.apiVersion}/explore/search?q=${Uri.encodeComponent(query)}';
  static String authorProfile(String identifier) =>
      '${ApiConfig.apiVersion}/explore/authors/$identifier';

  // Plan Requests (user)
  static const String myPlanRequests =
      '${ApiConfig.apiVersion}/plan-requests/my';
  static const String planRequests =
      '${ApiConfig.apiVersion}/plan-requests';

  // Plan Requests (admin)
  static String adminPlanRequests({String status = 'ALL', String search = ''}) =>
      '${ApiConfig.apiVersion}/admin/plan-requests?status=$status&search=$search';
  static String adminPlanRequestById(dynamic id) =>
      '${ApiConfig.apiVersion}/admin/plan-requests/$id';
}
