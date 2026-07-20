import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/roadmap.dart';
import '../providers/roadmap_provider.dart';
import '../widgets/popover_help_button.dart';
import '../widgets/rich_content.dart';
import 'lesson_detail_screen.dart';

class TopicDetailScreen extends StatelessWidget {
  const TopicDetailScreen({
    super.key,
    required this.topicId,
  });

  final String topicId;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RoadmapProvider>();
    final topic = provider.topicById(topicId);

    if (topic == null) {
      return const Scaffold(
        body: Center(child: Text('Topic not found.')),
      );
    }

    final progress = provider.topicProgress(topic);
    final topicTags =
        provider.categories.where((item) => topic.tagIds.contains(item.id)).toList();
    final totalSteps = topic.lessons.fold<int>(
      0,
      (sum, lesson) => sum + lesson.steps.length,
    );
    final mediaSteps = topic.lessons
        .expand((lesson) => lesson.steps)
        .where((step) => step.hasImageBlock || step.hasAudioBlock)
        .length;

    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFFF7ED),
                  Color(0xFFFFEDD5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFF37022).withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF37022).withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topic.title,
                  style: const TextStyle(
                    fontSize: 30,
                    height: 1.1,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 10),
                RichContentText(
                  topic.description,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _MetaPill(label: topic.levelLabel, isOrange: true),
                    _MetaPill(label: '${topic.lessons.length} blogs'),
                    _MetaPill(label: '$totalSteps steps'),
                    _MetaPill(label: '${(progress * 100).round()}% complete'),
                  ],
                ),
                if (topicTags.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: topicTags
                        .map((tag) => _MetaPill(label: '#${tag.title}', isOrange: true))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF37022).withValues(alpha: 0.25)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF37022).withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: _SignalColumn(
                      icon: Icons.schedule_rounded,
                      iconColor: const Color(0xFFF37022),
                      label: 'Estimated time',
                      value: '${topic.estimatedHours}h total',
                    ),
                  ),
                  const VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: Color(0xFFFED7AA),
                  ),
                  Expanded(
                    child: _SignalColumn(
                      icon: Icons.auto_stories_rounded,
                      iconColor: const Color(0xFFF37022),
                      label: 'Content mode',
                      value: mediaSteps == 0 ? 'Text-first' : 'Mixed media',
                    ),
                  ),
                  const VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: Color(0xFFFED7AA),
                  ),
                  Expanded(
                    child: _SignalColumn(
                      icon: Icons.account_tree_rounded,
                      iconColor: const Color(0xFFF37022),
                      label: 'Structure',
                      value: '${topic.lessons.length} blogs • $totalSteps steps',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text(
                'Blogs',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 8),
              const PopoverHelpButton(
                title: 'Các bài học (Blogs)',
                content:
                    'Mỗi Blog bao gồm một chuỗi các bước (Steps) xây dựng kiến thức bài bản.\n\nNhấn vào từng Blog để bắt đầu làm bài, đọc lý thuyết, thực hành code và giải Quiz củng cố kiến thức.',
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...topic.lessons.map(
            (lesson) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _LessonCard(
                topic: topic,
                lesson: lesson,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({
    required this.topic,
    required this.lesson,
  });

  final Topic topic;
  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RoadmapProvider>();
    final canAccess = provider.canAccessLesson(lesson);
    final progress = provider.lessonProgress(lesson);
    final accessLabel = switch (lesson.accessLevel) {
      AccessLevel.free => 'Open',
      AccessLevel.rewarded => 'Quiz + unlock',
      AccessLevel.premium => 'Premium',
      AccessLevel.group => 'Group',
    };

    final hasMedia = lesson.steps.any((step) => step.hasImageBlock || step.hasAudioBlock);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => LessonDetailScreen(
              topicId: topic.id,
              lessonId: lesson.id,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
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
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                      children: [
                        TextSpan(text: lesson.title),
                        TextSpan(
                          text: '  ·  ${lesson.steps.length} steps',
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: canAccess
                        ? const Color(0xFF4EB748).withValues(alpha: 0.12)
                        : const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    accessLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: canAccess
                          ? const Color(0xFF166534)
                          : const Color(0xFFB91C1C),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            RichContentText(
              lesson.description,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MetaPill(label: '${lesson.estimatedMinutes} min'),
                _MetaPill(label: hasMedia ? 'Mixed media capable' : 'Text-first'),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: const Color(0xFFE2E8F0),
                color: const Color(0xFF4EB748),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignalColumn extends StatelessWidget {
  const _SignalColumn({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: iconColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({
    required this.label,
    this.isOrange = false,
  });

  final String label;
  final bool isOrange;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isOrange ? const Color(0xFFF37022) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOrange ? const Color(0xFFF37022) : const Color(0xFFFED7AA),
        ),
        boxShadow: isOrange
            ? [
                BoxShadow(
                  color: const Color(0xFFF37022).withValues(alpha: 0.25),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isOrange ? Colors.white : const Color(0xFF9A3412),
        ),
      ),
    );
  }
}
