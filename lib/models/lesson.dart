import 'enums.dart';
import 'model_helpers.dart';
import 'step_node.dart';

class Lesson {
  final String id;
  final String? code;
  final String topicId;
  final String title;
  final String description;
  final int order;
  final AccessLevel accessLevel;
  final List<String> allowedGroupIds;
  final int estimatedMinutes;
  final List<StepNode> steps;
  final int completedStepsCount;
  final int totalStepsCount;

  const Lesson({
    required this.id,
    this.code,
    required this.topicId,
    required this.title,
    required this.description,
    required this.order,
    required this.accessLevel,
    required this.allowedGroupIds,
    required this.estimatedMinutes,
    required this.steps,
    this.completedStepsCount = 0,
    this.totalStepsCount = 0,
  });

  Lesson copyWith({
    String? id,
    String? code,
    String? topicId,
    String? title,
    String? description,
    int? order,
    AccessLevel? accessLevel,
    List<String>? allowedGroupIds,
    int? estimatedMinutes,
    List<StepNode>? steps,
    int? completedStepsCount,
    int? totalStepsCount,
  }) {
    return Lesson(
      id: id ?? this.id,
      code: code ?? this.code,
      topicId: topicId ?? this.topicId,
      title: title ?? this.title,
      description: description ?? this.description,
      order: order ?? this.order,
      accessLevel: accessLevel ?? this.accessLevel,
      allowedGroupIds: allowedGroupIds ?? this.allowedGroupIds,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      steps: steps ?? this.steps,
      completedStepsCount: completedStepsCount ?? this.completedStepsCount,
      totalStepsCount: totalStepsCount ?? this.totalStepsCount,
    );
  }

  factory Lesson.fromJson(Map<String, dynamic> json) {
    final steps = (json['steps'] as List<dynamic>? ?? const <dynamic>[])
        .map((item) => StepNode.fromJson(item as Map<String, dynamic>))
        .toList();

    return Lesson(
      id: parseStringValue(json['id']),
      code: json['code'] != null ? parseStringValue(json['code']) : null,
      topicId: parseStringValue(json['topicId'] ?? json['topic_id']),
      title: parseStringValue(json['title']),
      description: parseStringValue(json['description'] ?? json['summary']),
      order: parseIntValue(
        json['order'] ?? json['orderIndex'] ?? json['order_index'],
        fallback: 1,
      ),
      accessLevel: parseAccessLevel(json['accessLevel'] ?? json['access_level']),
      allowedGroupIds:
          parseStringList(json['allowedGroupIds'] ?? json['allowed_group_ids']),
      estimatedMinutes: parseIntValue(
        json['estimatedMinutes'] ?? json['estimated_minutes'],
        fallback: 30,
      ),
      steps: steps,
      completedStepsCount: parseIntValue(
        json['completedStepsCount'] ?? json['completed_steps_count'],
      ),
      totalStepsCount: parseIntValue(
        json['totalStepsCount'] ?? json['total_steps_count'],
        fallback: steps.length,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'topicId': topicId,
      'title': title,
      'description': description,
      'order': order,
      'accessLevel': accessLevel.name,
      'allowedGroupIds': allowedGroupIds,
      'estimatedMinutes': estimatedMinutes,
      'steps': steps.map((item) => item.toJson()).toList(),
      'completedStepsCount': completedStepsCount,
      'totalStepsCount': totalStepsCount,
    };
  }
}
