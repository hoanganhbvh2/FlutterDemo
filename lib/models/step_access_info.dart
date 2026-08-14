import 'enums.dart';

/// Describes the access & visual state of a step for the current user.
class StepAccessInfo {
  final bool canOpen;
  final bool needsQuiz;
  final bool needsRewardAd;
  final bool needsPremium;
  final bool needsGroup;
  final String message;
  final StepVisualState state;

  const StepAccessInfo({
    required this.canOpen,
    required this.needsQuiz,
    required this.needsRewardAd,
    required this.needsPremium,
    required this.needsGroup,
    required this.message,
    required this.state,
  });
}
