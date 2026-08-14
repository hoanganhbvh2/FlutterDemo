import 'model_helpers.dart';

class ChecklistItem {
  final String id;
  final String text;

  const ChecklistItem({
    required this.id,
    required this.text,
  });

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      id: parseStringValue(json['id']),
      text: parseStringValue(json['text']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
    };
  }
}

/// Parses a raw JSON checklist value into a list of [ChecklistItem].
/// Handles both structured `{id, text}` maps and plain string entries
/// (the latter are used in the admin editor and seed data).
List<ChecklistItem> parseChecklist(dynamic raw) {
  final list = raw as List<dynamic>? ?? const <dynamic>[];
  return list.asMap().entries.map((entry) {
    final item = entry.value;
    if (item is Map<String, dynamic>) {
      return ChecklistItem.fromJson(item);
    }
    // Plain string — use the text itself as the stable id so saved progress
    // round-trips correctly.
    final text = item.toString();
    return ChecklistItem(id: text, text: text);
  }).toList();
}
