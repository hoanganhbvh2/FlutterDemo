import 'model_helpers.dart';

class LearningGroup {
  final String id;
  final String title;
  final String description;

  const LearningGroup({
    required this.id,
    required this.title,
    required this.description,
  });

  factory LearningGroup.fromJson(Map<String, dynamic> json) {
    return LearningGroup(
      id: parseStringValue(json['id']),
      title: parseStringValue(json['title']),
      description: parseStringValue(json['description']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
    };
  }
}
