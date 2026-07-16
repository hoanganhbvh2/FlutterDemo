import 'dart:convert';

import 'package:flutter/foundation.dart' hide Category;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/roadmap.dart';
import '../models/sample_data.dart';

class RoadmapProvider extends ChangeNotifier {
  static const _topicsKey = 'kahoa_topics_v5';
  static const _categoriesKey = 'kahoa_categories_v5';
  static const _groupsKey = 'kahoa_groups_v5';
  static const _usersKey = 'kahoa_users_v5';
  static const _sessionKey = 'kahoa_current_user_v5';

  bool _isLoading = true;
  String? _selectedCategoryId;
  List<Category> _categories = [];
  List<LearningGroup> _groups = [];
  List<Topic> _topics = [];
  List<LearningUser> _users = [];
  LearningUser? _currentUser;

  bool get isLoading => _isLoading;
  String? get selectedCategoryId => _selectedCategoryId;
  List<Category> get categories => _categories;
  List<LearningGroup> get groups => _groups;
  List<Topic> get topics => _topics;
  List<LearningUser> get demoUsers => _users;
  LearningUser? get currentUser => _currentUser;

  RoadmapProvider() {
    _init();
  }

  Future<void> _init() async {
    await _loadData();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    _categories = _readList(
      prefs,
      _categoriesKey,
      sampleCategories,
      (json) => Category.fromJson(json),
    );
    _groups = _readList(
      prefs,
      _groupsKey,
      sampleGroups,
      (json) => LearningGroup.fromJson(json),
    );
    _topics = _readList(
      prefs,
      _topicsKey,
      sampleTopics,
      (json) => Topic.fromJson(json),
    );
    _users = _readList(
      prefs,
      _usersKey,
      sampleUsers,
      (json) => LearningUser.fromJson(json),
    );

    final currentUserId = prefs.getString(_sessionKey);
    if (currentUserId != null) {
      _currentUser = _users.where((item) => item.id == currentUserId).firstOrNull;
    }
  }

  List<T> _readList<T>(
    SharedPreferences prefs,
    String key,
    List<T> fallback,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    final raw = prefs.getString(key);
    if (raw == null) {
      prefs.setString(
        key,
        jsonEncode(
          fallback
              .map((item) => (item as dynamic).toJson() as Map<String, dynamic>)
              .toList(),
        ),
      );
      return List<T>.from(fallback);
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => fromJson(item as Map<String, dynamic>))
        .toList();
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
    if (_selectedCategoryId == null) {
      return null;
    }
    return _categories.where((item) => item.id == _selectedCategoryId).firstOrNull;
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

  Future<void> loginAs(String userId) async {
    final user = _users.where((item) => item.id == userId).firstOrNull;
    if (user == null) {
      return;
    }

    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, userId);
    notifyListeners();
  }

  Future<String?> loginWithCredentials({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedPassword = password.trim();

    if (normalizedEmail.isEmpty || normalizedPassword.isEmpty) {
      return 'Enter both email and password.';
    }

    final user = _users.where((item) => item.email.toLowerCase() == normalizedEmail).firstOrNull;
    if (user == null || user.password != normalizedPassword) {
      return 'Incorrect email or password.';
    }

    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, user.id);
    notifyListeners();
    return null;
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    notifyListeners();
  }

  bool get isPremiumUser {
    if (_currentUser == null) {
      return false;
    }
    return _currentUser!.plan == LearningPlan.premium;
  }

  bool userHasGroup(List<String> allowedGroupIds) {
    if (_currentUser == null) {
      return false;
    }
    if (allowedGroupIds.isEmpty) {
      return true;
    }
    return allowedGroupIds.any(_currentUser!.groupIds.contains);
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
    return _currentUser?.completedStepIds.contains(stepId) ?? false;
  }

  bool hasPassedQuiz(String stepId) {
    return _currentUser?.passedQuizStepIds.contains(stepId) ?? false;
  }

  bool hasUnlockedRewardedStep(String stepId) {
    return _currentUser?.unlockedRewardedStepIds.contains(stepId) ?? false;
  }

