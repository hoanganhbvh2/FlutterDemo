import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/roadmap.dart';
import '../providers/roadmap_provider.dart';
import '../widgets/popover_help_button.dart';
import 'topic_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isCollapsed = false;
  Timer? _scrollTimer;

  @override
  void dispose() {
    _scrollTimer?.cancel();
    super.dispose();
  }

  void _onScroll(ScrollNotification notification) {
    if (notification is ScrollStartNotification || notification is ScrollUpdateNotification) {
      if (!_isCollapsed) {
        setState(() {
          _isCollapsed = true;
        });
      }
      _scrollTimer?.cancel();
      _scrollTimer = Timer(const Duration(milliseconds: 700), () {
        if (mounted) {
          setState(() {
            _isCollapsed = false;
          });
        }
      });
    } else if (notification is ScrollEndNotification) {
      _scrollTimer?.cancel();
      _scrollTimer = Timer(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _isCollapsed = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RoadmapProvider>();
    final user = provider.currentUser;
    final stats = provider.overallStats;
    final planLabel = switch (user?.plan) {
      LearningPlan.premium => 'Premium',
      LearningPlan.groupPro => 'Group Pro',
      _ => 'Free',
    };

    final groupTitle = () {
      if (user != null && user.groups.isNotEmpty) {
        return user.groups.first.title;
      }
      if (user != null && user.groupIds.isNotEmpty) {
        final match = provider.groups.where((g) => user.groupIds.contains(g.id)).firstOrNull;
        if (match != null) {
          return match.title;
        }
      }
      return null;
    }();

    return Scaffold(
      body: SafeArea(
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            _onScroll(notification);
            if (notification.metrics.pixels >= notification.metrics.maxScrollExtent - 250) {
              if (provider.hasMoreTopics) {
                provider.loadNextPage();
              }
            }
            return false;
          },

          child: Stack(
            children: [
              RefreshIndicator(
                onRefresh: provider.refreshData,
                color: const Color(0xFF124DA3),
                backgroundColor: Colors.white,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: const Color(0xFF124DA3).withValues(alpha: 0.12),
                          child: Text(
                            user?.avatar ?? 'Đ',
                            style: const TextStyle(
                              color: Color(0xFF124DA3),
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hi, ${user?.name.split(' ').first ?? 'Đạt'}',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            if (groupTitle != null && groupTitle.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                groupTitle,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFF37022),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/logo.png',
                        height: 48,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(18),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF7ED),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFF37022).withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              planLabel.toUpperCase(),
                              style: const TextStyle(
                                color: Color(0xFFF37022),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.auto_awesome_rounded,
                            color: Color(0xFFF37022),
                            size: 20,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Continue learning without a crowded or distracting interface.',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 18,
                          height: 1.35,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Pick a topic, open the blog you want, and continue step by step with quiz confirmation right after reading.',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 13,
                          height: 1.55,
                        ),
                      ),
                    ],
                  ),
                ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    title: 'Topics',
                    value: '${stats['topics']}',
                    helper: 'currently visible',
                    color: const Color(0xFF124DA3),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    title: 'Progress',
                    value: '${stats['percent']}%',
                    helper: 'across all steps',
                    color: const Color(0xFFF37022),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF124DA3).withValues(alpha: 0.06),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: TextEditingController(text: provider.searchQuery)
                  ..selection = TextSelection.collapsed(offset: provider.searchQuery.length),
                onChanged: (val) => provider.setSearchQuery(val),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm chủ đề, #tag hoặc mã bài học (vd: BLOG-00001)...',
                  hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8), fontWeight: FontWeight.w400),
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF124DA3), size: 22),
                  suffixIcon: provider.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.cancel_rounded, color: Color(0xFF94A3B8), size: 20),
                          onPressed: () => provider.setSearchQuery(''),
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF124DA3), width: 1.8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Category',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _CategoryChip(
                    label: 'All',
                    selected: provider.selectedCategoryId == null,
                    onTap: () => provider.setCategoryFilter(null),
                  ),
                  ...provider.categories.map(
                    (category) => Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: _CategoryChip(
                        label: category.title,
                        selected: provider.selectedCategoryId == category.id,
                        onTap: () => provider.setCategoryFilter(category.id),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text(
                  'Topics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(width: 8),
                const PopoverHelpButton(
                  title: 'Chủ đề Bài học (Topics)',
                  content:
                      'Danh sách chủ đề học tập được phân loại theo danh mục.\n\nChọn một Topic để xem chi tiết các bài viết (Blogs) và hoàn thành các bước học (Steps) tương ứng!',
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (provider.lastSyncError != null) ...[
              _LoadWarning(message: provider.lastSyncError!),
              const SizedBox(height: 12),
            ],
            if (provider.filteredTopics.isEmpty) ...[
              const _EmptyTopicsCard(),
              const SizedBox(height: 12),
            ],
            ...provider.visibleTopics.map(
              (topic) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _TopicCard(topic: topic),
              ),
            ),
            if (provider.hasMoreTopics) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Color(0xFF124DA3),
                    ),
                  ),
                ),
              ),
            ],


          ],
        ),
      ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
                right: _isCollapsed ? -42 : 14,
                bottom: 24,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isCollapsed = !_isCollapsed;
                    });
                  },
                  child: _FloatingVerticalStats(
                    streak: user?.streakDays ?? 0,
                    points: user?.gems ?? 0,
                    completed: stats['completed'] ?? 0,
                    isCollapsed: _isCollapsed,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({required this.topic});

  final Topic topic;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RoadmapProvider>();
    final progress = provider.topicProgress(topic);
    final topicTags = topic.tagDetails;
    final completedSteps = topic.lessons
        .expand((item) => item.steps)
        .where((item) => provider.isStepCompleted(item.id))
        .length;
    final totalSteps = topic.lessons.expand((item) => item.steps).length;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TopicDetailScreen(topicId: topic.id),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              topic.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              topic.levelLabel,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF124DA3),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              topic.description,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Color(0xFF475569),
              ),
            ),
            if (topicTags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: topicTags
                    .map((tag) => _TopicTagChip(
                          label: tag.title,
                          onTap: () => provider.setSearchQuery('#${tag.title}'),
                        ))
                    .toList(),
              ),
            ],

            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 9,
                backgroundColor: const Color(0xFFE2E8F0),
                color: const Color(0xFF4EB748),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '$completedSteps / $totalSteps steps completed / ${topic.lessons.length} blogs / ${topic.estimatedHours}h',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadWarning extends StatelessWidget {
  const _LoadWarning({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF37022).withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFF37022),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
                color: Color(0xFF7C2D12),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyTopicsCard extends StatelessWidget {
  const _EmptyTopicsCard();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RoadmapProvider>();
    final isFiltering =
        provider.selectedCategoryId != null || provider.searchQuery.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded, size: 40, color: Color(0xFF94A3B8)),
          const SizedBox(height: 10),
          Text(
            isFiltering
                ? 'Không tìm thấy bài học nào phù hợp với danh mục hoặc từ khóa tìm kiếm.'
                : 'Chưa có chủ đề bài học nào trên hệ thống.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Color(0xFF475569),
              fontWeight: FontWeight.w600,
            ),
          ),
          if (isFiltering) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                provider.setCategoryFilter(null);
                provider.setSearchQuery('');
              },
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Xóa bộ lọc'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF124DA3),
                side: const BorderSide(color: Color(0xFF124DA3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}


class _TopicTagChip extends StatelessWidget {
  const _TopicTagChip({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = label.startsWith('#') ? label : '#$label';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF124DA3).withValues(alpha: 0.2)),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF124DA3),
          ),
        ),
      ),
    );
  }
}


