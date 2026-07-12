enum StepStatus {
  notStarted,
  inProgress,
  completed,
}

class ChecklistItem {
  final String id;
  String text;
  bool completed;

  ChecklistItem({
    required this.id,
    required this.text,
    required this.completed,
  });

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      completed: json['completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'completed': completed,
    };
  }
}

class StepNode {
  final String id;
  final String lessonId;
  String title;
  String description;
  String emoji;
  double positionX;
  double positionY;
  StepStatus status;
  int order;
  List<ChecklistItem>? checklist;
  String? codeSnippet;
  String? codeLanguage;
  String? imageUrl;

  StepNode({
    required this.id,
    required this.lessonId,
    required this.title,
    required this.description,
    required this.emoji,
    required this.positionX,
    required this.positionY,
    required this.status,
    required this.order,
    this.checklist,
    this.codeSnippet,
    this.codeLanguage,
    this.imageUrl,
  });

  factory StepNode.fromJson(Map<String, dynamic> json) {
    StepStatus statusVal;
    switch (json['status']) {
      case 'Completed':
        statusVal = StepStatus.completed;
        break;
      case 'In Progress':
        statusVal = StepStatus.inProgress;
        break;
      default:
        statusVal = StepStatus.notStarted;
    }

    var checklistList = json['checklist'] as List? ?? [];

    return StepNode(
      id: json['id'] ?? '',
      lessonId: json['lessonId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      emoji: json['emoji'] ?? '📝',
      positionX: (json['positionX'] as num?)?.toDouble() ?? 0.0,
      positionY: (json['positionY'] as num?)?.toDouble() ?? 0.0,
      status: statusVal,
      order: json['order'] ?? 1,
      checklist: checklistList.map((e) => ChecklistItem.fromJson(e)).toList(),
      codeSnippet: json['codeSnippet'] ?? '',
      codeLanguage: json['codeLanguage'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    String statusStr;
    switch (status) {
      case StepStatus.completed:
        statusStr = 'Completed';
        break;
      case StepStatus.inProgress:
        statusStr = 'In Progress';
        break;
      case StepStatus.notStarted:
        statusStr = 'Not Started';
    }
    return {
      'id': id,
      'lessonId': lessonId,
      'title': title,
      'description': description,
      'emoji': emoji,
      'positionX': positionX,
      'positionY': positionY,
      'status': statusStr,
      'order': order,
      'checklist': checklist?.map((e) => e.toJson()).toList() ?? [],
      'codeSnippet': codeSnippet ?? '',
      'codeLanguage': codeLanguage ?? '',
      'imageUrl': imageUrl ?? '',
    };
  }
}

class Edge {
  final String id;
  final String lessonId;
  final String from;
  final String to;

  Edge({
    required this.id,
    required this.lessonId,
    required this.from,
    required this.to,
  });

  factory Edge.fromJson(Map<String, dynamic> json) {
    return Edge(
      id: json['id'] ?? '',
      lessonId: json['lessonId'] ?? '',
      from: json['from'] ?? '',
      to: json['to'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lessonId': lessonId,
      'from': from,
      'to': to,
    };
  }
}

class Lesson {
  final String id;
  final String topicId;
  String title;
  String description;
  int order;
  List<StepNode> nodes;
  List<Edge> edges;

  Lesson({
    required this.id,
    required this.topicId,
    required this.title,
    required this.description,
    required this.order,
    required this.nodes,
    required this.edges,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    var nodesList = json['nodes'] as List? ?? [];
    var edgesList = json['edges'] as List? ?? [];
    return Lesson(
      id: json['id'] ?? '',
      topicId: json['topicId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      order: json['order'] ?? 1,
      nodes: nodesList.map((e) => StepNode.fromJson(e)).toList(),
      edges: edgesList.map((e) => Edge.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'topicId': topicId,
      'title': title,
      'description': description,
      'order': order,
      'nodes': nodes.map((e) => e.toJson()).toList(),
      'edges': edges.map((e) => e.toJson()).toList(),
    };
  }
}

class Topic {
  final String id;
  String title;
  String description;
  String emoji;
  List<Lesson> lessons;
  final String createdAt;

  Topic({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.lessons,
    required this.createdAt,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    var lessonsList = json['lessons'] as List? ?? [];
    return Topic(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      emoji: json['emoji'] ?? '🧠',
      lessons: lessonsList.map((e) => Lesson.fromJson(e)).toList(),
      createdAt: json['createdAt'] ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'emoji': emoji,
      'lessons': lessons.map((e) => e.toJson()).toList(),
      'createdAt': createdAt,
    };
  }
}

class ClassGroup {
  final String id;
  final String name;
  final String code;
  final String room;
  final String createdAt;

  ClassGroup({
    required this.id,
    required this.name,
    required this.code,
    required this.room,
    required this.createdAt,
  });

  factory ClassGroup.fromJson(Map<String, dynamic> json) {
    return ClassGroup(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      room: json['room'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'room': room,
      'createdAt': createdAt,
    };
  }
}

class Student {
  final String id;
  final String classId;
  final String name;
  final String studentId;
  final String avatarEmoji;
  final String avatarColor;
  final String photoUrl;
  final String password;
  final String createdAt;

  Student({
    required this.id,
    required this.classId,
    required this.name,
    required this.studentId,
    required this.avatarEmoji,
    required this.avatarColor,
    required this.photoUrl,
    required this.password,
    required this.createdAt,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] ?? '',
      classId: json['classId'] ?? '',
      name: json['name'] ?? '',
      studentId: json['studentId'] ?? '',
      avatarEmoji: json['avatarEmoji'] ?? '🦊',
      avatarColor: json['avatarColor'] ?? '#f97316',
      photoUrl: json['photoUrl'] ?? '',
      password: json['password'] ?? '123',
      createdAt: json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'classId': classId,
      'name': name,
      'studentId': studentId,
      'avatarEmoji': avatarEmoji,
      'avatarColor': avatarColor,
      'photoUrl': photoUrl,
      'password': password,
      'createdAt': createdAt,
    };
  }
}

