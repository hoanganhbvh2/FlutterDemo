import 'package:flutter/foundation.dart' hide Category;

import '../core/network/api_client.dart';
import '../data/sample_data.dart';
import '../models/roadmap.dart';
import '../providers/auth_provider.dart';
import '../services/roadmap_service.dart';

class RoadmapProvider extends ChangeNotifier {
  RoadmapProvider(this._apiClient) {
    _roadmapService = RoadmapService(_apiClient);
  }

  final ApiClient _apiClient;
  late final RoadmapService _roadmapService;

  AuthProvider? _auth;

  bool _isLoading = false;
  String? _lastSyncError;
  String? _selectedCategoryId;
  List<Category> _categories = [];
  List<LearningGroup> _groups = [];
  List<Topic> _topics = [];
  bool _bootstrapped = false;

  bool get isLoading => _isLoading;
  String? get lastSyncError => _lastSyncError;
  String? get selectedCategoryId => _selectedCategoryId;
  List<Category> get categories => _categories;
  List<LearningGroup> get groups => _groups;
  List<Topic> get topics => _topics;

  RoadmapService get roadmapService => _roadmapService;

  LearningUser? get currentUser => _auth?.currentUser;

  // ── Auth integration────────────────────────────

  void updateAuth(AuthProvider auth) {
    _auth = auth;

    if (!auth.isLoading && !_bootstrapped) {
      _bootstrapped = true;
      _loadData();
    }
  }

  // ── Data loading ──────────────────────────────────────────────────────────

