import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/roadmap.dart';
import '../providers/roadmap_provider.dart';
import '../widgets/popover_help_button.dart';
import '../widgets/rich_content.dart';

class StepDetailScreen extends StatefulWidget {
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
  State<StepDetailScreen> createState() => _StepDetailScreenState();
}

class _StepDetailScreenState extends State<StepDetailScreen> {
  late final Future<StepNode?> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = Provider.of<RoadmapProvider>(
      context,
      listen: false,
    ).loadStepDetail(widget.stepId);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RoadmapProvider>();

    return FutureBuilder<StepNode?>(
      future: _loadFuture,
      builder: (context, snapshot) {
        final lesson = provider.lessonById(widget.topicId, widget.lessonId);
        final step = provider.stepById(widget.topicId, widget.lessonId, widget.stepId);

        if (lesson == null || step == null) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return const Scaffold(
            body: Center(child: Text('Step not found.')),
          );
        }

        final access = provider.stepAccessInfo(lesson: lesson, step: step);
        final checklistState = provider.checklistProgressFor(step.id).toSet();
        final isChecklistDone = provider.isChecklistComplete(step);
        final isCompleted = provider.isStepCompleted(step.id);
        final hasQuizToTake = step.hasQuiz && !provider.hasPassedQuiz(step.id);
        final shouldPromptQuiz = isChecklistDone && hasQuizToTake;

        return PopScope<bool>(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              return;
            }
            Navigator.of(context).pop(shouldPromptQuiz);
          },
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Navigator.of(context).pop(shouldPromptQuiz),
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
                  _SectionLabel(
                    title: 'Learning content',
                    subtitle:
                        'This renderer is block-based so text, notes, images, audio, and code can be mixed freely later.',
                    helpTitle: step.hasQuiz ? 'Bài Quiz trắc nghiệm' : 'Hướng dẫn làm bài',
                    helpContent: step.hasQuiz && !provider.hasPassedQuiz(step.id)
                        ? 'Khi bạn đọc xong bài học, hoàn thành Checklist và quay lại danh sách bài học, bài Quiz trắc nghiệm sẽ tự động xuất hiện để bạn kiểm tra kiến thức và nhận thưởng XP!'
                        : 'Đọc kỹ nội dung lý thuyết, tham khảo mã nguồn mẫu và hoàn thành các mục thực hành trong Checklist bên dưới.',
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
                      (entry) {
                        final isChecked = checklistState.contains(entry.value.id);
                        return Container(
                          margin: EdgeInsets.only(
                            bottom: entry.key == step.checklist.length - 1 ? 0 : 8,
                          ),
                          decoration: BoxDecoration(
                            color: isChecked ? const Color(0xFFF0FDF4) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isChecked ? const Color(0xFF4EB748) : const Color(0xFFE2E8F0),
                              width: isChecked ? 1.5 : 1.0,
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              provider.toggleChecklist(
                                step: step,
                                itemId: entry.value.id,
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: Checkbox(
                                      value: isChecked,
                                      activeColor: const Color(0xFF4EB748),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      onChanged: (_) {
                                        provider.toggleChecklist(
                                          step: step,
                                          itemId: entry.value.id,
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: RichContentText(
                                        entry.value.text,
                                        style: TextStyle(
                                          fontSize: 14,
                                          height: 1.5,
                                          color: isChecked
                                              ? const Color(0xFF166534)
                                              : const Color(0xFF334155),
                                          decoration: isChecked ? TextDecoration.lineThrough : null,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 28),
                  if (!isCompleted)
                    FilledButton(
                      onPressed: isChecklistDone
                          ? () async {
                              final messenger = ScaffoldMessenger.of(context);
                              if (hasQuizToTake) {
                                Navigator.of(context).pop(true);
                              } else {
                                await provider.markStepCompleted(step);
                                if (!context.mounted) {
                                  return;
                                }
                                messenger.showSnackBar(
                                  SnackBar(
                                    backgroundColor: const Color(0xFF166534),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    content: Row(
                                      children: [
                                        const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            'Chúc mừng! Bạn đã hoàn thành bước học (+${step.xpReward} XP)',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                                Navigator.of(context).pop(false);
                              }
                            }
                          : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF124DA3),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        isChecklistDone
                            ? (hasQuizToTake
                                ? 'Hoàn thành & Làm Quiz nhận thưởng'
                                : 'Xác nhận hoàn thành')
                            : 'Hãy tích đủ Checklist bên trên',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  if (isCompleted)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF4EB748).withValues(alpha: 0.5), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4EB748).withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_rounded, color: Color(0xFF166534), size: 22),
                          SizedBox(width: 8),
                          Text(
                            'Bạn đã hoàn thành bước học này!',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF166534),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ],
            ),
          ),
        );
      },
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
      if (step.hasQuiz) 'quiz',
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
              if (mediaSignals.isNotEmpty) _InfoBadge(label: mediaSignals.join(' / ')),
            ],
          ),
        ],
      ),
    );
  }

  String _accessLabel(AccessLevel accessLevel) {
    return switch (accessLevel) {
      AccessLevel.free => 'Open',
      AccessLevel.rewarded => 'Quiz unlock',
      AccessLevel.premium => 'Premium',
      AccessLevel.group => 'Group',
    };
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.title,
    required this.subtitle,
    this.helpTitle,
    this.helpContent,
  });

  final String title;
  final String subtitle;
  final String? helpTitle;
  final String? helpContent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            if (helpTitle != null && helpContent != null) ...[
              const SizedBox(width: 8),
              PopoverHelpButton(
                title: helpTitle!,
                content: helpContent!,
              ),
            ],
          ],
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
