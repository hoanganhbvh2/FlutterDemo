import 'enums.dart';

/// Shared JSON parsing helpers used by all model `fromJson` factories.
/// These functions are intentionally non-private so they can be imported
/// by the individual model files under `lib/models/`.

String parseStringValue(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  final normalized = value.toString().trim();
  return normalized.isEmpty ? fallback : normalized;
}

List<String> parseStringList(dynamic raw) {
  final list = raw as List<dynamic>? ?? const <dynamic>[];
  return list
      .map((item) => parseStringValue(item))
      .where((item) => item.isNotEmpty)
      .toList();
}

int parseIntValue(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

AccessLevel parseAccessLevel(dynamic value) {
  switch (parseStringValue(value).toUpperCase()) {
    case 'REWARDED':
      return AccessLevel.rewarded;
    case 'PREMIUM':
      return AccessLevel.premium;
    case 'GROUP':
      return AccessLevel.group;
    default:
      return AccessLevel.free;
  }
}

LearningPlan parseLearningPlan(dynamic value) {
  switch (parseStringValue(value).toUpperCase()) {
    case 'PREMIUM':
      return LearningPlan.premium;
    case 'GROUP':
    case 'GROUPPRO':
    case 'GROUP_PRO':
      return LearningPlan.groupPro;
    default:
      return LearningPlan.free;
  }
}

ProgressStatus parseProgressStatus(dynamic value) {
  switch (parseStringValue(value).toUpperCase()) {
    case 'IN_PROGRESS':
      return ProgressStatus.inProgress;
    case 'COMPLETED':
      return ProgressStatus.completed;
    case 'LOCKED':
      return ProgressStatus.locked;
    default:
      return ProgressStatus.notStarted;
  }
}

StepContentBlockType parseBlockType(dynamic value) {
  switch (parseStringValue(value).toUpperCase()) {
    case 'HEADING':
      return StepContentBlockType.heading;
    case 'PARAGRAPH':
      return StepContentBlockType.paragraph;
    case 'CALLOUT':
      return StepContentBlockType.callout;
    case 'BULLETS':
      return StepContentBlockType.bullets;
    case 'QUOTE':
      return StepContentBlockType.quote;
    case 'IMAGE':
      return StepContentBlockType.image;
    case 'AUDIO':
      return StepContentBlockType.audio;
    case 'CODE':
      return StepContentBlockType.code;
    case 'DIVIDER':
      return StepContentBlockType.divider;
    default:
      return StepContentBlockType.paragraph;
  }
}
