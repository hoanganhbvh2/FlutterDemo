import '../models/roadmap.dart';

class AuthorProfile {
  final String id;
  final String code;
  final String username;
  final String name;
  final String fullName;
  final String email;
  final String description;
  final String role;
  final List<Topic> blogs;

  const AuthorProfile({
    required this.id,
    required this.code,
    required this.username,
    required this.name,
    required this.fullName,
    required this.email,
    required this.description,
    this.role = 'AUTHOR',
    this.blogs = const [],
  });

  factory AuthorProfile.fromJson(Map<String, dynamic> json) {
    final blogsList = (json['blogs'] as List<dynamic>? ?? const <dynamic>[])
        .map((item) => Topic.fromJson(item as Map<String, dynamic>))
        .toList();

    return AuthorProfile(
      id: parseStringValue(json['id']),
      code: parseStringValue(json['code']),
      username: parseStringValue(json['username']),
      name: parseStringValue(json['name'] ?? json['fullName']),
      fullName: parseStringValue(json['fullName'] ?? json['name']),
      email: parseStringValue(json['email']),
      description: parseStringValue(json['description']),
      role: parseStringValue(json['role'], fallback: 'AUTHOR'),
      blogs: blogsList,
    );
  }
}

class ExploreSearchResult {
  final List<AuthorProfile> authors;
  final List<Topic> blogs;
  final List<StepNode> steps;

  const ExploreSearchResult({
    this.authors = const [],
    this.blogs = const [],
    this.steps = const [],
  });

  factory ExploreSearchResult.fromJson(Map<String, dynamic> json) {
    final authorsList =
        (json['authors'] as List<dynamic>? ?? const <dynamic>[])
            .map((item) =>
                AuthorProfile.fromJson(item as Map<String, dynamic>))
            .toList();

    final blogsList = (json['blogs'] as List<dynamic>? ?? const <dynamic>[])
        .map((item) => Topic.fromJson(item as Map<String, dynamic>))
        .toList();

    final stepsList = (json['steps'] as List<dynamic>? ?? const <dynamic>[])
        .map((item) => StepNode.fromJson(item as Map<String, dynamic>))
        .toList();

    return ExploreSearchResult(
      authors: authorsList,
      blogs: blogsList,
      steps: stepsList,
    );
  }
}
