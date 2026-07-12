import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/roadmap.dart';
import '../models/sample_data.dart';

class RoadmapProvider with ChangeNotifier {
  static const String _storageKey = 'roadmap_platform_topics_v1';
  static const String _classesKey = 'roadmap_platform_classes_v1';
  static const String _studentsKey = 'roadmap_platform_students_v1';
  static const String _sessionKey = 'roadmap_platform_session_student_v1';

  List<Topic> _topics = [];
  bool _isLoading = true;

  // Classrooms and Students state
  List<ClassGroup> _classes = [];
  List<Student> _students = [];
  Student? _currentStudent;

  // Navigation & selection states
  Topic? _selectedTopic;
  Lesson? _selectedLesson;
  StepNode? _selectedStep;

  List<Topic> get topics => _topics;
  bool get isLoading => _isLoading;
  Topic? get selectedTopic => _selectedTopic;
  Lesson? get selectedLesson => _selectedLesson;
  StepNode? get selectedStep => _selectedStep;

  List<ClassGroup> get classes => _classes;
  List<Student> get students => _students;
  Student? get currentStudent => _currentStudent;

  ClassGroup? get currentClass {
    if (_currentStudent == null) return null;
    return _classes.firstWhere(
          (c) => c.id == _currentStudent!.classId,
      orElse: () => ClassGroup(id: '', name: 'N/A', code: 'N/A', room: '', createdAt: ''),
    );
  }

  RoadmapProvider() {
    _initData();
  }

  Future<void> _initData() async {
    await loadTopics();
    await loadClassesAndStudents();
  }

  Future<void> loadClassesAndStudents() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load Classes
      final String? savedClasses = prefs.getString(_classesKey);
      if (savedClasses != null) {
        final List<dynamic> decoded = jsonDecode(savedClasses);
        _classes = decoded.map((e) => ClassGroup.fromJson(e)).toList();
      } else {
        _classes = List.from(sampleClasses);
        await prefs.setString(_classesKey, jsonEncode(_classes.map((e) => e.toJson()).toList()));
      }

      // Load Students
      final String? savedStudents = prefs.getString(_studentsKey);
      if (savedStudents != null) {
        final List<dynamic> decoded = jsonDecode(savedStudents);
        _students = decoded.map((e) => Student.fromJson(e)).toList();
      } else {
        _students = List.from(sampleStudents);
        await prefs.setString(_studentsKey, jsonEncode(_students.map((e) => e.toJson()).toList()));
      }

