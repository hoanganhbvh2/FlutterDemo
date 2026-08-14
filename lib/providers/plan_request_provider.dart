import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/plan_request.dart';

class PlanRequestProvider extends ChangeNotifier {
  PlanRequestProvider(this._apiClient);

  final ApiClient _apiClient;

  List<PlanRequest> _myRequests = [];
  List<PlanRequest> _adminRequests = [];

  List<PlanRequest> get myRequests => _myRequests;
  List<PlanRequest> get adminRequests => _adminRequests;

  // ── User operations ───────────────────────────────────────────────────────

  Future<void> fetchMyPlanRequests() async {
    try {
      if (_apiClient.authToken == null || _apiClient.authToken!.isEmpty) return;

      final res = await _apiClient.get(
        ApiEndpoints.myPlanRequests,
        requiresAuth: true,
      );
      if (res is List) {
        _myRequests = res
            .map((item) => PlanRequest.fromJson(item as Map<String, dynamic>))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching plan requests: $e');
    }
  }

  Future<String?> submitPlanRequest({
    required String name,
    required String phone,
    required String content,
  }) async {
    try {
      if (_apiClient.authToken == null || _apiClient.authToken!.isEmpty) {
        return 'You must be signed in to submit a plan request.';
      }

      await _apiClient.post(
        ApiEndpoints.planRequests,
        requiresAuth: true,
        body: {
          'name': name.trim(),
          'phone': phone.trim(),
          'content': content.trim(),
        },
      );
      await fetchMyPlanRequests();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // ── Admin operations ───────────────────────────────────────────────────────

  Future<void> fetchAllPlanRequestsForAdmin({
    String status = 'ALL',
    String search = '',
  }) async {
    try {
      final token = _apiClient.authToken;
      if (token == null || token.isEmpty) return;

      final res = await _apiClient.get(
        ApiEndpoints.adminPlanRequests(status: status, search: search),
      );
      if (res is Map<String, dynamic> && res.containsKey('items')) {
        _adminRequests = (res['items'] as List)
            .map((item) => PlanRequest.fromJson(item as Map<String, dynamic>))
            .toList();
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<String?> updatePlanRequestStatus({
    required dynamic id,
    required String status,
    String? adminNote,
  }) async {
    try {
      await _apiClient.patch(
        ApiEndpoints.adminPlanRequestById(id),
        body: {'status': status, 'adminNote': adminNote},
      );
      await fetchAllPlanRequestsForAdmin();
      await fetchMyPlanRequests();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }
}
