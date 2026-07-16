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
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      icon: json['icon'] as String? ?? 'school',
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
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? '',
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
    final options = (json['options'] as List<dynamic>? ?? <dynamic>[])
        .map((item) => item.toString())
        .toList();

    return QuizQuestion(
      id: json['id'] as String? ?? '',
      prompt: json['prompt'] as String? ?? '',
      options: options,
      correctIndex: json['correctIndex'] as int? ?? 0,
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
    final questions = (json['questions'] as List<dynamic>? ?? <dynamic>[])
        .map((item) => QuizQuestion.fromJson(item as Map<String, dynamic>))
        .toList();

    return StepQuiz(
      passThreshold: json['passThreshold'] as int? ?? questions.length,
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
    final typeName = json['type'] as String? ?? StepContentBlockType.paragraph.name;
    final type = StepContentBlockType.values.firstWhere(
      (item) => item.name == typeName,
      orElse: () => StepContentBlockType.paragraph,
    );

    return StepContentBlock(
      id: json['id'] as String? ?? '',
      type: type,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      items: (json['items'] as List<dynamic>? ?? <dynamic>[])
          .map((item) => item.toString())
          .toList(),
      mediaUrl: json['mediaUrl'] as String? ?? '',
      caption: json['caption'] as String? ?? '',
      codeLanguage: json['codeLanguage'] as String? ?? '',
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
  });

  factory StepNode.fromJson(Map<String, dynamic> json) {
    final checklistItems = (json['checklist'] as List<dynamic>? ?? <dynamic>[])
        .map((item) => ChecklistItem.fromJson(item as Map<String, dynamic>))
        .toList();

    final groupIds = (json['allowedGroupIds'] as List<dynamic>? ?? <dynamic>[])
        .map((item) => item.toString())
        .toList();

    final prerequisiteIds =
        (json['prerequisiteStepIds'] as List<dynamic>? ?? <dynamic>[])
            .map((item) => item.toString())
            .toList();

    final accessName = json['accessLevel'] as String? ?? AccessLevel.free.name;
    final accessLevel = AccessLevel.values.firstWhere(
      (item) => item.name == accessName,
      orElse: () => AccessLevel.free,
    );

    final quizJson = json['quiz'] as Map<String, dynamic>?;
    final contentBlocks = (json['contentBlocks'] as List<dynamic>? ?? <dynamic>[])
        .map((item) => StepContentBlock.fromJson(item as Map<String, dynamic>))
        .toList();

    return StepNode(
      id: json['id'] as String? ?? '',
      lessonId: json['lessonId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      emoji: json['emoji'] as String? ?? 'book',
      order: json['order'] as int? ?? 1,
      accessLevel: accessLevel,
      allowedGroupIds: groupIds,
      prerequisiteStepIds: prerequisiteIds,
      checklist: checklistItems,
      note: json['note'] as String? ?? '',
      theory: json['theory'] as String? ?? '',
      codeSnippet: json['codeSnippet'] as String? ?? '',
      codeLanguage: json['codeLanguage'] as String? ?? '',
      contentBlocks: contentBlocks,
      xpReward: json['xpReward'] as int? ?? 30,
      estimatedMinutes: json['estimatedMinutes'] as int? ?? 10,
      quiz: quizJson == null ? null : StepQuiz.fromJson(quizJson),
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
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    final accessName = json['accessLevel'] as String? ?? AccessLevel.free.name;
    final accessLevel = AccessLevel.values.firstWhere(
      (item) => item.name == accessName,
      orElse: () => AccessLevel.free,
    );

    final steps = (json['steps'] as List<dynamic>? ?? <dynamic>[])
        .map((item) => StepNode.fromJson(item as Map<String, dynamic>))
        .toList();

    final groupIds = (json['allowedGroupIds'] as List<dynamic>? ?? <dynamic>[])
        .map((item) => item.toString())
        .toList();

    return Lesson(
      id: json['id'] as String? ?? '',
      topicId: json['topicId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      order: json['order'] as int? ?? 1,
      accessLevel: accessLevel,
      allowedGroupIds: groupIds,
      estimatedMinutes: json['estimatedMinutes'] as int? ?? 30,
      steps: steps,
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

  const Topic({
    required this.id,
    required this.tagIds,
    required this.title,
    required this.description,
    required this.emoji,
    required this.levelLabel,
    required this.estimatedHours,
    required this.lessons,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    final lessons = (json['lessons'] as List<dynamic>? ?? <dynamic>[])
        .map((item) => Lesson.fromJson(item as Map<String, dynamic>))
        .toList();
    final tagIds = (json['tagIds'] as List<dynamic>? ?? <dynamic>[])
        .map((item) => item.toString())
        .toList();

    return Topic(
      id: json['id'] as String? ?? '',
      tagIds: tagIds,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      emoji: json['emoji'] as String? ?? 'sparkles',
      levelLabel: json['levelLabel'] as String? ?? 'Beginner',
      estimatedHours: json['estimatedHours'] as int? ?? 6,
      lessons: lessons,
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
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
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
    );
  }

  factory LearningUser.fromJson(Map<String, dynamic> json) {
    final planName = json['plan'] as String? ?? LearningPlan.free.name;
    final plan = LearningPlan.values.firstWhere(
      (item) => item.name == planName,
      orElse: () => LearningPlan.free,
    );

    final groupIds = (json['groupIds'] as List<dynamic>? ?? <dynamic>[])
        .map((item) => item.toString())
        .toList();

    final completed = (json['completedStepIds'] as List<dynamic>? ?? <dynamic>[])
        .map((item) => item.toString())
        .toList();

    final unlocked =
        (json['unlockedRewardedStepIds'] as List<dynamic>? ?? <dynamic>[])
            .map((item) => item.toString())
            .toList();

    final quizPassed = (json['passedQuizStepIds'] as List<dynamic>? ??
            <dynamic>[])
        .map((item) => item.toString())
        .toList();

    final checklistJson =
        json['checklistState'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final checklistState = <String, List<String>>{};

    for (final entry in checklistJson.entries) {
      checklistState[entry.key] = (entry.value as List<dynamic>? ?? <dynamic>[])
          .map((item) => item.toString())
          .toList();
    }

    return LearningUser(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      password: json['password'] as String? ?? '',
      avatar: json['avatar'] as String? ?? 'A',
      plan: plan,
      groupIds: groupIds,
      streakDays: json['streakDays'] as int? ?? 0,
      gems: json['gems'] as int? ?? 0,
      adsWatched: json['adsWatched'] as int? ?? 0,
      completedStepIds: completed,
      unlockedRewardedStepIds: unlocked,
      passedQuizStepIds: quizPassed,
      checklistState: checklistState,
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
