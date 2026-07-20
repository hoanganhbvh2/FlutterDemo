enum AccessLevel {
  free,
  rewarded,
  premium,
  group,
}

enum LearningPlan {
  free,
  premium,
  groupPro,
}

enum StepVisualState {
  locked,
  ready,
  inProgress,
  completed,
}

enum StepContentBlockType {
  heading,
  paragraph,
  callout,
  bullets,
  quote,
  image,
  audio,
  code,
  divider,
}

enum ProgressStatus {
  notStarted,
  inProgress,
  completed,
  locked,
}

class Category {
  final String id;
  final String title;
  final String subtitle;
  final String icon;

  const Category({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: _stringValue(json['id']),
      title: _stringValue(json['title']),
      subtitle: _stringValue(json['subtitle'] ?? json['description']),
      icon: _stringValue(json['icon'], fallback: 'school'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'icon': icon,
    };
  }
}

class ChecklistItem {
  final String id;
  final String text;

  const ChecklistItem({
    required this.id,
    required this.text,
  });

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      id: _stringValue(json['id']),
      text: _stringValue(json['text']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
    };
  }
}

class QuizQuestion {
  final String id;
  final String prompt;
  final List<String> options;
  final int correctIndex;

  const QuizQuestion({
    required this.id,
    required this.prompt,
    required this.options,
    required this.correctIndex,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: _stringValue(json['id']),
      prompt: _stringValue(json['prompt']),
      options: _stringList(json['options']),
      correctIndex: _intValue(json['correctIndex']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prompt': prompt,
      'options': options,
      'correctIndex': correctIndex,
    };
  }
}

class StepQuiz {
  final int passThreshold;
  final List<QuizQuestion> questions;

  const StepQuiz({
    required this.passThreshold,
    required this.questions,
  });

  factory StepQuiz.fromJson(Map<String, dynamic> json) {
    final questions = (json['questions'] as List<dynamic>? ?? const <dynamic>[])
        .map((item) => QuizQuestion.fromJson(item as Map<String, dynamic>))
        .toList();

    var threshold = _intValue(
      json['passThreshold'],
      fallback: questions.isEmpty ? 0 : questions.length,
    );
    if (questions.isNotEmpty && threshold > questions.length) {
      threshold = questions.length;
    }

    return StepQuiz(
      passThreshold: threshold,
      questions: questions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'passThreshold': passThreshold,
      'questions': questions.map((item) => item.toJson()).toList(),
    };
  }
}

class StepContentBlock {
  final String id;
  final StepContentBlockType type;
  final String title;
  final String body;
  final List<String> items;
  final String mediaUrl;
  final String caption;
  final String codeLanguage;

  const StepContentBlock({
    required this.id,
    required this.type,
    this.title = '',
    this.body = '',
    this.items = const [],
    this.mediaUrl = '',
    this.caption = '',
    this.codeLanguage = '',
  });

  factory StepContentBlock.fromJson(Map<String, dynamic> json) {
    return StepContentBlock(
      id: _stringValue(json['id']),
      type: _parseBlockType(json['type']),
      title: _stringValue(json['title']),
      body: _stringValue(json['body']),
      items: _stringList(json['items']),
      mediaUrl: _stringValue(json['mediaUrl']),
      caption: _stringValue(json['caption']),
      codeLanguage: _stringValue(json['codeLanguage']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'body': body,
      'items': items,
      'mediaUrl': mediaUrl,
      'caption': caption,
      'codeLanguage': codeLanguage,
    };
  }

  static List<StepContentBlock> legacyBlocks({
    required String theory,
    required String note,
    required String codeSnippet,
    required String codeLanguage,
  }) {
    final blocks = <StepContentBlock>[];

    if (theory.trim().isNotEmpty) {
      blocks.add(
        StepContentBlock(
          id: 'legacy-theory',
          type: StepContentBlockType.paragraph,
          body: theory,
        ),
      );
    }

    if (note.trim().isNotEmpty) {
      blocks.add(
        StepContentBlock(
          id: 'legacy-note',
          type: StepContentBlockType.callout,
          body: note,
        ),
      );
    }

    if (codeSnippet.trim().isNotEmpty) {
      blocks.add(
        StepContentBlock(
          id: 'legacy-code',
          type: StepContentBlockType.code,
          body: codeSnippet,
          codeLanguage: codeLanguage,
        ),
      );
    }

    return blocks;
  }
}

class StepNode {
  final String id;
  final String lessonId;
  final String title;
  final String description;
  final String emoji;
  final int order;
  final AccessLevel accessLevel;
  final List<String> allowedGroupIds;
  final List<String> prerequisiteStepIds;
  final List<ChecklistItem> checklist;
  final StepQuiz? quiz;
  final String note;
  final String theory;
  final String codeSnippet;
  final String codeLanguage;
  final List<StepContentBlock> contentBlocks;
  final int xpReward;
  final int estimatedMinutes;
  final ProgressStatus progressStatus;
  final List<String> completedChecklist;
  final int quizScore;

