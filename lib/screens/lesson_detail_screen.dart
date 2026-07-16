import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/roadmap.dart';
import '../providers/roadmap_provider.dart';
import '../widgets/rich_content.dart';
import 'step_detail_screen.dart';

class LessonDetailScreen extends StatefulWidget {
  const LessonDetailScreen({
    super.key,
    required this.topicId,
    required this.lessonId,
  });

  final String topicId;
  final String lessonId;

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  Future<void> _openStep({
    required RoadmapProvider provider,
    required Lesson lesson,
    required StepNode step,
  }) async {
    final access = provider.stepAccessInfo(lesson: lesson, step: step);
    if (!access.canOpen) {
      return;
    }

    final shouldPromptQuiz = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => StepDetailScreen(
              topicId: widget.topicId,
              lessonId: lesson.id,
              stepId: step.id,
            ),
          ),
        ) ??
        false;

    if (!mounted || !shouldPromptQuiz || step.quiz == null || provider.hasPassedQuiz(step.id)) {
      return;
    }

    await _showExitQuiz(provider: provider, step: step);
  }

  Future<void> _showExitQuiz({
    required RoadmapProvider provider,
    required StepNode step,
  }) async {
    final answers = <String, int>{};
    final rootMessenger = ScaffoldMessenger.of(context);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        var isSubmitting = false;
        var quizPassed = false;
        var rewardUnlocked = provider.hasUnlockedRewardedStep(step.id);

        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> handleSubmit() async {
              setModalState(() {
                isSubmitting = true;
              });
              final passed = await provider.submitQuiz(step: step, answers: answers);
              if (!context.mounted) {
                return;
              }

              setModalState(() {
                isSubmitting = false;
                quizPassed = passed;
              });

              if (!passed) {
                rootMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('You did not meet the required score. Please try again.'),
                  ),
                );
                return;
              }

              if (step.accessLevel != AccessLevel.rewarded || provider.isPremiumUser) {
                if (provider.isChecklistComplete(step) && !provider.isStepCompleted(step.id)) {
                  await provider.markStepCompleted(step);
                }
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
                rootMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Quiz completed for this step.'),
                  ),
                );
              }
            }

            Future<void> handleRewardUnlock() async {
              await provider.unlockRewardedStep(step.id);
              rewardUnlocked = true;
              if (provider.isChecklistComplete(step) && !provider.isStepCompleted(step.id)) {
                await provider.markStepCompleted(step);
              }
              if (!context.mounted) {
                return;
              }
              Navigator.of(context).pop();
              rootMessenger.showSnackBar(
                const SnackBar(
                  content: Text('This step has been fully unlocked.'),
                ),
              );
            }

            return DraggableScrollableSheet(
              initialChildSize: 0.86,
              minChildSize: 0.65,
              maxChildSize: 0.96,
              builder: (context, controller) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: ListView(
                    controller: controller,
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFCBD5E1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Knowledge check',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Complete this quiz right after reading to continue your learning flow.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              height: 1.55,
                              color: const Color(0xFF475569),
                            ),
                      ),
                      const SizedBox(height: 18),
                      ...step.quiz!.questions.asMap().entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _QuizQuestionCard(
                            question: entry.value,
                            selectedIndex: answers[entry.value.id],
                            onSelect: (value) {
                              setModalState(() {
                                answers[entry.value.id] = value;
                              });
                            },
                            index: entry.key + 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      FilledButton(
                        onPressed: isSubmitting ? null : handleSubmit,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF1D4ED8),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(isSubmitting ? 'Checking...' : 'Submit quiz'),
                      ),
                      if (quizPassed &&
                          step.accessLevel == AccessLevel.rewarded &&
                          !provider.isPremiumUser &&
                          !rewardUnlocked) ...[
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: handleRewardUnlock,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFF59E0B)),
                            foregroundColor: const Color(0xFF92400E),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Watch a rewarded ad to finish this step'),
                        ),
                      ],
                      if (quizPassed &&
                          (step.accessLevel != AccessLevel.rewarded || provider.isPremiumUser)) ...[
                        const SizedBox(height: 12),
                        const Text(
                          'Quiz passed. You can continue to the next step.',
                          style: TextStyle(
                            color: Color(0xFF166534),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RoadmapProvider>();
    final topic = provider.topicById(widget.topicId);
    final lesson = provider.lessonById(widget.topicId, widget.lessonId);

    if (topic == null || lesson == null) {
      return const Scaffold(
        body: Center(child: Text('Lesson not found.')),
      );
    }

    final lessonAccess = provider.canAccessLesson(lesson);
    final progress = provider.lessonProgress(lesson);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          lesson.title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
        children: [
          _LessonHeader(
            topic: topic,
            lesson: lesson,
            progress: progress,
            lessonAccess: lessonAccess,
          ),
          if (!lessonAccess)
            Container(
              margin: const EdgeInsets.only(top: 14, bottom: 18),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'This blog is part of a restricted access flow. Use the right plan or group to view the full content.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Color(0xFF92400E),
                ),
              ),
            ),
          const SizedBox(height: 6),
          const Text(
            'Step list',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Follow the sequence to unlock content, read each step on its own screen, and return here for quizzes when needed.',
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 14),
          ...lesson.steps.asMap().entries.map(
            (entry) => Padding(
              padding: EdgeInsets.only(
                bottom: entry.key == lesson.steps.length - 1 ? 0 : 12,
              ),
              child: _StepTimelineTile(
                lesson: lesson,
                step: entry.value,
                index: entry.key,
                isLast: entry.key == lesson.steps.length - 1,
                onTap: () => _openStep(
                  provider: provider,
                  lesson: lesson,
                  step: entry.value,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonHeader extends StatelessWidget {
  const _LessonHeader({
    required this.topic,
    required this.lesson,
    required this.progress,
    required this.lessonAccess,
  });

  final Topic topic;
  final Lesson lesson;
  final double progress;
  final bool lessonAccess;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            topic.title.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1D4ED8),
            ),
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 24,
                height: 1.2,
                fontWeight: FontWeight.w800,
              ),
              children: [
                TextSpan(text: lesson.title),
                TextSpan(
                  text: '  ·  ${lesson.steps.length} steps',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          RichContentText(
            lesson.description,
            style: const TextStyle(
              fontSize: 15,
              height: 1.65,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFE2E8F0),
                    color: const Color(0xFF1D4ED8),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF475569),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(label: '${lesson.estimatedMinutes} min'),
              _MetaChip(label: lessonAccess ? 'Available now' : 'Locked'),
              _MetaChip(
                label: lesson.steps
                        .where((step) => step.hasImageBlock || step.hasAudioBlock)
                        .isEmpty
                    ? 'Text-first lesson'
                    : 'Mixed content lesson',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepTimelineTile extends StatelessWidget {
  const _StepTimelineTile({
    required this.lesson,
    required this.step,
    required this.index,
    required this.onTap,
    required this.isLast,
  });

  final Lesson lesson;
  final StepNode step;
  final int index;
  final VoidCallback onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RoadmapProvider>();
    final access = provider.stepAccessInfo(lesson: lesson, step: step);
    final color = switch (access.state) {
      StepVisualState.locked => const Color(0xFF94A3B8),
      StepVisualState.ready => const Color(0xFF2563EB),
      StepVisualState.inProgress => const Color(0xFFF59E0B),
      StepVisualState.completed => const Color(0xFF16A34A),
    };

    final structureSignals = <String>[
      '${step.displayContentBlocks.length} blocks',
      if (step.hasImageBlock) 'image',
      if (step.hasAudioBlock) 'audio',
      if (step.quiz != null) 'quiz',
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 110,
                margin: const EdgeInsets.symmetric(vertical: 6),
                color: const Color(0xFFE2E8F0),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: access.canOpen ? onTap : null,
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.35,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                      children: [
                        TextSpan(text: step.title),
                        TextSpan(
                          text: '  ·  ${step.estimatedMinutes} min',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  RichContentText(
                    step.description,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MetaChip(label: '${step.xpReward} xp'),
                      _MetaChip(label: structureSignals.join(' / ')),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    access.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuizQuestionCard extends StatelessWidget {
  const _QuizQuestionCard({
    required this.question,
    required this.selectedIndex,
    required this.onSelect,
    required this.index,
  });

  final QuizQuestion question;
  final int? selectedIndex;
  final ValueChanged<int> onSelect;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question $index',
            style: const TextStyle(
              fontSize: 11,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1D4ED8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            question.prompt,
            style: const TextStyle(
              fontSize: 15,
              height: 1.45,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          ...question.options.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => onSelect(entry.key),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: selectedIndex == entry.key
                        ? const Color(0xFFE0F2FE)
                        : const Color(0xFFF8FAFC),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        selectedIndex == entry.key
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: selectedIndex == entry.key
                            ? const Color(0xFF1D4ED8)
                            : const Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF475569),
        ),
      ),
    );
  }
}
