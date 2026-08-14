// All domain enumerations used across models.
// Import this file (or the barrel `roadmap.dart`) to access any enum.
enum AccessLevel {
  free,
  rewarded,
  premium,
  group,
}

enum LearningPlan {
  free,
  premium,
  groupPro,
}

enum StepVisualState {
  locked,
  ready,
  inProgress,
  completed,
}

enum StepContentBlockType {
  heading,
  paragraph,
  callout,
  bullets,
  quote,
  image,
  audio,
  code,
  divider,
}

enum ProgressStatus {
  notStarted,
  inProgress,
  completed,
  locked,
}