  List<String> checklistProgressFor(String stepId) {
    return _currentUser?.checklistState[stepId] ?? const [];
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
    final completed = isStepCompleted(step.id);
    final checklistTouched = checklistProgressFor(step.id).isNotEmpty;
    final prerequisiteId = step.prerequisiteStepIds.firstWhere(
      (item) => !isStepCompleted(item),
      orElse: () => '',
    );
    final prerequisiteTitle = lesson.steps
        .where((item) => item.id == prerequisiteId)
        .map((item) => item.title)
        .firstOrNull;

    if (completed) {
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

    if (prerequisiteId.isNotEmpty) {
      return StepAccessInfo(
        canOpen: false,
        needsQuiz: false,
        needsRewardAd: false,
        needsPremium: false,
        needsGroup: false,
        message: 'Finish the previous step first: ${prerequisiteTitle ?? prerequisiteId}',
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

    if (step.accessLevel == AccessLevel.premium && !isPremiumUser) {
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

    if (step.accessLevel == AccessLevel.group && !userHasGroup(step.allowedGroupIds)) {
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

    final quizRequired = step.quiz != null && !hasPassedQuiz(step.id);
    if (quizRequired) {
      return StepAccessInfo(
        canOpen: true,
        needsQuiz: true,
        needsRewardAd: false,
        needsPremium: false,
        needsGroup: false,
        message: 'Read this step first, then return to the lesson to take the quiz.',
        state: checklistTouched
            ? StepVisualState.inProgress
            : StepVisualState.ready,
      );
    }

    if (step.accessLevel == AccessLevel.rewarded &&
        !isPremiumUser &&
        !hasUnlockedRewardedStep(step.id)) {
      return const StepAccessInfo(
        canOpen: true,
        needsQuiz: false,
        needsRewardAd: true,
        needsPremium: false,
        needsGroup: false,
        message: 'After passing the quiz, use a rewarded ad to finish this step.',
        state: StepVisualState.inProgress,
      );
    }

    return StepAccessInfo(
      canOpen: true,
      needsQuiz: false,
      needsRewardAd: false,
      needsPremium: false,
      needsGroup: false,
      message: 'Ready to learn.',
      state: checklistTouched ? StepVisualState.inProgress : StepVisualState.ready,
    );
  }

  Future<bool> submitQuiz({
    required StepNode step,
    required Map<String, int> answers,
  }) async {
    if (_currentUser == null || step.quiz == null) {
      return false;
    }

    final correctCount = step.quiz!.questions.where((question) {
      return answers[question.id] == question.correctIndex;
    }).length;

    if (correctCount < step.quiz!.passThreshold) {
      return false;
    }

    final updatedQuizPasses = {..._currentUser!.passedQuizStepIds, step.id}.toList();
    await _replaceCurrentUser(
      _currentUser!.copyWith(passedQuizStepIds: updatedQuizPasses),
    );
    return true;
  }

  Future<void> unlockRewardedStep(String stepId) async {
    if (_currentUser == null) {
      return;
    }

    final updatedUnlocked = {
      ..._currentUser!.unlockedRewardedStepIds,
      stepId,
    }.toList();

    await _replaceCurrentUser(
      _currentUser!.copyWith(
        unlockedRewardedStepIds: updatedUnlocked,
        adsWatched: _currentUser!.adsWatched + 1,
      ),
    );
  }

  Future<void> toggleChecklist({
    required StepNode step,
    required String itemId,
  }) async {
    if (_currentUser == null) {
      return;
    }

    final nextState = <String, List<String>>{
      ..._currentUser!.checklistState,
    };
    final completedIds = {...(nextState[step.id] ?? const <String>[])};

    if (completedIds.contains(itemId)) {
      completedIds.remove(itemId);
    } else {
      completedIds.add(itemId);
    }

    nextState[step.id] = completedIds.toList();
    await _replaceCurrentUser(_currentUser!.copyWith(checklistState: nextState));
  }

  Future<void> markStepCompleted(StepNode step) async {
    if (_currentUser == null) {
      return;
    }

    final updatedCompleted = {..._currentUser!.completedStepIds, step.id}.toList();
    await _replaceCurrentUser(
      _currentUser!.copyWith(
        completedStepIds: updatedCompleted,
        gems: _currentUser!.gems + step.xpReward,
      ),
    );
  }

  double topicProgress(Topic topic) {
    final allSteps = topic.lessons.expand((item) => item.steps).toList();
    if (allSteps.isEmpty) {
      return 0;
    }
    final completed = allSteps.where((item) => isStepCompleted(item.id)).length;
    return completed / allSteps.length;
  }

  double lessonProgress(Lesson lesson) {
    if (lesson.steps.isEmpty) {
      return 0;
    }
    final completed = lesson.steps.where((item) => isStepCompleted(item.id)).length;
    return completed / lesson.steps.length;
  }

  Map<String, int> get overallStats {
    final visibleTopics = filteredTopics;
    final lessonCount = visibleTopics.fold<int>(
      0,
      (sum, topic) => sum + topic.lessons.length,
    );
    final stepCount = visibleTopics.fold<int>(
      0,
      (sum, topic) => sum + topic.lessons.fold<int>(0, (inner, lesson) => inner + lesson.steps.length),
    );
    final completedCount = visibleTopics.fold<int>(
      0,
      (sum, topic) => sum + topic.lessons.fold<int>(
        0,
        (inner, lesson) => inner + lesson.steps.where((step) => isStepCompleted(step.id)).length,
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

  Future<void> _replaceCurrentUser(LearningUser nextUser) async {
    _currentUser = nextUser;
    _users = _users.map((item) => item.id == nextUser.id ? nextUser : item).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _usersKey,
      jsonEncode(_users.map((item) => item.toJson()).toList()),
    );
    await prefs.setString(_sessionKey, nextUser.id);
    notifyListeners();
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
