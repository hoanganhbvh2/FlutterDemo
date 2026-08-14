import 'model_helpers.dart';

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
      id: parseStringValue(json['id']),
      title: parseStringValue(json['title']),
      subtitle: parseStringValue(json['subtitle'] ?? json['description']),
      icon: parseStringValue(json['icon'], fallback: 'school'),
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
