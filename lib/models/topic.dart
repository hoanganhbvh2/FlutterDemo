import 'category.dart';
import 'lesson.dart';
import 'model_helpers.dart';

class Topic {
  final String id;
  final String? code;
  final List<String> categoryIds;
  final List<Category> categoryDetails;
  final List<String> tagIds;
  final List<Category> tagDetails;
  final String title;
  final String description;
  final String emoji;
  final String levelLabel;
  final int estimatedHours;
  final List<Lesson> lessons;
  final int progressPercent;
  final int completedStepsCount;
  final int totalStepsCount;

  const Topic({
    required this.id,
    this.code,
    this.categoryIds = const [],
    this.categoryDetails = const [],
    this.tagIds = const [],
    this.tagDetails = const [],
    required this.title,
    required this.description,
    required this.emoji,
    required this.levelLabel,
    required this.estimatedHours,
    required this.lessons,
    this.progressPercent = 0,
    this.completedStepsCount = 0,
    this.totalStepsCount = 0,
  });

  Topic copyWith({
    String? id,
    List<String>? categoryIds,
    List<Category>? categoryDetails,
    List<String>? tagIds,
    List<Category>? tagDetails,
    String? title,
    String? description,
    String? emoji,
    String? levelLabel,
    int? estimatedHours,
    List<Lesson>? lessons,
    int? progressPercent,
    int? completedStepsCount,
    int? totalStepsCount,
  }) {
    return Topic(
      id: id ?? this.id,
      categoryIds: categoryIds ?? this.categoryIds,
      categoryDetails: categoryDetails ?? this.categoryDetails,
      tagIds: tagIds ?? this.tagIds,
      tagDetails: tagDetails ?? this.tagDetails,
      title: title ?? this.title,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      levelLabel: levelLabel ?? this.levelLabel,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      lessons: lessons ?? this.lessons,
      progressPercent: progressPercent ?? this.progressPercent,
      completedStepsCount: completedStepsCount ?? this.completedStepsCount,
      totalStepsCount: totalStepsCount ?? this.totalStepsCount,
    );
  }

  factory Topic.fromJson(Map<String, dynamic> json) {
    final categories = (json['categories'] as List<dynamic>? ?? const <dynamic>[])
        .map(
          (item) => Category.fromJson({
            'id': item['id'],
            'title': item['title'],
            'description': item['description'],
            'icon': 'school',
          }),
        )
        .toList();

    final tags = (json['tags'] as List<dynamic>? ?? const <dynamic>[])
        .map(
          (item) => Category.fromJson({
            'id': item['id'],
            'title': item['title'],
            'description': item['description'],
            'icon': 'tag',
          }),
        )
        .toList();

    final categoryIds = parseStringList(json['categoryIds'] ?? json['category_ids']);
    final normalizedCategoryIds = categoryIds.isNotEmpty
        ? categoryIds
        : categories.map((item) => item.id).toList();

    final tagIds = parseStringList(json['tagIds'] ?? json['tag_ids']);
    final normalizedTagIds =
        tagIds.isNotEmpty ? tagIds : tags.map((item) => item.id).toList();

    return Topic(
      id: parseStringValue(json['id']),
      code: json['code'] != null ? parseStringValue(json['code']) : null,
      categoryIds: normalizedCategoryIds,
      categoryDetails: categories,
      tagIds: normalizedTagIds,
      tagDetails: tags,
      title: parseStringValue(json['title']),
      description: parseStringValue(json['description']),
      emoji: parseStringValue(json['emoji'], fallback: 'sparkles'),
      levelLabel: parseStringValue(
        json['levelLabel'] ?? json['level_label'],
        fallback: 'Beginner',
      ),
      estimatedHours: parseIntValue(
        json['estimatedHours'] ?? json['estimated_hours'],
        fallback: 0,
      ),
      lessons: (json['lessons'] as List<dynamic>? ?? const <dynamic>[])
          .map((item) => Lesson.fromJson(item as Map<String, dynamic>))
          .toList(),
      progressPercent:
          parseIntValue(json['progressPercent'] ?? json['progress_percent']),
      completedStepsCount: parseIntValue(
        json['completedStepsCount'] ?? json['completed_steps_count'],
      ),
      totalStepsCount: parseIntValue(
        json['totalStepsCount'] ?? json['total_steps_count'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryIds': categoryIds,
      'categories': categoryDetails.map((item) => item.toJson()).toList(),
      'tagIds': tagIds,
      'tags': tagDetails.map((item) => item.toJson()).toList(),
      'title': title,
      'description': description,
      'emoji': emoji,
      'levelLabel': levelLabel,
      'estimatedHours': estimatedHours,
      'lessons': lessons.map((item) => item.toJson()).toList(),
      'progressPercent': progressPercent,
      'completedStepsCount': completedStepsCount,
      'totalStepsCount': totalStepsCount,
    };
  }
}
