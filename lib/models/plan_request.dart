import 'model_helpers.dart';

/// Typed model for a plan upgrade request.
/// Replaces the previous untyped `Map<String, dynamic>` in providers.
class PlanRequest {
  final String id;
  final String name;
  final String phone;
  final String content;
  final String status;
  final String? adminNote;
  final String createdAt;

  const PlanRequest({
    required this.id,
    required this.name,
    required this.phone,
    required this.content,
    required this.status,
    this.adminNote,
    required this.createdAt,
  });

  factory PlanRequest.fromJson(Map<String, dynamic> json) {
    return PlanRequest(
      id: parseStringValue(json['id'] ?? json['_id']),
      name: parseStringValue(json['name']),
      phone: parseStringValue(json['phone']),
      content: parseStringValue(json['content']),
      status: parseStringValue(json['status'], fallback: 'PENDING'),
      adminNote:
          json['adminNote'] != null ? parseStringValue(json['adminNote']) : null,
      createdAt: parseStringValue(json['createdAt'] ?? json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'content': content,
      'status': status,
      if (adminNote != null) 'adminNote': adminNote,
      'createdAt': createdAt,
    };
  }
}
