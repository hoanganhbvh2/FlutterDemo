import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/roadmap.dart';
import '../providers/auth_provider.dart';
import '../providers/plan_request_provider.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: () => context.read<AuthProvider>().logout(),
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Log out',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final planRequests = context.read<PlanRequestProvider>();
          await provider.refreshData();
          await planRequests.fetchMyPlanRequests();
        },
        color: const Color(0xFF4EB748),
        backgroundColor: Colors.white,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            // User Header Card
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
                    backgroundColor: const Color(0xFF4EB748).withValues(alpha: 0.15),
                    child: Text(
                      user.avatar,
                      style: const TextStyle(
                        color: Color(0xFF4EB748),
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
                            color: const Color(0xFF4EB748).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            planLabel,
                            style: const TextStyle(
                              color: Color(0xFF4EB748),
                              fontWeight: FontWeight.w800,
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

            // Metrics Cards
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

            // Plan Request Section & History Accordions
            const _PlanRequestSection(),
          ],
        ),
      ),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanRequestSection extends StatefulWidget {
  const _PlanRequestSection();

  @override
  State<_PlanRequestSection> createState() => _PlanRequestSectionState();
}

class _PlanRequestSectionState extends State<_PlanRequestSection> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _contentController;

  bool _isSubmitting = false;
  String? _statusMessage;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<RoadmapProvider>().currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController();
    _contentController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlanRequestProvider>().fetchMyPlanRequests();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _statusMessage = null;
    });

    final planProvider = context.read<PlanRequestProvider>();
    final error = await planProvider.submitPlanRequest(
      name: _nameController.text,
      phone: _phoneController.text,
      content: _contentController.text,
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
      if (error == null) {
        _isError = false;
        _statusMessage = 'Gửi yêu cầu nâng cấp thành công! Ban quản trị sẽ phản hồi sớm.';
        _contentController.clear();
        _phoneController.clear();
      } else {
        _isError = true;
        _statusMessage = error;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlanRequestProvider>();
    final myRequests = provider.myRequests;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Accordion 1: Form Gửi Yêu Cầu Nâng Cấp Premium
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: false,
              tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF4EB748).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.stars_rounded,
                  color: Color(0xFF4EB748),
                  size: 22,
                ),
              ),
              title: Row(
                children: const [
                  Expanded(
                    child: Text(
                      'Gửi Yêu Cầu Nâng Cấp Premium',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  PopoverHelpButton(
                    title: 'Yêu cầu nâng cấp Premium',
                    content:
                        'Gửi thông tin cho Ban quản trị để nâng cấp tài khoản lên gói PREMIUM. Sau khi duyệt, toàn bộ bài học khóa sẽ tự động mở.',
                  ),
                ],
              ),
              subtitle: const Text(
                'Đăng ký tài khoản Premium để mở khóa toàn bộ bài học',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              children: [
                const SizedBox(height: 12),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _FieldLabel(label: 'Họ và tên'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
                        decoration: _inputDecoration(hintText: 'Nhập họ và tên'),
                        validator: (v) => (v ?? '').trim().isEmpty ? 'Vui lòng nhập họ và tên' : null,
                      ),
                      const SizedBox(height: 14),

                      const _FieldLabel(label: 'Số điện thoại'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
                        decoration: _inputDecoration(hintText: 'Nhập số điện thoại liên hệ'),
                        validator: (v) => (v ?? '').trim().isEmpty ? 'Vui lòng nhập số điện thoại' : null,
                      ),
                      const SizedBox(height: 14),

                      const _FieldLabel(label: 'Nội dung / Lý do yêu cầu'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _contentController,
                        maxLines: 3,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
                        decoration: _inputDecoration(hintText: 'Nhập lý do hoặc thông tin chuyển khoản nâng cấp...'),
                        validator: (v) => (v ?? '').trim().isEmpty ? 'Vui lòng nhập nội dung yêu cầu' : null,
                      ),

                      if (_statusMessage != null) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: _isError ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _isError ? const Color(0xFFFCA5A5) : const Color(0xFF86EFAC),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
                                color: _isError ? const Color(0xFF991B1B) : const Color(0xFF166534),
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _statusMessage!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: _isError ? const Color(0xFF991B1B) : const Color(0xFF166534),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: FilledButton.icon(
                          onPressed: _isSubmitting ? null : _submitRequest,
                          icon: _isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.send_rounded, size: 18),
                          label: Text(
                            _isSubmitting ? 'Đang gửi...' : 'Gửi Yêu Cầu Nâng Cấp',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF4EB748),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Accordion 2: Lịch Sử Yêu Cầu Của Tôi
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: true,
              tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF124DA3).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.history_rounded, color: Color(0xFF124DA3), size: 20),
              ),
              title: Row(
                children: [
                  Text(
                    'Lịch Sử Yêu Cầu Của Tôi (${myRequests.length})',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              subtitle: const Text(
                'Kiểm tra kết quả duyệt & phản hồi từ Admin',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => context.read<PlanRequestProvider>().fetchMyPlanRequests(),
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('Làm mới'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF124DA3),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                if (myRequests.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: const [
                        Icon(Icons.inbox_outlined, color: Color(0xFF94A3B8), size: 36),
                        SizedBox(height: 8),
                        Text(
                          'Bạn chưa gửi yêu cầu nâng cấp nào.',
                          style: TextStyle(fontSize: 13.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: myRequests.length,
                    separatorBuilder: (_, index) => const SizedBox(height: 12),

                    itemBuilder: (context, index) {
                      final req = myRequests[index];
                      final status = req.status.toUpperCase();
                      final name = req.name;
                      final phone = req.phone;
                      final content = req.content;
                      final adminNote = req.adminNote;
                      final createdAt = req.createdAt.split('T').first;

                      final (statusLabel, statusBg, statusFg, statusIcon) = switch (status) {
                        'APPROVED' => ('ĐÃ DUYỆT', const Color(0xFFDCFCE7), const Color(0xFF15803D), Icons.check_circle_rounded),
                        'REJECTED' => ('TỪ CHỐI', const Color(0xFFFEE2E2), const Color(0xFFB91C1C), Icons.cancel_rounded),
                        _ => ('ĐANG CHỜ DUYỆT', const Color(0xFFFEF3C7), const Color(0xFFB45309), Icons.pending_rounded),
                      };

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Ticket #${req.id}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: statusBg,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(statusIcon, size: 14, color: statusFg),
                                      const SizedBox(width: 4),
                                      Text(
                                        statusLabel,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: statusFg,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Người gửi: $name ($phone)',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Text(
                                content,
                                style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4),
                              ),
                            ),
                            if (adminNote != null && adminNote.toString().isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0F9FF),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFBAE6FD)),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF0284C7)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Phản hồi Admin: $adminNote',
                                        style: const TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF0369A1),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Text(
                              'Ngày gửi: $createdAt',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({required String hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF4EB748), width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFDC2626)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.8),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF334155),
      ),
    );
  }
}