      // Load session
      final String? savedSession = prefs.getString(_sessionKey);
      if (savedSession != null) {
        _currentStudent = Student.fromJson(jsonDecode(savedSession));
      }
    } catch (e) {
      debugPrint('Failed to load classes/students: $e');
      _classes = List.from(sampleClasses);
      _students = List.from(sampleStudents);
    }
    notifyListeners();
  }

  Future<void> loginStudent(Student student) async {
    _currentStudent = student;
    notifyListeners(); // Thông báo ngay để UI chuyển sang Dashboard

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sessionKey, jsonEncode(student.toJson()));
    } catch (e) {
      debugPrint('Failed to save student session: $e');
    }
  }

  Future<void> logoutStudent() async {
    _currentStudent = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionKey);
    } catch (e) {
      debugPrint('Failed to remove student session: $e');
    }
    notifyListeners();
  }


  // Load database from SharedPreferences
  Future<void> loadTopics() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? saved = prefs.getString(_storageKey);

      if (saved != null) {
        final List<dynamic> decoded = jsonDecode(saved);
        _topics = decoded.map((e) => Topic.fromJson(e)).toList();
      } else {
        _topics = List.from(sampleTopics);
        await saveTopics();
      }
    } catch (e) {
      debugPrint('Failed to load topics: $e');
      _topics = List.from(sampleTopics);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save database to SharedPreferences
  Future<void> saveTopics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(_topics.map((e) => e.toJson()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (e) {
      debugPrint('Failed to save topics: $e');
    }
  }

  // Navigation Setters
  void selectTopic(Topic? topic) {
    _selectedTopic = topic;
    _selectedLesson = null;
    _selectedStep = null;
    notifyListeners();
  }

  void selectLesson(Lesson? lesson) {
    _selectedLesson = lesson;
    _selectedStep = null;
    notifyListeners();
  }

  void selectStep(StepNode? step) {
    _selectedStep = step;
    notifyListeners();
  }

  // --- Topic CRUD Actions ---
  Future<void> addTopic(String title) async {
    final newTopic = Topic(
      id: 'topic-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: 'Nhấn nút Sửa để điền mô tả cho chủ đề này.',
      emoji: '🧠',
      lessons: [],
      createdAt: DateTime.now().toIso8601String(),
    );
    _topics.add(newTopic);
    await saveTopics();
    notifyListeners();
  }

  Future<void> addGeneratedTopic(Topic topic) async {
    _topics.add(topic);
    await saveTopics();
    selectTopic(topic);
    if (topic.lessons.isNotEmpty) {
      selectLesson(topic.lessons.first);
    }
    notifyListeners();
  }

  Future<void> updateTopic(String id, {String? title, String? description, String? emoji}) async {
    final idx = _topics.indexWhere((t) => t.id == id);
    if (idx != -1) {
      if (title != null) _topics[idx].title = title;
      if (description != null) _topics[idx].description = description;
      if (emoji != null) _topics[idx].emoji = emoji;

      if (_selectedTopic?.id == id) {
        _selectedTopic = _topics[idx];
      }
      await saveTopics();
      notifyListeners();
    }
  }

  Future<void> deleteTopic(String id) async {
    _topics.removeWhere((t) => t.id == id);
    if (_selectedTopic?.id == id) {
      _selectedTopic = null;
      _selectedLesson = null;
      _selectedStep = null;
    }
    await saveTopics();
    notifyListeners();
  }

  // --- Lesson CRUD Actions ---
  Future<void> addLesson(String topicId, String title, String description) async {
    final topicIdx = _topics.indexWhere((t) => t.id == topicId);
    if (topicIdx != -1) {
      final topic = _topics[topicIdx];
      final newLesson = Lesson(
        id: 'lesson-${DateTime.now().millisecondsSinceEpoch}',
        topicId: topicId,
        title: title,
        description: description,
        order: topic.lessons.length + 1,
        nodes: [],
        edges: [],
      );
      topic.lessons.add(newLesson);
      _selectedTopic = topic;
      _selectedLesson = newLesson;
      await saveTopics();
      notifyListeners();
    }
  }

  Future<void> updateLesson(String lessonId, {String? title, String? description}) async {
    if (_selectedTopic == null) return;

    final lessonIdx = _selectedTopic!.lessons.indexWhere((l) => l.id == lessonId);
    if (lessonIdx != -1) {
      final lesson = _selectedTopic!.lessons[lessonIdx];
      if (title != null) lesson.title = title;
      if (description != null) lesson.description = description;

      _selectedLesson = lesson;
      await saveTopics();
      notifyListeners();
    }
  }

  Future<void> deleteLesson(String lessonId) async {
    if (_selectedTopic == null) return;

    _selectedTopic!.lessons.removeWhere((l) => l.id == lessonId);
    if (_selectedLesson?.id == lessonId) {
      _selectedLesson = null;
      _selectedStep = null;
    }
    await saveTopics();
    notifyListeners();
  }

  // --- Step Node CRUD Actions ---
  Future<void> addStep(String lessonId) async {
    if (_selectedTopic == null || _selectedLesson == null) return;

    final nextOrder = _selectedLesson!.nodes.length + 1;
    final newStep = StepNode(
      id: 'step-${DateTime.now().millisecondsSinceEpoch}',
      lessonId: lessonId,
      title: 'Chủ đề kiến thức mới / New Concept',
      description: 'Chạm biểu tượng bút để thay đổi nội dung này, thêm ví dụ hoặc checklist học tập.',
      emoji: '💡',
      positionX: 300.0,
      positionY: 100.0 + (nextOrder - 1) * 120.0,
      status: StepStatus.notStarted,
      order: nextOrder,
    );

    _selectedLesson!.nodes.add(newStep);
    _selectedStep = newStep;
    await saveTopics();
    notifyListeners();
  }

  Future<void> updateStep(String stepId, {
    String? title,
    String? description,
    String? emoji,
    StepStatus? status,
    int? order,
    List<ChecklistItem>? checklist,
    String? codeSnippet,
    String? codeLanguage,
    String? imageUrl,
  }) async {
    if (_selectedLesson == null) return;

    final stepIdx = _selectedLesson!.nodes.indexWhere((n) => n.id == stepId);
    if (stepIdx != -1) {
      final step = _selectedLesson!.nodes[stepIdx];
      if (title != null) step.title = title;
      if (description != null) step.description = description;
      if (emoji != null) step.emoji = emoji;
      if (status != null) step.status = status;
      if (order != null) step.order = order;
      if (checklist != null) step.checklist = checklist;
      if (codeSnippet != null) step.codeSnippet = codeSnippet;
      if (codeLanguage != null) step.codeLanguage = codeLanguage;
      if (imageUrl != null) step.imageUrl = imageUrl;

      _selectedStep = step;
      await saveTopics();
      notifyListeners();
    }
  }

  Future<void> deleteStep(String stepId) async {
    if (_selectedLesson == null) return;

    _selectedLesson!.nodes.removeWhere((n) => n.id == stepId);
    // Delete any connected edges too
    _selectedLesson!.edges.removeWhere((e) => e.from == stepId || e.to == stepId);

    if (_selectedStep?.id == stepId) {
      _selectedStep = null;
    }
    await saveTopics();
    notifyListeners();
  }

  // --- Statistics Helpers ---
  Map<String, dynamic> getOverallStats() {
    final totalTopics = _topics.length;
    final allLessons = _topics.flatMap((t) => t.lessons);
    final totalLessons = allLessons.length;
    final allSteps = allLessons.flatMap((l) => l.nodes);
    final totalSteps = allSteps.length;
    final completedSteps = allSteps.where((s) => s.status == StepStatus.completed).length;
    final percent = totalSteps > 0 ? ((completedSteps / totalSteps) * 100).round() : 0;

    return {
      'totalTopics': totalTopics,
      'totalLessons': totalLessons,
      'totalSteps': totalSteps,
      'completedSteps': completedSteps,
      'percent': percent,
    };
  }
}

// Simple flatMap helper for lists in Dart
extension ListFlatMap<T> on List<T> {
  List<R> flatMap<R>(Iterable<R> Function(T) f) {
    return map(f).expand((e) => e).toList();
  }
}
