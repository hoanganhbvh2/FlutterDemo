import '../core/network/resolve_image_url.dart';
import 'checklist_item.dart';
import 'enums.dart';
import 'model_helpers.dart';
import 'quiz.dart';

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
    final rawMediaUrl =
        parseStringValue(json['mediaUrl'] ?? json['media_url']);
    return StepContentBlock(
      id: parseStringValue(json['id']),
      type: parseBlockType(json['type'] ?? json['block_type']),
      title: parseStringValue(json['title']),
      body: parseStringValue(json['body']),
      items: parseStringList(json['items'] ?? json['items_json']),
      mediaUrl: resolveImageUrl(rawMediaUrl),
      caption: parseStringValue(json['caption']),
      codeLanguage:
          parseStringValue(json['codeLanguage'] ?? json['code_language']),
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

  /// Builds legacy content blocks from flat fields (backwards-compatible).
  static List<StepContentBlock> legacyBlocks({
    required String theory,
    required String note,
    required String codeSnippet,
    required String codeLanguage,
  }) {
    final blocks = <StepContentBlock>[];

    if (theory.trim().isNotEmpty) {
      blocks.add(StepContentBlock(
        id: 'legacy-theory',
        type: StepContentBlockType.paragraph,
        body: theory,
      ));
    }

    if (note.trim().isNotEmpty) {
      blocks.add(StepContentBlock(
        id: 'legacy-note',
        type: StepContentBlockType.callout,
        body: note,
      ));
    }

    if (codeSnippet.trim().isNotEmpty) {
      blocks.add(StepContentBlock(
        id: 'legacy-code',
        type: StepContentBlockType.code,
        body: codeSnippet,
        codeLanguage: codeLanguage,
      ));
    }

    return blocks;
  }
}

class StepNode {
  final String id;
  final String? code;
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
    this.code,
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
    final checklist = parseChecklist(json['checklist']);
    final passThreshold = parseIntValue(json['passThreshold']);
    final quizQuestions =
        ((json['quizQuestions'] ?? json['quiz_questions']) as List<dynamic>? ??
                const <dynamic>[])
            .map((item) =>
                QuizQuestion.fromJson(item as Map<String, dynamic>))
            .toList();

    final rawContentBlocks =
        (json['contentBlocks'] ?? json['content_blocks']) as List<dynamic>? ??
            const <dynamic>[];

    StepQuiz? quiz;
    final quizJson = json['quiz'];
    if (quizJson is Map<String, dynamic>) {
      quiz = StepQuiz.fromJson(quizJson);
    } else if (quizQuestions.isNotEmpty || passThreshold > 0) {
      quiz = StepQuiz(
        passThreshold:
            passThreshold > 0 ? passThreshold : quizQuestions.length,
        questions: quizQuestions,
      );
    }

    return StepNode(
      id: parseStringValue(json['id']),
      code: json['code'] != null ? parseStringValue(json['code']) : null,
      lessonId:
          parseStringValue(json['lessonId'] ?? json['lesson_id']),
      title: parseStringValue(json['title']),
      description:
          parseStringValue(json['description'] ?? json['summary']),
      emoji: parseStringValue(json['emoji'], fallback: 'book'),
      order: parseIntValue(
        json['order'] ?? json['orderIndex'] ?? json['order_index'],
        fallback: 1,
      ),
      accessLevel: parseAccessLevel(
        json['accessLevel'] ?? json['access_level'],
      ),
      allowedGroupIds: parseStringList(
        json['allowedGroupIds'] ?? json['allowed_group_ids'],
      ),
      prerequisiteStepIds: parseStringList(
        json['prerequisiteStepIds'] ?? json['prerequisite_step_ids'],
      ),
      checklist: checklist,
      quiz: quiz,
      note: parseStringValue(json['note']),
      theory: parseStringValue(json['theory']),
      codeSnippet:
          parseStringValue(json['codeSnippet'] ?? json['code_snippet']),
      codeLanguage:
          parseStringValue(json['codeLanguage'] ?? json['code_language']),
      contentBlocks: rawContentBlocks
          .map((item) =>
              StepContentBlock.fromJson(item as Map<String, dynamic>))
          .toList(),
      xpReward: parseIntValue(
        json['xpReward'] ?? json['xp_reward'],
        fallback: 30,
      ),
      estimatedMinutes: parseIntValue(
        json['estimatedMinutes'] ?? json['estimated_minutes'],
        fallback: 10,
      ),
      progressStatus: parseProgressStatus(
        json['progressStatus'] ?? json['progress_status'],
      ),
      completedChecklist: parseStringList(
        json['completedChecklist'] ?? json['completed_checklist'],
      ),
      quizScore:
          parseIntValue(json['quizScore'] ?? json['quiz_score']),
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
    if (contentBlocks.isNotEmpty) return contentBlocks;
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

  bool get hasQuiz =>
      quiz != null && (quiz!.passThreshold > 0 || quiz!.questions.isNotEmpty);

  /// A step with a quiz is considered "passed" when:
  /// 1. The server marked it completed (progressStatus == completed), OR
  /// 2. quizScore (as %) is >= 70 (the server-side threshold).
  bool get hasPassedQuiz =>
      hasQuiz &&
      (progressStatus == ProgressStatus.completed ||
          (quizScore > 0 && quizScore >= 70));

  bool get isCompleted => progressStatus == ProgressStatus.completed;
}
