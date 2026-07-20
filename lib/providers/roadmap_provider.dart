import 'dart:convert';

import 'package:flutter/foundation.dart' hide Category;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/roadmap.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/roadmap_service.dart';

class RoadmapProvider extends ChangeNotifier {
  static const _tokenKey = 'kahoa_auth_token_v1';
  static const _sessionKey = 'kahoa_current_user_v1';

  RoadmapProvider()
      : _apiClient = ApiClient() {
    _authService = AuthService(_apiClient);
    _roadmapService = RoadmapService(_apiClient);
    _init();
  }

  final ApiClient _apiClient;
  late AuthService _authService;
  late RoadmapService _roadmapService;

  bool _isLoading = true;
  String? _selectedCategoryId;
  List<Category> _categories = [];
  List<LearningGroup> _groups = [];
  List<Topic> _topics = [];
  LearningUser? _currentUser;

  bool get isLoading => _isLoading;
  String? get selectedCategoryId => _selectedCategoryId;
  List<Category> get categories => _categories;
  List<LearningGroup> get groups => _groups;
  List<Topic> get topics => _topics;
  LearningUser? get currentUser => _currentUser;

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final rawUser = prefs.getString(_sessionKey);

    if (token != null && rawUser != null) {
      _apiClient.authToken = token;
      _currentUser = LearningUser.fromJson(
        jsonDecode(rawUser) as Map<String, dynamic>,
      );

      try {
        await _bootstrapSession(refreshUser: true);
      } catch (_) {
        await _clearSession();
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _bootstrapSession({bool refreshUser = false}) async {
    final user = _currentUser;
    if (user == null) {
      _topics = [];
      _categories = [];
      _groups = [];
      return;
    }

    if (refreshUser) {
      _currentUser = await _authService.getUserById(user.id);
    }

    final topicSummaries = await _roadmapService.getTopics();
    final topicDetails = <Topic>[];

    for (final topic in topicSummaries) {
      topicDetails.add(await _roadmapService.getTopicDetail(topic.id));
    }

    _topics = topicDetails;
    _categories = _buildCategories(topicDetails);
    _groups = _currentUser?.groups ?? const [];
    await _persistSession();
  }

  Future<void> refreshData() async {
    try {
      await _bootstrapSession(refreshUser: true);
    } catch (_) {}
    notifyListeners();
  }

  Future<void> _persistSession() async {
    final prefs = await SharedPreferences.getInstance();
    if (_apiClient.authToken != null) {
      await prefs.setString(_tokenKey, _apiClient.authToken!);
    }
    if (_currentUser != null) {
      await prefs.setString(_sessionKey, jsonEncode(_currentUser!.toJson()));
    }
  }

  Future<void> _clearSession() async {
    _apiClient.authToken = null;
    _currentUser = null;
    _topics = [];
    _categories = [];
    _groups = [];
    _selectedCategoryId = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_sessionKey);
  }

  List<Topic> get filteredTopics {
    if (_selectedCategoryId == null) {
      return _topics;
    }

    return _topics
        .where((item) => item.tagIds.contains(_selectedCategoryId))
        .toList();
  }

  Category? get selectedCategory {
    final selectedId = _selectedCategoryId;
    if (selectedId == null) {
      return null;
    }

    return _categories.where((item) => item.id == selectedId).firstOrNull;
  }

  void setCategoryFilter(String? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  Topic? topicById(String topicId) {
    return _topics.where((item) => item.id == topicId).firstOrNull;
  }

  Lesson? lessonById(String topicId, String lessonId) {
    final topic = topicById(topicId);
    return topic?.lessons.where((item) => item.id == lessonId).firstOrNull;
  }

  StepNode? stepById(String topicId, String lessonId, String stepId) {
    final lesson = lessonById(topicId, lessonId);
    return lesson?.steps.where((item) => item.id == stepId).firstOrNull;
  }

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

  Future<String?> loginWithCredentials({
    required String email,
    required String password,
  }) async {
    final identifier = email.trim();
    final normalizedPassword = password.trim();

    if (identifier.isEmpty || normalizedPassword.isEmpty) {
      return 'Enter both username/email and password.';
    }

    try {
      final session = await _authService.login(
        identifier: identifier,
        password: normalizedPassword,
      );

      _apiClient.authToken = session.token;
      _currentUser = session.user;
      _groups = session.user.groups;
      await _bootstrapSession(refreshUser: true);
      notifyListeners();
      return null;
    } on ApiException catch (error) {
      await _clearSession();
      notifyListeners();
      return error.message;
    } catch (_) {
      await _clearSession();
      notifyListeners();
      return 'Unable to sign in right now. Please try again.';
    }
  }

  Future<String?> registerAccount({
    required String username,
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final session = await _authService.register(
        username: username,
        email: email,
        password: password,
        fullName: fullName,
      );

      _apiClient.authToken = session.token;
      _currentUser = session.user;
      _groups = session.user.groups;
      await _bootstrapSession(refreshUser: true);
      notifyListeners();
      return null;
    } on ApiException catch (error) {
      await _clearSession();
      notifyListeners();
      return error.message;
    } catch (_) {
      await _clearSession();
      notifyListeners();
      return 'Unable to register right now. Please try again.';
    }
  }

  Future<void> logout() async {
    await _clearSession();
    notifyListeners();
  }

  bool get isPremiumUser {
    final plan = _currentUser?.plan;
    return plan == LearningPlan.premium || plan == LearningPlan.groupPro;
  }

  bool userHasGroup(List<String> allowedGroupIds) {
    final user = _currentUser;
    if (user == null) {
      return false;
    }
    if (allowedGroupIds.isEmpty) {
      return user.plan == LearningPlan.groupPro;
    }
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
    if (step != null && step.isCompleted) {
      return true;
    }
    final user = _currentUser;
    if (user != null && user.completedStepIds.contains(stepId)) {
      return true;
    }
    return false;
  }

  bool hasPassedQuiz(String stepId) {
    return _findStep(stepId)?.hasPassedQuiz ?? false;
  }

  List<String> checklistProgressFor(String stepId) {
    return _findStep(stepId)?.completedChecklist ?? const [];
  }

  bool isChecklistComplete(StepNode step) {
    if (step.checklist.isEmpty) {
      return true;
    }
    final completedIds = checklistProgressFor(step.id).toSet();
    return step.checklist.every((item) => completedIds.contains(item.id));
  }

  StepAccessInfo stepAccessInfo({
    required Lesson lesson,
    required StepNode step,
  }) {
    final current = _findStep(step.id) ?? step;
    final checklistTouched = checklistProgressFor(current.id).isNotEmpty;

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
      final prerequisiteTitle = _findStep(prerequisiteId)?.title ?? prerequisiteId;
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
        message: 'Read this step first, then return to the lesson to take the quiz.',
        state: checklistTouched ? StepVisualState.inProgress : StepVisualState.ready,
      );
    }

    return StepAccessInfo(
      canOpen: true,
      needsQuiz: false,
      needsRewardAd: false,
      needsPremium: false,
      needsGroup: false,
      message: checklistTouched ? 'In progress.' : 'Ready to learn.',
      state: checklistTouched ? StepVisualState.inProgress : StepVisualState.ready,
    );
  }