  const StepNode({
    required this.id,
    required this.lessonId,
    required this.title,
    required this.description,
    required this.emoji,
    required this.order,
    required this.accessLevel,
    required this.allowedGroupIds,
    required this.prerequisiteStepIds,
    required this.checklist,
    required this.note,
    required this.theory,
    required this.codeSnippet,
    required this.codeLanguage,
    this.contentBlocks = const [],
    required this.xpReward,
    required this.estimatedMinutes,
    this.quiz,
    this.progressStatus = ProgressStatus.notStarted,
    this.completedChecklist = const [],
    this.quizScore = 0,
  });

  StepNode copyWith({
    String? id,
    String? lessonId,
    String? title,
    String? description,
    String? emoji,
    int? order,
    AccessLevel? accessLevel,
    List<String>? allowedGroupIds,
    List<String>? prerequisiteStepIds,
    List<ChecklistItem>? checklist,
    StepQuiz? quiz,
    bool clearQuiz = false,
    String? note,
    String? theory,
    String? codeSnippet,
    String? codeLanguage,
    List<StepContentBlock>? contentBlocks,
    int? xpReward,
    int? estimatedMinutes,
    ProgressStatus? progressStatus,
    List<String>? completedChecklist,
    int? quizScore,
  }) {
    return StepNode(
      id: id ?? this.id,
      lessonId: lessonId ?? this.lessonId,
      title: title ?? this.title,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      order: order ?? this.order,
      accessLevel: accessLevel ?? this.accessLevel,
      allowedGroupIds: allowedGroupIds ?? this.allowedGroupIds,
      prerequisiteStepIds: prerequisiteStepIds ?? this.prerequisiteStepIds,
      checklist: checklist ?? this.checklist,
      quiz: clearQuiz ? null : (quiz ?? this.quiz),
      note: note ?? this.note,
      theory: theory ?? this.theory,
      codeSnippet: codeSnippet ?? this.codeSnippet,
      codeLanguage: codeLanguage ?? this.codeLanguage,
      contentBlocks: contentBlocks ?? this.contentBlocks,
      xpReward: xpReward ?? this.xpReward,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      progressStatus: progressStatus ?? this.progressStatus,
      completedChecklist: completedChecklist ?? this.completedChecklist,
      quizScore: quizScore ?? this.quizScore,
    );
  }