  Future<void> _loadData() async {
    _isLoading = true;
    _lastSyncError = null;
    notifyListeners();

    try {
      await _bootstrapSession();
    } on ApiException catch (error) {
      _lastSyncError = error.message;
      if (_topics.isEmpty) {
        _topics = sampleTopics;
        _categories = sampleCategories;
      }
    } catch (_) {
      _lastSyncError = 'Unable to load roadmap data from the backend.';
      if (_topics.isEmpty) {
        _topics = sampleTopics;
        _categories = sampleCategories;
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _bootstrapSession() async {
    _lastSyncError = null;

    final topicSummaries = await _roadmapService.getTopics();
    final topicDetails = <Topic>[];
    for (final topic in topicSummaries) {
      topicDetails.add(await _roadmapService.getTopicDetail(topic.id));
    }
    _topics = topicDetails;

    try {
      final fetchedCategories = await _roadmapService.getCategories();
      _categories = fetchedCategories.isNotEmpty
          ? fetchedCategories
          : _buildCategories(topicDetails);
    } catch (_) {
      _categories = _buildCategories(topicDetails);
    }

    _groups = _auth?.currentUser?.groups ?? const [];
  }

  Future<void> refreshData() async {
    try {
      await _auth?.refreshUser();
      await _bootstrapSession();
    } on ApiException catch (error) {
      _lastSyncError = error.message;
    } catch (_) {
      _lastSyncError = 'Unable to refresh roadmap data right now.';
    }
    notifyListeners();
  }

  Future<void> fetchTopicDetail(String topicId) async {
    try {
      final detail = await _roadmapService.getTopicDetail(topicId);
      final index = _topics.indexWhere((t) => t.id == topicId);
      if (index != -1) {
        _topics[index] = detail;
      } else {
        _topics.add(detail);
      }
      _categories = _buildCategories(_topics);
      _lastSyncError = null;
      notifyListeners();
    } on ApiException catch (error) {
      _lastSyncError = error.message;
      notifyListeners();
    } catch (_) {
      _lastSyncError = 'Unable to load this topic right now.';
      notifyListeners();
    }
  }

  // ── Search & Filter ───────────────────────────────────────────────────────

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  List<Topic> get filteredTopics {
    var result = _topics;

    if (_selectedCategoryId != null) {
      result = result
          .where((item) => item.categoryIds.contains(_selectedCategoryId))
          .toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      final isHashTagSearch = q.startsWith('#');
      final cleanTagQuery = isHashTagSearch ? q.substring(1).trim() : q;

      result = result.where((topic) {
        final matchesTag = topic.tagDetails.any((t) {
          final tTitle = t.title.toLowerCase();
          return tTitle.contains(cleanTagQuery);
        });

        if (isHashTagSearch) return matchesTag;

        final matchesTitle = topic.title.toLowerCase().contains(q);
        final matchesDesc = topic.description.toLowerCase().contains(q);
        final matchesLesson = topic.lessons.any((l) {
          final codeMatch = l.code?.toLowerCase().contains(q) ?? false;
          final titleMatch = l.title.toLowerCase().contains(q);
          return codeMatch || titleMatch;
        });

        return matchesTitle || matchesDesc || matchesTag || matchesLesson;
      }).toList();
    }

    return result;
  }

  int _displayLimit = 10;
  int get displayLimit => _displayLimit;

  List<Topic> get visibleTopics {
    final all = filteredTopics;
    if (all.length <= _displayLimit) return all;
    return all.sublist(0, _displayLimit);
  }

  bool get hasMoreTopics => filteredTopics.length > _displayLimit;

  void loadNextPage() {
    if (hasMoreTopics) {
      _displayLimit += 10;
      notifyListeners();
    }
  }

  Category? get selectedCategory {
    final selectedId = _selectedCategoryId;
    if (selectedId == null) return null;
    return _categories.where((item) => item.id == selectedId).firstOrNull;
  }

  void setCategoryFilter(String? categoryId) {
    _selectedCategoryId = categoryId;
    _displayLimit = 10;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _displayLimit = 10;
    notifyListeners();
  }

  // ── Lookup helpers ────────────────────────────────────────────────────────

  Topic? topicById(String topicId) =>
      _topics.where((item) => item.id == topicId).firstOrNull;

  Lesson? lessonById(String topicId, String lessonId) {
    final topic = topicById(topicId);
    return topic?.lessons.where((item) => item.id == lessonId).firstOrNull;
  }

  StepNode? stepById(String topicId, String lessonId, String stepId) {
    final lesson = lessonById(topicId, lessonId);
    return lesson?.steps.where((item) => item.id == stepId).firstOrNull;
  }

  // ── Step progress ─────────────────────────────────────────────────────────

  Future<StepNode?> loadStepDetail(String stepId) async {
    try {
      final detail = await _roadmapService.getStepDetail(stepId);
      final merged = _mergeStep(detail);
      notifyListeners();
      return merged ?? _findStep(stepId);
    } catch (_) {
      return _findStep(stepId);
    }
  }

  // ── Access control ────────────────────────────────────────────────────────

  bool get isPremiumUser {
    final plan = _auth?.currentUser?.plan;
    return plan == LearningPlan.premium || plan == LearningPlan.groupPro;
  }

  bool userHasGroup(List<String> allowedGroupIds) {
    final user = _auth?.currentUser;
    if (user == null) return false;
    if (allowedGroupIds.isEmpty) return user.plan == LearningPlan.groupPro;
    return allowedGroupIds.any(user.groupIds.contains);
  }

  bool canAccessLesson(Lesson lesson) {
    switch (lesson.accessLevel) {
      case AccessLevel.free:
      case AccessLevel.rewarded:
        return true;
      case AccessLevel.premium:
        return isPremiumUser;
      case AccessLevel.group:
        return userHasGroup(lesson.allowedGroupIds);
    }
  }

  bool isStepCompleted(String stepId) {
    final step = _findStep(stepId);
    if (step != null && step.isCompleted) return true;
    final user = _auth?.currentUser;
    if (user != null && user.completedStepIds.contains(stepId)) return true;
    return false;
  }

  bool hasPassedQuiz(String stepId) =>
      _findStep(stepId)?.hasPassedQuiz ?? false;

  List<String> checklistProgressFor(String stepId) =>
      _findStep(stepId)?.completedChecklist ?? const [];

  bool isChecklistComplete(StepNode step) {
    if (step.checklist.isEmpty) return true;
    final completedIds = checklistProgressFor(step.id).toSet();
    return step.checklist.every((item) => completedIds.contains(item.id));
  }

  StepAccessInfo stepAccessInfo({
    required Lesson lesson,
    required StepNode step,
  }) {
    final current = _findStep(step.id) ?? step;
    final checklistTouched = checklistProgressFor(current.id).isNotEmpty;

    if (!canAccessLesson(lesson)) {
      final needsPremium = lesson.accessLevel == AccessLevel.premium;
      return StepAccessInfo(
        canOpen: false,
        needsQuiz: false,
        needsRewardAd: false,
        needsPremium: needsPremium,
        needsGroup: !needsPremium,
        message: needsPremium
            ? 'This blog is available to premium accounts only.'
            : 'This blog is restricted to a private group.',
        state: StepVisualState.locked,
      );
    }

    if (current.accessLevel == AccessLevel.premium && !isPremiumUser) {
      return const StepAccessInfo(
        canOpen: false,
        needsQuiz: false,
        needsRewardAd: false,
        needsPremium: true,
        needsGroup: false,
        message: 'Upgrade to premium to open this step.',
        state: StepVisualState.locked,
      );
    }

    if (current.accessLevel == AccessLevel.group &&
        !userHasGroup(current.allowedGroupIds)) {
      return const StepAccessInfo(
        canOpen: false,
        needsQuiz: false,
        needsRewardAd: false,
        needsPremium: false,
        needsGroup: true,
        message: 'This step belongs to a private group program.',
        state: StepVisualState.locked,
      );
    }

    if (isStepCompleted(current.id)) {
      return const StepAccessInfo(
        canOpen: true,
        needsQuiz: false,
        needsRewardAd: false,
        needsPremium: false,
        needsGroup: false,
        message: 'Completed. You can revisit this step anytime.',
        state: StepVisualState.completed,
      );
    }

    final prerequisiteId = current.prerequisiteStepIds.firstWhere(
      (item) => !isStepCompleted(item),
      orElse: () => '',
    );
    if (prerequisiteId.isNotEmpty) {
      final prerequisiteTitle =
          _findStep(prerequisiteId)?.title ?? prerequisiteId;
      return StepAccessInfo(
        canOpen: false,
        needsQuiz: false,
        needsRewardAd: false,
        needsPremium: false,
        needsGroup: false,
        message: 'Finish the previous step first: $prerequisiteTitle',
        state: StepVisualState.locked,
      );
    }

    if (current.progressStatus == ProgressStatus.locked) {
      return const StepAccessInfo(
        canOpen: false,
        needsQuiz: false,
        needsRewardAd: false,
        needsPremium: false,
        needsGroup: false,
        message: 'This step is still locked.',
        state: StepVisualState.locked,
      );
    }

    if (current.hasQuiz && !current.hasPassedQuiz) {
      return StepAccessInfo(
        canOpen: true,
        needsQuiz: true,
        needsRewardAd: false,
        needsPremium: false,
        needsGroup: false,
        message:
            'Read this step first, then return to the lesson to take the quiz.',
        state: checklistTouched
            ? StepVisualState.inProgress
            : StepVisualState.ready,
      );
    }

    return StepAccessInfo(
      canOpen: true,
      needsQuiz: false,
      needsRewardAd: false,
      needsPremium: false,
      needsGroup: false,
      message: checklistTouched ? 'In progress.' : 'Ready to learn.',
      state: checklistTouched
          ? StepVisualState.inProgress
          : StepVisualState.ready,
    );
  }

  Future<bool> submitQuiz({
    required StepNode step,
    required Map<String, int> answers,
  }) async {
    final current = _findStep(step.id) ?? step;
    final quiz = current.quiz;
    if (quiz == null || quiz.questions.isEmpty) return false;

    final selectedAnswers = quiz.questions.asMap().entries.map((entry) {
      final question = entry.value;
      return answers[question.id] ??
          answers['q-${entry.key}'] ??
          answers['${entry.key}'] ??
          -1;
    }).toList();
    final wasCompleted = current.isCompleted;

    try {
      final response = await _roadmapService.submitQuiz(
        stepId: current.id,
        selectedAnswers: selectedAnswers,
      );

      final passed =
          response['passed'] == true || response['hasPassedQuiz'] == true;
      final serverStatus = _progressStatusFromValue(response['progressStatus']);
      final finalStatus = passed ? ProgressStatus.completed : serverStatus;

      _applyProgressUpdate(
        stepId: current.id,
        progressStatus: finalStatus,
        completedChecklist: _extractStringList(response['completedChecklist']),
        quizScore: _extractInt(response['quizScore']),
      );
    } catch (_) {
      return false;
    }

    final refreshed = _findStep(current.id) ?? current;
    if (!wasCompleted && refreshed.isCompleted) {
      await _applyCompletionForUser(refreshed);
    }

    return refreshed.hasPassedQuiz;
  }

  Future<void> toggleChecklist({
    required StepNode step,
    required String itemId,
  }) async {
    final current = _findStep(step.id) ?? step;
    final previousStatus = current.progressStatus;
    final previousChecklist = current.completedChecklist;
    final previousQuizScore = current.quizScore;

    final completedIds = {...current.completedChecklist};
    if (completedIds.contains(itemId)) {
      completedIds.remove(itemId);
    } else {
      completedIds.add(itemId);
    }

    final nextChecklist = completedIds.toList();
    final nextStatus = current.isCompleted
        ? 'COMPLETED'
        : nextChecklist.isEmpty
        ? 'NOT_STARTED'
        : current.hasQuiz
        ? 'IN_PROGRESS'
        : isChecklistComplete(
            current.copyWith(completedChecklist: nextChecklist),
          )
        ? 'COMPLETED'
        : 'IN_PROGRESS';

    _applyProgressUpdate(
      stepId: current.id,
      progressStatus: _progressStatusFromValue(nextStatus),
      completedChecklist: nextChecklist,
      quizScore: current.quizScore,
    );

    final wasCompleted = current.isCompleted;
    try {
      final response = await _roadmapService.updateStepProgress(
        stepId: current.id,
        completedChecklist: nextChecklist,
        status: nextStatus,
      );

      _applyProgressUpdate(
        stepId: current.id,
        progressStatus: _progressStatusFromValue(response['progressStatus']),
        completedChecklist: _extractStringList(response['completedChecklist']),
        quizScore: _extractInt(response['quizScore']),
      );
    } catch (_) {
      _applyProgressUpdate(
        stepId: current.id,
        progressStatus: previousStatus,
        completedChecklist: previousChecklist,
        quizScore: previousQuizScore,
      );
      return;
    }

    final refreshed = _findStep(current.id) ?? current;
    if (!wasCompleted && refreshed.isCompleted) {
      await _applyCompletionForUser(refreshed);
    }
  }

  Future<void> markStepCompleted(StepNode step) async {
    final current = _findStep(step.id) ?? step;
    if (current.isCompleted) return;

    final previousStatus = current.progressStatus;
    final previousChecklist = current.completedChecklist;
    final previousQuizScore = current.quizScore;

    _applyProgressUpdate(
      stepId: current.id,
      progressStatus: ProgressStatus.completed,
      completedChecklist: current.completedChecklist,
      quizScore: current.quizScore,
    );

    try {
      final response = await _roadmapService.updateStepProgress(
        stepId: current.id,
        completedChecklist: current.completedChecklist,
        status: 'COMPLETED',
      );

      _applyProgressUpdate(
        stepId: current.id,
        progressStatus: _progressStatusFromValue(response['progressStatus']),
        completedChecklist: _extractStringList(response['completedChecklist']),
        quizScore: _extractInt(response['quizScore']),
      );
    } catch (_) {
      _applyProgressUpdate(
        stepId: current.id,
        progressStatus: previousStatus,
        completedChecklist: previousChecklist,
        quizScore: previousQuizScore,
      );
      return;
    }

    final refreshed = _findStep(current.id) ?? current;
    if (refreshed.isCompleted) {
      await _applyCompletionForUser(refreshed);
    }
  }

  // ── Progress & stats ───────────────────────────────────────────────────────

  double topicProgress(Topic topic) {
    final liveTopic = topicById(topic.id) ?? topic;
    final allSteps = liveTopic.lessons.expand((item) => item.steps).toList();
    if (allSteps.isEmpty) return 0;
    final completed = allSteps.where((item) => item.isCompleted).length;
    return completed / allSteps.length;
  }

  double lessonProgress(Lesson lesson) {
    final liveLesson = lessonById(lesson.topicId, lesson.id) ?? lesson;
    if (liveLesson.steps.isEmpty) return 0;
    final completed = liveLesson.steps.where((item) => item.isCompleted).length;
    return completed / liveLesson.steps.length;
  }

  Map<String, int> get overallStats {
    final visibleTopics = filteredTopics;
    final lessonCount = visibleTopics.fold<int>(
      0,
      (sum, topic) => sum + topic.lessons.length,
    );
    final stepCount = visibleTopics.fold<int>(
      0,
      (sum, topic) =>
          sum +
          topic.lessons.fold<int>(
            0,
            (inner, lesson) => inner + lesson.steps.length,
          ),
    );
    final completedCount = visibleTopics.fold<int>(
      0,
      (sum, topic) =>
          sum +
          topic.lessons.fold<int>(
            0,
            (inner, lesson) =>
                inner + lesson.steps.where((step) => step.isCompleted).length,
          ),
    );

    final percent = stepCount == 0
        ? 0
        : ((completedCount / stepCount) * 100).round();

    return {
      'topics': visibleTopics.length,
      'lessons': lessonCount,
      'steps': stepCount,
      'completed': completedCount,
      'percent': percent,
    };
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  Future<void> _applyCompletionForUser(StepNode step) async {
    final auth = _auth;
    final user = auth?.currentUser;
    if (user == null) return;
    if (user.completedStepIds.contains(step.id)) return;

    final updatedUser = user.copyWith(
      completedStepIds: [...user.completedStepIds, step.id],
      completedStepsCount: user.completedStepsCount + 1,
      gems: user.gems + step.xpReward,
      passedQuizStepIds: step.hasPassedQuiz
          ? {...user.passedQuizStepIds, step.id}.toList()
          : user.passedQuizStepIds,
    );
    _groups = updatedUser.groups;
    auth!.updateUser(updatedUser);
    notifyListeners();
  }

  List<Category> _buildCategories(List<Topic> topics) {
    final categoriesById = <String, Category>{};
    for (final topic in topics) {
      for (final cat in topic.categoryDetails) {
        categoriesById[cat.id] = cat;
      }
    }
    return categoriesById.values.toList()
      ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
  }

  StepNode? _mergeStep(StepNode incoming) {
    StepNode? mergedStep;

    _topics = _topics.map((topic) {
      bool topicHasStep = false;
      final lessons = topic.lessons.map((lesson) {
        bool lessonHasStep = false;
        final steps = lesson.steps.map((step) {
          if (step.id != incoming.id) return step;

          topicHasStep = true;
          lessonHasStep = true;
          mergedStep = step.copyWith(
            title: incoming.title.isNotEmpty ? incoming.title : step.title,
            description: incoming.description.isNotEmpty
                ? incoming.description
                : step.description,
            accessLevel: incoming.accessLevel,
            allowedGroupIds: incoming.allowedGroupIds,
            prerequisiteStepIds: incoming.prerequisiteStepIds,
            checklist: incoming.checklist.isNotEmpty
                ? incoming.checklist
                : step.checklist,
            quiz: incoming.quiz ?? step.quiz,
            note: incoming.note.isNotEmpty ? incoming.note : step.note,
            theory: incoming.theory.isNotEmpty ? incoming.theory : step.theory,
            codeSnippet: incoming.codeSnippet.isNotEmpty
                ? incoming.codeSnippet
                : step.codeSnippet,
            codeLanguage: incoming.codeLanguage.isNotEmpty
                ? incoming.codeLanguage
                : step.codeLanguage,
            contentBlocks: incoming.contentBlocks.isNotEmpty
                ? incoming.contentBlocks
                : step.contentBlocks,
            xpReward: incoming.xpReward,
            estimatedMinutes: incoming.estimatedMinutes,
            progressStatus: incoming.progressStatus,
            completedChecklist: incoming.completedChecklist,
            quizScore: incoming.quizScore,
          );
          return mergedStep!;
        }).toList();

        if (!lessonHasStep) return lesson;

        final doneCount = steps.where((s) => s.isCompleted).length;
        return lesson.copyWith(
          steps: steps,
          completedStepsCount: doneCount,
          totalStepsCount: steps.length,
        );
      }).toList();

      if (!topicHasStep) return topic;

      final allSteps = lessons.expand((item) => item.steps).toList();
      final doneTotalCount = allSteps.where((s) => s.isCompleted).length;
      return topic.copyWith(
        lessons: lessons,
        completedStepsCount: doneTotalCount,
        totalStepsCount: allSteps.length,
        progressPercent: allSteps.isEmpty
            ? 0
            : ((doneTotalCount / allSteps.length) * 100).round(),
      );
    }).toList();

    return mergedStep ?? _findStep(incoming.id);
  }

  void _applyProgressUpdate({
    required String stepId,
    required ProgressStatus progressStatus,
    required List<String> completedChecklist,
    required int quizScore,
  }) {
    final current = _findStep(stepId);
    if (current == null) return;

    final updatedStep = current.copyWith(
      progressStatus: progressStatus,
      completedChecklist: completedChecklist,
      quizScore: quizScore,
    );

    _mergeStep(updatedStep);
    notifyListeners();
  }

  StepNode? _findStep(String stepId) {
    for (final topic in _topics) {
      for (final lesson in topic.lessons) {
        for (final step in lesson.steps) {
          if (step.id == stepId) return step;
        }
      }
    }
    return null;
  }
}

// ── Module-level utilities ─────────────────────────────────────────────────

int _extractInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

List<String> _extractStringList(dynamic value) {
  final list = value as List<dynamic>? ?? const <dynamic>[];
  return list.map((item) => item.toString()).toList();
}

ProgressStatus _progressStatusFromValue(dynamic value) {
  switch (value?.toString().toUpperCase()) {
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

extension _IterableFirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull {
    if (isEmpty) return null;
    return first;
  }
}