class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.helper,
    required this.color,
  });

  final String title;
  final String value;
  final String helper;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 3,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            helper,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF4EB748) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF4EB748) : const Color(0xFFE2E8F0),
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0xFF4EB748).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : const Color(0xFF334155),
            ),
          ),
        ),
      ),
    );
  }
}

class _FloatingVerticalStats extends StatelessWidget {
  const _FloatingVerticalStats({
    required this.streak,
    required this.points,
    required this.completed,
    this.isCollapsed = false,
  });

  final int streak;
  final int points;
  final int completed;
  final bool isCollapsed;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isCollapsed)
            const Padding(
              padding: EdgeInsets.only(right: 4),
              child: Icon(
                Icons.chevron_left_rounded,
                size: 18,
                color: Color(0xFF124DA3),
              ),
            ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _FloatingStatItem(
                icon: Icons.local_fire_department_rounded,
                iconColor: const Color(0xFFF37022),
                value: '$streak',
                label: 'Days',
              ),
              const SizedBox(height: 10),
              Container(height: 1, width: 26, color: const Color(0xFFF1F5F9)),
              const SizedBox(height: 10),
              _FloatingStatItem(
                icon: Icons.diamond_rounded,
                iconColor: const Color(0xFF124DA3),
                value: '$points',
                label: 'PTS',
              ),
              const SizedBox(height: 10),
              Container(height: 1, width: 26, color: const Color(0xFFF1F5F9)),
              const SizedBox(height: 10),
              _FloatingStatItem(
                icon: Icons.check_circle_rounded,
                iconColor: const Color(0xFF4EB748),
                value: '$completed',
                label: 'Done',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FloatingStatItem extends StatelessWidget {
  const _FloatingStatItem({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}