  factory StepNode.fromJson(Map<String, dynamic> json) {
    final checklist = _parseChecklist(json['checklist']);
    final passThreshold = _intValue(json['passThreshold']);
    final quizQuestions = (json['quizQuestions'] as List<dynamic>? ?? const <dynamic>[])
        .map((item) => QuizQuestion.fromJson(item as Map<String, dynamic>))
        .toList();

    StepQuiz? quiz;
    final quizJson = json['quiz'];
    if (quizJson is Map<String, dynamic>) {
      quiz = StepQuiz.fromJson(quizJson);
    } else if (quizQuestions.isNotEmpty || passThreshold > 0) {
      quiz = StepQuiz(
        passThreshold: passThreshold > 0 ? passThreshold : quizQuestions.length,
        questions: quizQuestions,
      );
    }

    return StepNode(
      id: _stringValue(json['id']),
      lessonId: _stringValue(json['lessonId']),
      title: _stringValue(json['title']),
      description: _stringValue(json['description'] ?? json['summary']),
      emoji: _stringValue(json['emoji'], fallback: 'book'),
      order: _intValue(json['order'] ?? json['orderIndex'], fallback: 1),
      accessLevel: _parseAccessLevel(json['accessLevel']),
      allowedGroupIds: _stringList(json['allowedGroupIds']),
      prerequisiteStepIds: _stringList(json['prerequisiteStepIds']),
      checklist: checklist,
      quiz: quiz,
      note: _stringValue(json['note']),
      theory: _stringValue(json['theory']),
      codeSnippet: _stringValue(json['codeSnippet']),
      codeLanguage: _stringValue(json['codeLanguage']),
      contentBlocks: (json['contentBlocks'] as List<dynamic>? ?? const <dynamic>[])
          .map((item) => StepContentBlock.fromJson(item as Map<String, dynamic>))
          .toList(),
      xpReward: _intValue(json['xpReward'], fallback: 30),
      estimatedMinutes: _intValue(json['estimatedMinutes'], fallback: 10),
      progressStatus: _parseProgressStatus(json['progressStatus']),
      completedChecklist: _stringList(json['completedChecklist']),
      quizScore: _intValue(json['quizScore']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lessonId': lessonId,
      'title': title,
      'description': description,
      'emoji': emoji,
      'order': order,
      'accessLevel': accessLevel.name,
      'allowedGroupIds': allowedGroupIds,
      'prerequisiteStepIds': prerequisiteStepIds,
      'checklist': checklist.map((item) => item.toJson()).toList(),
      'note': note,
      'theory': theory,
      'codeSnippet': codeSnippet,
      'codeLanguage': codeLanguage,
      'contentBlocks': contentBlocks.map((item) => item.toJson()).toList(),
      'xpReward': xpReward,
      'estimatedMinutes': estimatedMinutes,
      'quiz': quiz?.toJson(),
      'progressStatus': progressStatus.name,
      'completedChecklist': completedChecklist,
      'quizScore': quizScore,
    };
  }

  List<StepContentBlock> get displayContentBlocks {
    if (contentBlocks.isNotEmpty) {
      return contentBlocks;
    }

    return StepContentBlock.legacyBlocks(
      theory: theory,
      note: note,
      codeSnippet: codeSnippet,
      codeLanguage: codeLanguage,
    );
  }

  bool get hasImageBlock =>
      displayContentBlocks.any((item) => item.type == StepContentBlockType.image);

  bool get hasAudioBlock =>
      displayContentBlocks.any((item) => item.type == StepContentBlockType.audio);

  bool get hasQuiz => quiz != null && (quiz!.passThreshold > 0 || quiz!.questions.isNotEmpty);

  bool get hasPassedQuiz =>
      hasQuiz &&
      quiz!.passThreshold > 0 &&
      quizScore >= quiz!.passThreshold;

  bool get isCompleted => progressStatus == ProgressStatus.completed;
}

class Lesson {
  final String id;
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
      id: _stringValue(json['id']),
      topicId: _stringValue(json['topicId']),
      title: _stringValue(json['title']),
      description: _stringValue(json['description'] ?? json['summary']),
      order: _intValue(json['order'] ?? json['orderIndex'], fallback: 1),
      accessLevel: _parseAccessLevel(json['accessLevel']),
      allowedGroupIds: _stringList(json['allowedGroupIds']),
      estimatedMinutes: _intValue(json['estimatedMinutes'], fallback: 30),
      steps: steps,
      completedStepsCount: _intValue(json['completedStepsCount']),
      totalStepsCount: _intValue(
        json['totalStepsCount'],
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

class Topic {
  final String id;
  final List<String> tagIds;
  final String title;
  final String description;
  final String emoji;
  final String levelLabel;
  final int estimatedHours;
  final List<Lesson> lessons;
  final int progressPercent;
  final int completedStepsCount;
  final int totalStepsCount;
  final List<Category> tagDetails;

  const Topic({
    required this.id,
    required this.tagIds,
    required this.title,
    required this.description,
    required this.emoji,
    required this.levelLabel,
    required this.estimatedHours,
    required this.lessons,
    this.progressPercent = 0,
    this.completedStepsCount = 0,
    this.totalStepsCount = 0,
    this.tagDetails = const [],
  });

  Topic copyWith({
    String? id,
    List<String>? tagIds,
    String? title,
    String? description,
    String? emoji,
    String? levelLabel,
    int? estimatedHours,
    List<Lesson>? lessons,
    int? progressPercent,
    int? completedStepsCount,
    int? totalStepsCount,
    List<Category>? tagDetails,
  }) {
    return Topic(
      id: id ?? this.id,
      tagIds: tagIds ?? this.tagIds,
      title: title ?? this.title,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      levelLabel: levelLabel ?? this.levelLabel,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      lessons: lessons ?? this.lessons,
      progressPercent: progressPercent ?? this.progressPercent,
      completedStepsCount: completedStepsCount ?? this.completedStepsCount,
      totalStepsCount: totalStepsCount ?? this.totalStepsCount,
      tagDetails: tagDetails ?? this.tagDetails,
    );
  }

  factory Topic.fromJson(Map<String, dynamic> json) {
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

    final tagIds = _stringList(json['tagIds']);
    final normalizedTagIds = tagIds.isNotEmpty
        ? tagIds
        : tags.map((item) => item.id).toList();

    return Topic(
      id: _stringValue(json['id']),
      tagIds: normalizedTagIds,
      title: _stringValue(json['title']),
      description: _stringValue(json['description']),
      emoji: _stringValue(json['emoji'], fallback: 'sparkles'),
      levelLabel: _stringValue(json['levelLabel'], fallback: 'Beginner'),
      estimatedHours: _intValue(json['estimatedHours'], fallback: 0),
      lessons: (json['lessons'] as List<dynamic>? ?? const <dynamic>[])
          .map((item) => Lesson.fromJson(item as Map<String, dynamic>))
          .toList(),
      progressPercent: _intValue(json['progressPercent']),
      completedStepsCount: _intValue(json['completedStepsCount']),
      totalStepsCount: _intValue(json['totalStepsCount']),
      tagDetails: tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tagIds': tagIds,
      'title': title,
      'description': description,
      'emoji': emoji,
      'levelLabel': levelLabel,
      'estimatedHours': estimatedHours,
      'lessons': lessons.map((item) => item.toJson()).toList(),
      'progressPercent': progressPercent,
      'completedStepsCount': completedStepsCount,
      'totalStepsCount': totalStepsCount,
      'tags': tagDetails.map((item) => item.toJson()).toList(),
    };
  }
}

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
      id: _stringValue(json['id']),
      title: _stringValue(json['title']),
      description: _stringValue(json['description']),
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

class LearningUser {
  final String id;
  final String name;
  final String email;
  final String password;
  final String avatar;
  final LearningPlan plan;
  final List<String> groupIds;
  final int streakDays;
  final int gems;
  final int adsWatched;
  final List<String> completedStepIds;
  final List<String> unlockedRewardedStepIds;
  final List<String> passedQuizStepIds;
  final Map<String, List<String>> checklistState;
  final int completedStepsCount;
  final List<LearningGroup> groups;

  const LearningUser({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.avatar,
    required this.plan,
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

  LearningUser copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
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
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
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
    final groupIds = _stringList(json['groupIds']);
    final normalizedGroupIds = groupIds.isNotEmpty
        ? groupIds
        : groups.map((item) => item.id).toList();

    final fullName = _stringValue(
      json['fullName'] ?? json['name'] ?? json['userName'],
      fallback: 'Learner',
    );
    final completedCount = _intValue(json['completedStepsCount']);
    final completedSteps = _stringList(json['completedStepIds']);

    return LearningUser(
      id: _stringValue(json['id']),
      name: fullName,
      email: _stringValue(json['email']),
      password: _stringValue(json['password']),
      avatar: _stringValue(
        json['avatar'],
        fallback: fullName.isEmpty ? 'L' : fullName.trim()[0].toUpperCase(),
      ),
      plan: _parseLearningPlan(json['plan']),
      groupIds: normalizedGroupIds,
      streakDays: _intValue(json['streakDays']),
      gems: _intValue(json['gems'], fallback: completedCount * 10),
      adsWatched: _intValue(json['adsWatched']),
      completedStepIds: completedSteps,
      unlockedRewardedStepIds: _stringList(json['unlockedRewardedStepIds']),
      passedQuizStepIds: _stringList(json['passedQuizStepIds']),
      checklistState: _checklistState(json['checklistState']),
      completedStepsCount: completedCount,
      groups: groups,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
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

class StepAccessInfo {
  final bool canOpen;
  final bool needsQuiz;
  final bool needsRewardAd;
  final bool needsPremium;
  final bool needsGroup;
  final String message;
  final StepVisualState state;

  const StepAccessInfo({
    required this.canOpen,
    required this.needsQuiz,
    required this.needsRewardAd,
    required this.needsPremium,
    required this.needsGroup,
    required this.message,
    required this.state,
  });
}

AccessLevel _parseAccessLevel(dynamic value) {
  switch (_stringValue(value).toUpperCase()) {
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

LearningPlan _parseLearningPlan(dynamic value) {
  switch (_stringValue(value).toUpperCase()) {
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

ProgressStatus _parseProgressStatus(dynamic value) {
  switch (_stringValue(value).toUpperCase()) {
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

StepContentBlockType _parseBlockType(dynamic value) {
  switch (_stringValue(value).toUpperCase()) {
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

List<ChecklistItem> _parseChecklist(dynamic raw) {
  final list = raw as List<dynamic>? ?? const <dynamic>[];
  return list.asMap().entries.map((entry) {
    final item = entry.value;
    if (item is Map<String, dynamic>) {
      return ChecklistItem.fromJson(item);
    }

    return ChecklistItem(
      id: 'check-${entry.key}',
      text: item.toString(),
    );
  }).toList();
}

Map<String, List<String>> _checklistState(dynamic raw) {
  final json = raw as Map<String, dynamic>? ?? const <String, dynamic>{};
  final state = <String, List<String>>{};

  for (final entry in json.entries) {
    state[entry.key] = _stringList(entry.value);
  }

  return state;
}

List<String> _stringList(dynamic raw) {
  final list = raw as List<dynamic>? ?? const <dynamic>[];
  return list.map((item) => _stringValue(item)).where((item) => item.isNotEmpty).toList();
}

String _stringValue(dynamic value, {String fallback = ''}) {
  if (value == null) {
    return fallback;
  }

  final normalized = value.toString().trim();
  return normalized.isEmpty ? fallback : normalized;
}

int _intValue(dynamic value, {int fallback = 0}) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}