  Future<bool> submitQuiz({
    required StepNode step,
    required Map<String, int> answers,
  }) async {
    final current = _findStep(step.id) ?? step;
    final quiz = current.quiz;
    if (quiz == null || quiz.questions.isEmpty) {
      return false;
    }

    final selectedAnswers = quiz.questions.asMap().entries.map((entry) {
      final question = entry.value;
      return answers[question.id] ?? answers['q-${entry.key}'] ?? answers['${entry.key}'] ?? -1;
    }).toList();
    final wasCompleted = current.isCompleted;

    int correctCount = 0;
    for (int i = 0; i < quiz.questions.length; i++) {
      if (selectedAnswers[i] == quiz.questions[i].correctIndex) {
        correctCount++;
      }
    }
    final effectiveThreshold = quiz.questions.isEmpty
        ? 0
        : (quiz.passThreshold > quiz.questions.length
            ? quiz.questions.length
            : quiz.passThreshold);
    final isPass = quiz.questions.isEmpty || correctCount >= effectiveThreshold;

    if (_currentUser != null) {
      try {
        final response = await _roadmapService.submitQuiz(
          stepId: current.id,
          selectedAnswers: selectedAnswers,
        );

        final serverStatus = _progressStatusFromValue(response['progressStatus']);
        final finalStatus = (isPass || serverStatus == ProgressStatus.completed)
            ? ProgressStatus.completed
            : serverStatus;

        _applyProgressUpdate(
          stepId: current.id,
          progressStatus: finalStatus,
          completedChecklist: _extractStringList(response['completedChecklist']),
          quizScore: _extractInt(response['quizScore']),
        );
      } catch (_) {
        _applyProgressUpdate(
          stepId: current.id,
          progressStatus: isPass ? ProgressStatus.completed : ProgressStatus.inProgress,
          completedChecklist: current.completedChecklist,
          quizScore: correctCount,
        );
      }
    } else {
      _applyProgressUpdate(
        stepId: current.id,
        progressStatus: isPass ? ProgressStatus.completed : ProgressStatus.inProgress,
        completedChecklist: current.completedChecklist,
        quizScore: correctCount,
      );
    }

    final refreshed = _findStep(current.id) ?? current;
    if (!wasCompleted && refreshed.isCompleted) {
      await _applyCompletionForUser(refreshed);
    }

    return refreshed.hasPassedQuiz || isPass;
  }

  Future<void> toggleChecklist({
    required StepNode step,
    required String itemId,
  }) async {
    final current = _findStep(step.id) ?? step;

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

    // Optimistically update local state & notify screen listeners instantly
    _applyProgressUpdate(
      stepId: current.id,
      progressStatus: _progressStatusFromValue(nextStatus),
      completedChecklist: nextChecklist,
      quizScore: current.quizScore,
    );

    final wasCompleted = current.isCompleted;
    if (_currentUser != null) {
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
      } catch (_) {}
    }

