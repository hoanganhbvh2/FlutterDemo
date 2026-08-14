import 'model_helpers.dart';

class QuizQuestion {
  final String id;
  final String prompt;
  final List<String> options;
  final int correctIndex;

  const QuizQuestion({
    required this.id,
    required this.prompt,
    required this.options,
    required this.correctIndex,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: parseStringValue(json['id']),
      prompt: parseStringValue(json['prompt']),
      options: parseStringList(json['options']),
      correctIndex: parseIntValue(json['correctIndex']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prompt': prompt,
      'options': options,
      'correctIndex': correctIndex,
    };
  }
}

class StepQuiz {
  final int passThreshold;
  final List<QuizQuestion> questions;

  const StepQuiz({
    required this.passThreshold,
    required this.questions,
  });

  factory StepQuiz.fromJson(Map<String, dynamic> json) {
    final questions = (json['questions'] as List<dynamic>? ?? const <dynamic>[])
        .map((item) => QuizQuestion.fromJson(item as Map<String, dynamic>))
        .toList();

    var threshold = parseIntValue(
      json['passThreshold'],
      fallback: questions.isEmpty ? 0 : questions.length,
    );
    if (questions.isNotEmpty && threshold > questions.length) {
      threshold = questions.length;
    }

    return StepQuiz(
      passThreshold: threshold,
      questions: questions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'passThreshold': passThreshold,
      'questions': questions.map((item) => item.toJson()).toList(),
    };
  }
}
