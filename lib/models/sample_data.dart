import 'roadmap.dart';

const sampleCategories = <Category>[
  Category(
    id: 'mobile',
    title: 'Mobile',
    subtitle: 'Build apps and ship habits',
    icon: 'smartphone',
  ),
  Category(
    id: 'backend',
    title: 'Backend',
    subtitle: 'API design and architecture',
    icon: 'server',
  ),
  Category(
    id: 'career',
    title: 'Career',
    subtitle: 'Learning systems and growth',
    icon: 'rocket',
  ),
];

const sampleGroups = <LearningGroup>[
  LearningGroup(
    id: 'bootcamp-pro',
    title: 'LTM-F-K22',
    description: 'Private roadmap for mentored learners.',
  ),
];

final sampleTopics = <Topic>[
  Topic(
    id: 'topic-flutter-foundations',
    tagIds: const ['mobile'],
    title: 'Flutter Foundations',
    description:
        'Start from setup, understand widgets, and ship a clean first app with a structured learning flow.',
    emoji: '📱',
    levelLabel: 'Beginner',
    estimatedHours: 12,
    lessons: [
      Lesson(
        id: 'lesson-flutter-setup',
        topicId: 'topic-flutter-foundations',
        title: 'Kickoff and Setup',
        description:
            'Create your environment, understand the project shape, and unlock the first runnable screen.',
        order: 1,
        accessLevel: AccessLevel.free,
        allowedGroupIds: const [],
        estimatedMinutes: 45,
        steps: [
          StepNode(
            id: 'step-sdk',
            lessonId: 'lesson-flutter-setup',
            title: 'Install Flutter SDK',
            description: 'Prepare the base toolchain and verify your setup.',
            emoji: '🧰',
            order: 1,
            accessLevel: AccessLevel.free,
            allowedGroupIds: const [],
            prerequisiteStepIds: const [],
            checklist: const [
              ChecklistItem(
                id: 'sdk-1',
                text: 'Install Flutter via the official stable channel.',
              ),
              ChecklistItem(
                id: 'sdk-2',
                text: 'Run flutter doctor and resolve core blockers.',
              ),
              ChecklistItem(
                id: 'sdk-3',
                text: 'Create a sandbox project to test the toolchain.',
              ),
            ],
            note:
                'Store-ready apps start with a predictable environment. Avoid mixing random IDE plugins before the toolchain is healthy.',
            theory:
                'Flutter uses a single Dart codebase to render native interfaces on both Android and iOS. Your first milestone is not writing UI, but making the toolchain predictable: Flutter SDK, simulator or emulator, and a first clean run.',
            codeSnippet:
                'flutter doctor\nflutter create roadmap_app\ncd roadmap_app\nflutter run',
            codeLanguage: 'bash',
            contentBlocks: const [
              StepContentBlock(
                id: 'sdk-heading',
                type: StepContentBlockType.heading,
                title: 'Start with a **healthy toolchain**',
                body:
                    'Before UI work begins, the learner needs confidence that `flutter doctor` and a fresh run actually work.',
              ),
              StepContentBlock(
                id: 'sdk-paragraph',
                type: StepContentBlockType.paragraph,
                body:
                    'Treat this step as infrastructure, not setup ceremony. A predictable environment makes every later support conversation faster and cleaner.',
              ),
              StepContentBlock(
                id: 'sdk-image',
                type: StepContentBlockType.image,
                title: 'Environment checkpoint',
                caption:
                    'This block is ready for screenshots, diagrams, or annotated setup visuals when real content is authored in admin.',
              ),
              StepContentBlock(
                id: 'sdk-code',
                type: StepContentBlockType.code,
                body:
                    'flutter doctor\nflutter create roadmap_app\ncd roadmap_app\nflutter run',
                codeLanguage: 'bash',
              ),
            ],
            xpReward: 30,
            estimatedMinutes: 12,
          ),
          StepNode(
            id: 'step-project-structure',
            lessonId: 'lesson-flutter-setup',
            title: 'Read the project structure',
            description:
                'Understand where UI, state, and assets should live before scaling the app.',
            emoji: '🗂️',
            order: 2,
            accessLevel: AccessLevel.rewarded,
            allowedGroupIds: const [],
            prerequisiteStepIds: const ['step-sdk'],
            checklist: const [
              ChecklistItem(
                id: 'structure-1',
                text: 'Identify the role of lib, assets, android, and ios.',
              ),
              ChecklistItem(
                id: 'structure-2',
                text: 'Decide where screens, providers, and models will live.',
              ),
            ],
            quiz: const StepQuiz(
              passThreshold: 2,
              questions: [
                QuizQuestion(
                  id: 'quiz-structure-1',
                  prompt: 'What folder should contain your app UI code?',
                  options: ['android', 'lib', 'ios', 'build'],
                  correctIndex: 1,
                ),
                QuizQuestion(
                  id: 'quiz-structure-2',
                  prompt: 'What is the main reason to separate models and screens?',
                  options: [
                    'To make the bundle larger',
                    'To slow down hot reload',
                    'To keep the codebase maintainable',
                    'To avoid using state management',
                  ],
                  correctIndex: 2,
                ),
              ],
            ),
            note:
                'Rewarded steps simulate your future monetization path: users learn first, then unlock deeper material by quiz plus reward ad.',
            theory:
                'A good learning app grows fast. If you do not decide the folder boundaries early, step content, unlock logic, and future monetization code will end up mixed inside screens.',
            codeSnippet:
                'lib/\n  models/\n  providers/\n  screens/\n  widgets/\n  services/',
            codeLanguage: 'text',
            contentBlocks: const [
              StepContentBlock(
                id: 'structure-heading',
                type: StepContentBlockType.heading,
                title: 'Organize for **clarity before scale**',
                body:
                    'A clean project tree makes both the learner app and the admin tooling easier to evolve.',
              ),
              StepContentBlock(
                id: 'structure-bullets',
                type: StepContentBlockType.bullets,
                title: 'Folders that matter first',
                items: [
                  'Keep `models` focused on product data, not widget state.',
                  'Use `providers` or future services for logic that must survive multiple screens.',
                  'Treat `screens` as orchestration layers, not as giant storage bins.',
                ],
              ),
              StepContentBlock(
                id: 'structure-audio',
                type: StepContentBlockType.audio,
                title: 'Optional audio explanation',
                caption:
                    'This block reserves room for a short spoken explanation or recap without changing the reader layout later.',
              ),
            ],
            xpReward: 45,
            estimatedMinutes: 15,
          ),
          StepNode(
            id: 'step-first-screen',
            lessonId: 'lesson-flutter-setup',
            title: 'Ship a first screen',
            description:
                'Render a simple but intentional home screen to validate layout thinking.',
            emoji: '✨',
            order: 3,
            accessLevel: AccessLevel.rewarded,
            allowedGroupIds: const [],
            prerequisiteStepIds: const ['step-project-structure'],
            checklist: const [
              ChecklistItem(
                id: 'screen-1',
                text: 'Build a scaffold with a clear top section and one CTA.',
              ),
              ChecklistItem(
                id: 'screen-2',
                text: 'Choose a bright palette and one emphasis color.',
              ),
              ChecklistItem(
                id: 'screen-3',
                text: 'Verify the first screen on both small and tall devices.',
              ),
            ],
            note:
                'This is where UX starts. Even a placeholder screen should establish hierarchy and spacing discipline.',
            theory:
                'The first screen is where you prove the design language. Use contrast, spacing, and one focused action instead of dumping every feature at once.',
            codeSnippet:
                'return Scaffold(\n  appBar: AppBar(title: const Text("Roadmap")),\n  body: const Center(child: Text("Hello roadmap")),\n);',
            codeLanguage: 'dart',
            xpReward: 55,
            estimatedMinutes: 18,
          ),
        ],
      ),
      Lesson(
        id: 'lesson-flutter-learning-app',
        topicId: 'topic-flutter-foundations',
        title: 'Design a real learning app flow',
        description:
            'Move from demo widgets to a content-first app with progress, quiz unlocks, and a proper step screen.',
        order: 2,
        accessLevel: AccessLevel.premium,
        allowedGroupIds: const [],
        estimatedMinutes: 60,
        steps: [
          StepNode(
            id: 'step-navigation',
            lessonId: 'lesson-flutter-learning-app',
            title: 'Plan the navigation stack',
            description: 'Map Home, Topic, Blog, and Step screens clearly.',
            emoji: '🧭',
            order: 1,
            accessLevel: AccessLevel.premium,
            allowedGroupIds: const [],
            prerequisiteStepIds: const [],
            checklist: const [
              ChecklistItem(
                id: 'nav-1',
                text: 'List the user journey from dashboard to step detail.',
              ),
              ChecklistItem(
                id: 'nav-2',
                text: 'Decide what data can be passed via constructor safely.',
              ),
            ],
            note:
                'Your own request specifically called out that step content should move to a dedicated screen. This is the right structural change.',
            theory:
                'Content-heavy apps should not overload a single page. A dedicated step screen keeps reading focus high and makes room for quiz, notes, checklist, and code.',
            codeSnippet:
                'Navigator.of(context).push(\n  MaterialPageRoute(\n    builder: (_) => StepDetailScreen(stepId: step.id),\n  ),\n);',
            codeLanguage: 'dart',
            contentBlocks: const [
              StepContentBlock(
                id: 'navigation-quote',
                type: StepContentBlockType.quote,
                body:
                    'When the lesson gets longer, the reading experience becomes the product, not just a details panel.',
              ),
              StepContentBlock(
                id: 'navigation-paragraph',
                type: StepContentBlockType.paragraph,
                body:
                    'The dedicated step screen is where future rich content can breathe: images, audio snippets, code, notes, and follow-up actions all have room without crushing the list view.',
              ),
              StepContentBlock(
                id: 'navigation-code',
                type: StepContentBlockType.code,
                body:
                    'Navigator.of(context).push(\n  MaterialPageRoute(\n    builder: (_) => StepDetailScreen(stepId: step.id),\n  ),\n);',
                codeLanguage: 'dart',
              ),
            ],
            xpReward: 80,
            estimatedMinutes: 20,
          ),
          StepNode(
            id: 'step-progress-model',
            lessonId: 'lesson-flutter-learning-app',
            title: 'Model progress server-first',
            description:
                'Design a progress object that can later sync across devices.',
            emoji: '📈',
            order: 2,
            accessLevel: AccessLevel.premium,
            allowedGroupIds: const [],
            prerequisiteStepIds: const ['step-navigation'],
            checklist: const [
              ChecklistItem(
                id: 'progress-1',
                text: 'Track completed steps, quiz passes, and unlocked rewarded steps separately.',
              ),
              ChecklistItem(
                id: 'progress-2',
                text: 'Keep checklist state keyed by step id.',
              ),
            ],
            note:
                'Even though we are mocking state locally now, the model already anticipates backend sync so you will not repaint everything later.',
            theory:
                'A future backend should never trust client-only booleans. Progress needs structure: completion, unlock events, and checklist history per step.',
            codeSnippet:
                'class LearningUser {\n  final List<String> completedStepIds;\n  final List<String> passedQuizStepIds;\n  final Map<String, List<String>> checklistState;\n}',
            codeLanguage: 'dart',
            xpReward: 90,
            estimatedMinutes: 18,
          ),
        ],
      ),
    ],
  ),
  Topic(
    id: 'topic-spring-api',
    tagIds: const ['backend', 'career'],
    title: 'Spring API Roadmap',
    description:
        'Build a clean backend mental model around auth, CRUD flows, and production boundaries.',
    emoji: '🛠️',
    levelLabel: 'Intermediate',
    estimatedHours: 10,
    lessons: [
      Lesson(
        id: 'lesson-api-essentials',
        topicId: 'topic-spring-api',
        title: 'API essentials',
        description:
            'Understand resources, DTOs, and why backend validation must own access control.',
        order: 1,
        accessLevel: AccessLevel.free,
        allowedGroupIds: const [],
        estimatedMinutes: 50,
        steps: [
          StepNode(
            id: 'step-rest-resources',
            lessonId: 'lesson-api-essentials',
            title: 'Shape resources cleanly',
            description: 'Define stable routes around business objects.',
            emoji: '🌐',
            order: 1,
            accessLevel: AccessLevel.free,
            allowedGroupIds: const [],
            prerequisiteStepIds: const [],
            checklist: const [
              ChecklistItem(
                id: 'rest-1',
                text: 'Map Topic, Blog, and Step to clear resource names.',
              ),
              ChecklistItem(
                id: 'rest-2',
                text: 'Separate request DTOs from persistence entities.',
              ),
            ],
            note:
                'Your frontend already benefits when the backend speaks the same domain language.',
            theory:
                'A clean API names things by business meaning, not database tables. Resource design also shapes permissions and analytics later.',
            codeSnippet:
                '@GetMapping("/topics/{topicId}/lessons")\npublic List<LessonResponse> getLessons(...) { ... }',
            codeLanguage: 'java',
            xpReward: 35,
            estimatedMinutes: 15,
          ),
          StepNode(
            id: 'step-server-guards',
            lessonId: 'lesson-api-essentials',
            title: 'Guard premium logic on the server',
            description:
                'Keep quiz unlock and premium gates validated outside the client.',
            emoji: '🔐',
            order: 2,
            accessLevel: AccessLevel.group,
            allowedGroupIds: const ['bootcamp-pro'],
            prerequisiteStepIds: const ['step-rest-resources'],
            checklist: const [
              ChecklistItem(
                id: 'guard-1',
                text: 'Verify plan type on the server before returning locked content.',
              ),
              ChecklistItem(
                id: 'guard-2',
                text: 'Persist quiz results and rewarded unlock events.',
              ),
            ],
            note:
                'This lesson is group-gated to reflect your future class or mentor distribution model.',
            theory:
                'Premium content fails quickly if unlock logic lives only on the device. The app can request, but the backend must decide.',
            codeSnippet:
                'if (!permissionService.canViewStep(userId, stepId)) {\n  throw new ForbiddenException("Step locked");\n}',
            codeLanguage: 'java',
            xpReward: 70,
            estimatedMinutes: 22,
          ),
        ],
      ),
    ],
  ),
  Topic(
    id: 'topic-learning-system',
    tagIds: const ['career'],
    title: 'Learning System for Consistency',
    description:
        'Turn content consumption into a streak-driven routine with reflection, checkpoints, and energy management.',
    emoji: '🎯',
    levelLabel: 'All levels',
    estimatedHours: 6,
    lessons: [
      Lesson(
        id: 'lesson-consistency',
        topicId: 'topic-learning-system',
        title: 'Consistency loop',
        description:
            'Use small wins, checkpoints, and weekly reflection to keep the roadmap alive.',
        order: 1,
        accessLevel: AccessLevel.free,
        allowedGroupIds: const [],
        estimatedMinutes: 35,
        steps: [
          StepNode(
            id: 'step-daily-goal',
            lessonId: 'lesson-consistency',
            title: 'Set a daily minimum',
            description: 'Pick the smallest repeatable learning unit.',
            emoji: '🔥',
            order: 1,
            accessLevel: AccessLevel.free,
            allowedGroupIds: const [],
            prerequisiteStepIds: const [],
            checklist: const [
              ChecklistItem(
                id: 'goal-1',
                text: 'Define a daily minimum that takes under 20 minutes.',
              ),
              ChecklistItem(
                id: 'goal-2',
                text: 'Attach the learning block to an existing habit.',
              ),
            ],
            note:
                'Gamification only works when the loop is realistic. Hard systems collapse, easy systems compound.',
            theory:
                'A daily minimum lowers resistance. The streak becomes believable, and the learner is more likely to return tomorrow.',
            codeSnippet:
                'Daily target: 1 step + 1 checklist item + 1 reflection note',
            codeLanguage: 'text',
            contentBlocks: const [
              StepContentBlock(
                id: 'daily-goal-paragraph',
                type: StepContentBlockType.paragraph,
                body:
                    'The best daily target is small enough to survive low-energy days while still reinforcing momentum.',
              ),
              StepContentBlock(
                id: 'daily-goal-callout',
                type: StepContentBlockType.callout,
                title: 'Keep the loop believable',
                body:
                    'If the learner misses too often, the streak system stops feeling trustworthy and the roadmap loses emotional pull.',
              ),
            ],
            xpReward: 20,
            estimatedMinutes: 10,
          ),
        ],
      ),
    ],
  ),
];

