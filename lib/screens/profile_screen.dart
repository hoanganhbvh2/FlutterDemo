import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/roadmap.dart';
import '../providers/roadmap_provider.dart';
import '../widgets/popover_help_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RoadmapProvider>();
    final user = provider.currentUser;
    final stats = provider.overallStats;

    if (user == null) {
      return const SizedBox.shrink();
    }

    final groupTitles = provider.groups
        .where((group) => user.groupIds.contains(group.id))
        .map((group) => group.title)
        .toList();

    final planLabel = switch (user.plan) {
      LearningPlan.free => 'Free',
      LearningPlan.premium => 'Premium',
      LearningPlan.groupPro => 'Group Pro',
    };
    final planDescription = switch (user.plan) {
      LearningPlan.free =>
        'Best for open content, quiz participation, and unlocking extra material through rewarded ads.',
      LearningPlan.premium =>
        'Includes access to premium blogs without needing rewarded ad unlocks.',
      LearningPlan.groupPro =>
        'Designed for private learner groups with access to program-specific content.',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: provider.logout,
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Log out',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: provider.refreshData,
        color: const Color(0xFF124DA3),
        backgroundColor: Colors.white,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: const Color(0xFF124DA3).withValues(alpha: 0.12),
                  child: Text(
                    user.avatar,
                    style: const TextStyle(
                      color: Color(0xFF124DA3),
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF124DA3).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          planLabel,
                          style: const TextStyle(
                            color: Color(0xFF124DA3),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'Streak',
                  value: '${user.streakDays} days',
                  color: const Color(0xFFF37022),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  title: 'Points',
                  value: '${user.gems}',
                  color: const Color(0xFFF37022),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'Completed',
                  value: '${stats['completed']} steps',
                  color: const Color(0xFF4EB748),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  title: 'Groups',
                  value: '${groupTitles.length}',
                  color: const Color(0xFF124DA3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Current access level',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const PopoverHelpButton(
                      title: 'Quyền truy cập & Nhóm học',
                      content:
                          '• FREE: Truy cập toàn bộ các bài học cơ bản miễn phí.\n\n• PREMIUM: Mở khóa tất cả bài học nâng cao mà không cần xem quảng cáo.\n\n• GROUP: Dành riêng cho học viên thuộc các lớp / nhóm được cấp mã kích hoạt.',
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  planDescription,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.55,
                    color: Color(0xFF475569),
                  ),
                ),
                if (groupTitles.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Active groups: ${groupTitles.join(', ')}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF334155),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showRedeemCodeDialog(context, provider),
                    icon: const Icon(Icons.vpn_key_outlined, size: 18),
                    label: const Text('Join Group / Redeem Access Code'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF124DA3),
                      side: const BorderSide(color: Color(0xFF124DA3)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ],
        ),
      ),
    );
  }

  void _showRedeemCodeDialog(BuildContext context, RoadmapProvider provider) {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Redeem Code / Group Access',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter an invite code or group key to unlock specialized topics.',
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'e.g. VIP-GROUP-2026',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final code = controller.text.trim();
                Navigator.of(dialogContext).pop();
                if (code.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Access code "$code" redeemed successfully.'),
                    ),
                  );
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF124DA3),
              ),
              child: const Text('Redeem'),
            ),
          ],
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.color,
  });

  final String title;
  final String value;
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
            width: 24,
            height: 3,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
