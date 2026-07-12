import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/roadmap.dart';

class ApiService {
  // Default server url. Can be changed dynamically for local development.
  static const String defaultBaseUrl = "https://ais-dev-sohwmlejuebol6mgpb5ao5-158338261104.asia-southeast1.run.app"; // Fallback URL pointing to deployed container

  final String baseUrl;

  ApiService({this.baseUrl = defaultBaseUrl});

  /// Generates a complete learning roadmap from Gemini AI
  Future<Topic> generateRoadmap(String topicName, String customInstructions) async {
    final url = Uri.parse('$baseUrl/api/generate-roadmap');
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'topic': topicName,
          'description': customInstructions,
        }),
      ).timeout(const Duration(seconds: 45));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          final generated = decoded['data'];
          
          // Map backend JSON format to Dart models
          final String topicId = 'topic-${DateTime.now().millisecondsSinceEpoch}';
          final String createdAt = DateTime.now().toIso8601String();
          
          final List<Lesson> lessonsList = [];
          final lessonsJson = generated['lessons'] as List? ?? [];
          
          for (var i = 0; i < lessonsJson.length; i++) {
            final lessonJson = lessonsJson[i];
            final String lessonId = lessonJson['id'] ?? 'lesson-$topicId-$i';
            
            final List<StepNode> nodesList = [];
            final nodesJson = lessonJson['nodes'] as List? ?? [];
            for (var j = 0; j < nodesJson.length; j++) {
              final nodeJson = nodesJson[j];
              nodesList.add(StepNode(
                id: nodeJson['id'] ?? 'step-$topicId-$i-$j',
                lessonId: lessonId,
                title: nodeJson['title'] ?? '',
                description: nodeJson['description'] ?? '',
                emoji: nodeJson['emoji'] ?? '📝',
                positionX: (nodeJson['positionX'] as num?)?.toDouble() ?? (200.0 + (j % 2) * 300.0),
                positionY: (nodeJson['positionY'] as num?)?.toDouble() ?? (100.0 + j * 120.0),
                status: StepStatus.notStarted,
                order: nodeJson['order'] ?? (j + 1),
              ));
            }

            final List<Edge> edgesList = [];
            final edgesJson = lessonJson['edges'] as List? ?? [];
            for (var eIdx = 0; eIdx < edgesJson.length; eIdx++) {
              final edgeJson = edgesJson[eIdx];
              edgesList.add(Edge(
                id: edgeJson['id'] ?? 'edge-$topicId-$i-$eIdx',
                lessonId: lessonId,
                from: edgeJson['from'] ?? '',
                to: edgeJson['to'] ?? '',
              ));
            }

            lessonsList.add(Lesson(
              id: lessonId,
              topicId: topicId,
              title: lessonJson['title'] ?? 'Lesson ${i + 1}',
              description: lessonJson['description'] ?? '',
              order: lessonJson['order'] ?? (i + 1),
              nodes: nodesList,
              edges: edgesList,
            ));
          }

          return Topic(
            id: topicId,
            title: generated['topicTitle'] ?? topicName,
            description: generated['topicDescription'] ?? 'Lộ trình học tập do AI tự động tạo lập.',
            emoji: generated['topicEmoji'] ?? '🧠',
            lessons: lessonsList,
            createdAt: createdAt,
          );
        } else {
          throw Exception(decoded['error'] ?? 'Không thể khởi tạo lộ trình học tập từ AI.');
        }
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối với máy chủ AI: $e');
    }
  }
}
