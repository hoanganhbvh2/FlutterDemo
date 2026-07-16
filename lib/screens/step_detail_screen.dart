import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/roadmap.dart';
import '../providers/roadmap_provider.dart';
import '../widgets/rich_content.dart';

class StepDetailScreen extends StatelessWidget {
  const StepDetailScreen({
    super.key,
    required this.topicId,
    required this.lessonId,
    required this.stepId,
  });

  final String topicId;
  final String lessonId;
  final String stepId;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RoadmapProvider>();
    final lesson = provider.lessonById(topicId, lessonId);
    final step = provider.stepById(topicId, lessonId, stepId);

    if (lesson == null || step == null) {
      return const Scaffold(
        body: Center(child: Text('Step not found.')),
      );
    }

    final access = provider.stepAccessInfo(lesson: lesson, step: step);
    final checklistState = provider.checklistProgressFor(step.id).toSet();
    final canComplete = provider.isChecklistComplete(step) &&
        (step.quiz == null || provider.hasPassedQuiz(step.id)) &&
        (step.accessLevel != AccessLevel.rewarded ||
            provider.isPremiumUser ||
            provider.hasUnlockedRewardedStep(step.id));
    final isCompleted = provider.isStepCompleted(step.id);

    return PopScope<bool>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        Navigator.of(context).pop(true);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.of(context).pop(true),
          ),
          title: Text(
            step.title,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 2, 20, 32),
          children: [
            _StepHero(step: step),
            const SizedBox(height: 18),
            if (!access.canOpen)
              Text(
                access.message,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.55,
                  color: Color(0xFFB91C1C),
                  fontWeight: FontWeight.w600,
                ),
              )
            else ...[
              if (step.quiz != null && !provider.hasPassedQuiz(step.id)) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'When you return to the blog page, the quiz will appear immediately for this step.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: Color(0xFF1D4ED8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              _SectionLabel(
                title: 'Learning content',
                subtitle:
                    'This renderer is block-based so text, notes, images, audio, and code can be mixed freely later.',
              ),
              const SizedBox(height: 14),
              StepContentRenderer(
                blocks: step.displayContentBlocks,
              ),
              if (step.checklist.isNotEmpty) ...[
                const SizedBox(height: 28),
                const _SectionLabel(
                  title: 'Checklist',
                  subtitle: 'Complete the practical items before moving on.',
                ),
                const SizedBox(height: 10),
                ...step.checklist.asMap().entries.map(
                  (entry) => Container(
                    margin: EdgeInsets.only(
                      bottom: entry.key == step.checklist.length - 1 ? 0 : 6,
                    ),
                    child: CheckboxListTile(
                      value: checklistState.contains(entry.value.id),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: true,
                      title: RichContentText(
                        entry.value.text,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Color(0xFF334155),
                        ),
                      ),
                      onChanged: (_) {
                        provider.toggleChecklist(step: step, itemId: entry.value.id);
                      },
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 28),
              if (!isCompleted)
                FilledButton(
                  onPressed: canComplete
                      ? () async {
                          final messenger = ScaffoldMessenger.of(context);
                          await provider.markStepCompleted(step);
                          if (!context.mounted) {
                            return;
                          }
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Step marked as completed.'),
                            ),
                          );
                        }
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1D4ED8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text(
                    canComplete
                        ? 'Mark as completed'
                        : 'Finish the checklist and quiz first',
                  ),
                ),
              if (isCompleted)
                const Text(
                  'This step is complete. You can return to the step list and continue.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF166534),
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StepHero extends StatelessWidget {
  const _StepHero({required this.step});

  final StepNode step;

  @override
  Widget build(BuildContext context) {
    final mediaSignals = <String>[
      if (step.hasImageBlock) 'image',
      if (step.hasAudioBlock) 'audio',
      if (step.quiz != null) 'quiz',
      if (step.checklist.isNotEmpty) 'checklist',
    ];

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
          Text.rich(
            TextSpan(
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 24,
                height: 1.2,
                fontWeight: FontWeight.w800,
              ),
              children: [
                TextSpan(text: step.title),
                TextSpan(
                  text: '  ·  ${step.estimatedMinutes} min',
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
            step.description,
            style: const TextStyle(
              fontSize: 15,
              height: 1.65,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoBadge(label: '${step.xpReward} xp'),
              _InfoBadge(label: _accessLabel(step.accessLevel)),
              _InfoBadge(label: '${step.displayContentBlocks.length} blocks'),
              if (mediaSignals.isNotEmpty)
                _InfoBadge(label: mediaSignals.join(' / ')),
            ],
          ),
        ],
      ),
    );
  }

  String _accessLabel(AccessLevel accessLevel) {
    return switch (accessLevel) {
      AccessLevel.free => 'Open',
      AccessLevel.rewarded => 'Quiz + ad',
      AccessLevel.premium => 'Premium',
      AccessLevel.group => 'Group',
    };
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13,
            height: 1.5,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
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
