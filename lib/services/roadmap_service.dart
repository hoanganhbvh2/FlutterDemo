import '../models/roadmap.dart';
import '../utils/api_config.dart';
import 'api_client.dart';

class RoadmapService {
  RoadmapService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Topic>> getTopics() async {
    final data = await _apiClient.get(ApiEndpoints.topics, requiresAuth: false);
    if (data is! List) {
      throw const ApiException('The backend returned an unexpected response for topics.');
    }
    return data
        .map((item) => Topic.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Topic> getTopicDetail(String topicId) async {
    final data = await _apiClient.get(ApiEndpoints.topicDetail(topicId), requiresAuth: false) as Map<String, dynamic>;
    return Topic.fromJson(data);
  }

  Future<StepNode> getStepDetail(String stepId) async {
    final data = await _apiClient.get(ApiEndpoints.stepDetail(stepId), requiresAuth: false) as Map<String, dynamic>;
    return StepNode.fromJson(data);
  }

  Future<Map<String, dynamic>> updateStepProgress({
    required String stepId,
    required List<String> completedChecklist,
    required String status,
  }) async {
    final data = await _apiClient.put(
      ApiEndpoints.stepProgress(stepId),
      requiresAuth: true,
      body: {
        'completedChecklist': completedChecklist,
        'status': status,
      },
    ) as Map<String, dynamic>;
    return data;
  }

  Future<Map<String, dynamic>> submitQuiz({
    required String stepId,
    required List<int> selectedAnswers,
  }) async {
    final data = await _apiClient.post(
      ApiEndpoints.stepQuiz(stepId),
      requiresAuth: true,
      body: {
        'selectedAnswers': selectedAnswers,
      },
    ) as Map<String, dynamic>;
    return data;
  }
}
