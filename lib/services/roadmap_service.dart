import '../models/roadmap.dart';
import 'api_client.dart';

class RoadmapService {
  RoadmapService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Topic>> getTopics() async {
    final data = await _apiClient.get('/api/v1/topics') as List<dynamic>;
    return data
        .map((item) => Topic.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Topic> getTopicDetail(String topicId) async {
    final data = await _apiClient.get('/api/v1/topics/$topicId') as Map<String, dynamic>;
    return Topic.fromJson(data);
  }

  Future<StepNode> getStepDetail(String stepId) async {
    final data = await _apiClient.get('/api/v1/steps/$stepId') as Map<String, dynamic>;
    return StepNode.fromJson(data);
  }

  Future<Map<String, dynamic>> updateStepProgress({
    required String stepId,
    required List<String> completedChecklist,
    required String status,
  }) async {
    final data = await _apiClient.put(
      '/api/v1/steps/$stepId/progress',
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
      '/api/v1/steps/$stepId/quiz',
      body: {
        'selectedAnswers': selectedAnswers,
      },
    ) as Map<String, dynamic>;
    return data;
  }
}