final sampleUsers = <LearningUser>[
  const LearningUser(
    id: 'user-free',
    name: 'Mai Free',
    email: 'mai@kahoa.app',
    password: 'kahoa123',
    avatar: 'M',
    plan: LearningPlan.free,
    groupIds: [],
    streakDays: 4,
    gems: 120,
    adsWatched: 1,
    completedStepIds: ['step-sdk'],
    unlockedRewardedStepIds: [],
    passedQuizStepIds: [],
    checklistState: {
      'step-sdk': ['sdk-1', 'sdk-2'],
    },
  ),
  const LearningUser(
    id: 'user-premium',
    name: 'An Premium',
    email: 'an@kahoa.app',
    password: 'kahoa123',
    avatar: 'A',
    plan: LearningPlan.premium,
    groupIds: [],
    streakDays: 12,
    gems: 310,
    adsWatched: 0,
    completedStepIds: ['step-sdk', 'step-project-structure'],
    unlockedRewardedStepIds: [],
    passedQuizStepIds: ['step-project-structure'],
    checklistState: {
      'step-sdk': ['sdk-1', 'sdk-2', 'sdk-3'],
      'step-project-structure': ['structure-1'],
    },
  ),
  const LearningUser(
    id: 'user-group',
    name: 'Linh Group',
    email: 'linh@kahoa.app',
    password: 'kahoa123',
    avatar: 'L',
    plan: LearningPlan.groupPro,
    groupIds: ['bootcamp-pro'],
    streakDays: 8,
    gems: 240,
    adsWatched: 0,
    completedStepIds: ['step-rest-resources'],
    unlockedRewardedStepIds: [],
    passedQuizStepIds: [],
    checklistState: {
      'step-rest-resources': ['rest-1'],
    },
  ),
];