    final refreshed = _findStep(current.id) ?? current;
    if (!wasCompleted && refreshed.isCompleted) {
      await _applyCompletionForUser(refreshed);
    }
  }

  Future<void> markStepCompleted(StepNode step) async {
    final current = _findStep(step.id) ?? step;
    if (current.isCompleted) {
      return;
    }

    // Optimistically mark completed locally
    _applyProgressUpdate(
      stepId: current.id,
      progressStatus: ProgressStatus.completed,
      completedChecklist: current.completedChecklist,
      quizScore: current.quizScore,
    );

    if (_currentUser != null) {
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
      } catch (_) {}
    }

    final refreshed = _findStep(current.id) ?? current;
    if (refreshed.isCompleted) {
      await _applyCompletionForUser(refreshed);
    }
  }

  double topicProgress(Topic topic) {
    final liveTopic = topicById(topic.id) ?? topic;
    final allSteps = liveTopic.lessons.expand((item) => item.steps).toList();
    if (allSteps.isEmpty) {
      return 0;
    }
    final completed = allSteps.where((item) => item.isCompleted).length;
    return completed / allSteps.length;
  }

  double lessonProgress(Lesson lesson) {
    final liveLesson = lessonById(lesson.topicId, lesson.id) ?? lesson;
    if (liveLesson.steps.isEmpty) {
      return 0;
    }
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
          sum + topic.lessons.fold<int>(0, (inner, lesson) => inner + lesson.steps.length),
    );
    final completedCount = visibleTopics.fold<int>(
      0,
      (sum, topic) => sum + topic.lessons.fold<int>(
        0,
        (inner, lesson) => inner + lesson.steps.where((step) => step.isCompleted).length,
      ),
    );

    final percent = stepCount == 0 ? 0 : ((completedCount / stepCount) * 100).round();

    return {
      'topics': visibleTopics.length,
      'lessons': lessonCount,
      'steps': stepCount,
      'completed': completedCount,
      'percent': percent,
    };
  }

  Future<void> _applyCompletionForUser(StepNode step) async {
    final user = _currentUser;
    if (user == null) {
      return;
    }

    if (user.completedStepIds.contains(step.id)) {
      return;
    }

    _currentUser = user.copyWith(
      completedStepIds: [...user.completedStepIds, step.id],
      completedStepsCount: user.completedStepsCount + 1,
      gems: user.gems + step.xpReward,
      passedQuizStepIds: step.hasPassedQuiz
          ? {...user.passedQuizStepIds, step.id}.toList()
          : user.passedQuizStepIds,
    );
    _groups = _currentUser?.groups ?? const [];
    await _persistSession();
    notifyListeners();
  }

  List<Category> _buildCategories(List<Topic> topics) {
    final tagsById = <String, Category>{};

    for (final topic in topics) {
      for (final tag in topic.tagDetails) {
        tagsById[tag.id] = tag;
      }
    }

    final tags = tagsById.values.toList()
      ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    return tags;
  }

  StepNode? _mergeStep(StepNode incoming) {
    StepNode? mergedStep;

    _topics = _topics
        .map((topic) {
          bool topicHasStep = false;
          final lessons = topic.lessons.map((lesson) {
            bool lessonHasStep = false;
            final steps = lesson.steps.map((step) {
              if (step.id != incoming.id) {
                return step;
              }

              topicHasStep = true;
              lessonHasStep = true;
              mergedStep = step.copyWith(
                title: incoming.title.isNotEmpty ? incoming.title : step.title,
                description: incoming.description.isNotEmpty ? incoming.description : step.description,
                accessLevel: incoming.accessLevel,
                allowedGroupIds: incoming.allowedGroupIds,
                prerequisiteStepIds: incoming.prerequisiteStepIds,
                checklist: incoming.checklist.isNotEmpty ? incoming.checklist : step.checklist,
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

            if (!lessonHasStep) {
              return lesson;
            }

            return lesson.copyWith(
              steps: steps,
              completedStepsCount: steps.where((item) => isStepCompleted(item.id)).length,
              totalStepsCount: steps.length,
            );
          }).toList();

          if (!topicHasStep) {
            return topic;
          }

          final allSteps = lessons.expand((item) => item.steps).toList();
          return topic.copyWith(
            lessons: lessons,
            completedStepsCount: allSteps.where((item) => isStepCompleted(item.id)).length,
            totalStepsCount: allSteps.length,
            progressPercent: allSteps.isEmpty
                ? 0
                : ((allSteps.where((item) => isStepCompleted(item.id)).length / allSteps.length) * 100)
                    .round(),
          );
        })
        .toList();

    return mergedStep ?? _findStep(incoming.id);
  }

  void _applyProgressUpdate({
    required String stepId,
    required ProgressStatus progressStatus,
    required List<String> completedChecklist,
    required int quizScore,
  }) {
    final current = _findStep(stepId);
    if (current == null) {
      return;
    }

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
          if (step.id == stepId) {
            return step;
          }
        }
      }
    }
    return null;
  }
}

int _extractInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
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
    if (isEmpty) {
      return null;
    }
    return first;
  }
}
