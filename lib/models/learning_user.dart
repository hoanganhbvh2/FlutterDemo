import 'enums.dart';
import 'learning_group.dart';
import 'model_helpers.dart';

Map<String, List<String>> _parseChecklistState(dynamic raw) {
  final json = raw as Map<String, dynamic>? ?? const <String, dynamic>{};
  final state = <String, List<String>>{};
  for (final entry in json.entries) {
    state[entry.key] = parseStringList(entry.value);
  }
  return state;
}

class LearningUser {
  final String id;
  final String? code;
  final String name;
  final String email;
  final String avatar;
  final LearningPlan plan;
  final List<String> groupIds;
  final int streakDays;
  final int gems;
  final int adsWatched;
  final List<String> completedStepIds;
  final List<String> unlockedRewardedStepIds;
  final List<String> passedQuizStepIds;
  final String role;
  final Map<String, List<String>> checklistState;
  final int completedStepsCount;
  final List<LearningGroup> groups;

  const LearningUser({
    required this.id,
    this.code,
    required this.name,
    required this.email,
    required this.avatar,
    required this.plan,
    this.role = 'USER',
    required this.groupIds,
    required this.streakDays,
    required this.gems,
    required this.adsWatched,
    required this.completedStepIds,
    required this.unlockedRewardedStepIds,
    required this.passedQuizStepIds,
    required this.checklistState,
    this.completedStepsCount = 0,
    this.groups = const [],
  });

  bool get isAdmin =>
      role.toUpperCase().contains('ADMIN') ||
      email.toLowerCase().contains('admin');

  LearningUser copyWith({
    String? id,
    String? code,
    String? name,
    String? email,
    String? avatar,
    LearningPlan? plan,
    List<String>? groupIds,
    int? streakDays,
    int? gems,
    int? adsWatched,
    List<String>? completedStepIds,
    List<String>? unlockedRewardedStepIds,
    List<String>? passedQuizStepIds,
    Map<String, List<String>>? checklistState,
    int? completedStepsCount,
    List<LearningGroup>? groups,
  }) {
    return LearningUser(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      plan: plan ?? this.plan,
      groupIds: groupIds ?? this.groupIds,
      streakDays: streakDays ?? this.streakDays,
      gems: gems ?? this.gems,
      adsWatched: adsWatched ?? this.adsWatched,
      completedStepIds: completedStepIds ?? this.completedStepIds,
      unlockedRewardedStepIds:
          unlockedRewardedStepIds ?? this.unlockedRewardedStepIds,
      passedQuizStepIds: passedQuizStepIds ?? this.passedQuizStepIds,
      checklistState: checklistState ?? this.checklistState,
      completedStepsCount: completedStepsCount ?? this.completedStepsCount,
      groups: groups ?? this.groups,
    );
  }

  factory LearningUser.fromJson(Map<String, dynamic> json) {
    final groups = (json['groups'] as List<dynamic>? ?? const <dynamic>[])
        .map((item) => LearningGroup.fromJson(item as Map<String, dynamic>))
        .toList();
    final groupIds = parseStringList(json['groupIds']);
    final normalizedGroupIds = groupIds.isNotEmpty
        ? groupIds
        : groups.map((item) => item.id).toList();

    final fullName = parseStringValue(
      json['fullName'] ?? json['name'] ?? json['userName'],
      fallback: 'Learner',
    );
    final completedCount = parseIntValue(json['completedStepsCount']);
    final completedSteps = parseStringList(json['completedStepIds']);

    return LearningUser(
      id: parseStringValue(json['id']),
      code: json['code'] != null ? parseStringValue(json['code']) : null,
      name: fullName,
      email: parseStringValue(json['email']),
      avatar: parseStringValue(
        json['avatar'],
        fallback: fullName.isEmpty ? 'L' : fullName.trim()[0].toUpperCase(),
      ),
      plan: parseLearningPlan(json['plan']),
      role: parseStringValue(json['role'] ?? json['role_id'], fallback: 'USER'),
      groupIds: normalizedGroupIds,
      streakDays: parseIntValue(json['streakDays']),
      gems: parseIntValue(json['gems'], fallback: completedCount * 10),
      adsWatched: parseIntValue(json['adsWatched']),
      completedStepIds: completedSteps,
      unlockedRewardedStepIds:
          parseStringList(json['unlockedRewardedStepIds']),
      passedQuizStepIds: parseStringList(json['passedQuizStepIds']),
      checklistState: _parseChecklistState(json['checklistState']),
      completedStepsCount: completedCount,
      groups: groups,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'plan': plan.name,
      'groupIds': groupIds,
      'streakDays': streakDays,
      'gems': gems,
      'adsWatched': adsWatched,
      'completedStepIds': completedStepIds,
      'unlockedRewardedStepIds': unlockedRewardedStepIds,
      'passedQuizStepIds': passedQuizStepIds,
      'checklistState': checklistState,
      'completedStepsCount': completedStepsCount,
      'groups': groups.map((item) => item.toJson()).toList(),
    };
  }
}
