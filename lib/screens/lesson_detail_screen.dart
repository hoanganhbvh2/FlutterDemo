import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/roadmap.dart';
import '../providers/roadmap_provider.dart';
import '../widgets/popover_help_button.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<RoadmapProvider>().fetchTopicDetail(widget.topicId);
      }
    });
  }

  Future<void> _openStep({
    required RoadmapProvider provider,
    required Lesson lesson,
    required StepNode step,
  }) async {
    final access = provider.stepAccessInfo(lesson: lesson, step: step);
    if (!access.canOpen) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StepDetailScreen(
          topicId: widget.topicId,
          lessonId: lesson.id,
          stepId: step.id,
        ),
      ),
    );

    if (!mounted) return;
    // Refresh UI to show updated step completion state
    setState(() {});
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
              margin: const EdgeInsets.only(top: 14, bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock_outline_rounded, size: 18, color: Color(0xFFD97706)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Bài học này yêu cầu quyền truy cập',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF92400E),
                      ),
                    ),
                  ),
                  PopoverHelpButton(
                    title: 'Giới hạn Truy cập',
                    content:
                        'Bài học này nằm trong luồng giới hạn nội dung.\n\nVui lòng nâng cấp tài khoản Premium hoặc gia nhập đúng Nhóm học (Group) để mở khóa đầy đủ.',
                    iconColor: Color(0xFFD97706),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Text(
                'Step list',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 8),
              const PopoverHelpButton(
                title: 'Quy trình thực hiện Bài học',
                content:
                    'Học theo thứ tự từng Step để mở khóa nội dung tiếp theo.\n\nSau khi đọc lý thuyết & hoàn thành Checklist ở từng Step, hãy quay lại đây để làm Quiz trắc nghiệm mở khóa bước tiếp theo!',
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (lesson.steps.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Center(
                child: Text(
                  'Bài học này hiện chưa có bước học (Step) nào.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          else
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
              color: Color(0xFF124DA3),
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
                    color: const Color(0xFF4EB748),
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
      StepVisualState.ready => const Color(0xFF124DA3),
      StepVisualState.inProgress => const Color(0xFFF37022),
      StepVisualState.completed => const Color(0xFF4EB748),
    };

    final structureSignals = <String>[
      '${step.displayContentBlocks.length} blocks',
      if (step.hasImageBlock) 'image',
      if (step.hasAudioBlock) 'audio',
      if (step.hasQuiz) 'quiz',
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: access.state == StepVisualState.completed
                    ? const Color(0xFF4EB748)
                    : color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                boxShadow: access.state == StepVisualState.completed
                    ? [
                        BoxShadow(
                          color: const Color(0xFF4EB748).withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: access.state == StepVisualState.completed
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 20,
                    )
                  : Text(
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
                color: access.state == StepVisualState.completed
                    ? const Color(0xFF4EB748).withValues(alpha: 0.4)
                    : const Color(0xFFE2E8F0),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: access.canOpen ? onTap : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: access.state == StepVisualState.completed
                    ? const Color(0xFFF0FDF4)
                    : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: access.state == StepVisualState.completed
                      ? const Color(0xFF4EB748).withValues(alpha: 0.45)
                      : const Color(0xFFE2E8F0),
                  width: access.state == StepVisualState.completed ? 1.5 : 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text.rich(
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
                      ),
                      if (access.state == StepVisualState.completed) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4EB748).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFF4EB748).withValues(alpha: 0.35),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                size: 12,
                                color: Color(0xFF166534),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Đã hoàn thành',
                                style: TextStyle(
                                  fontSize: 10,
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
