import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/roadmap.dart';
import '../providers/roadmap_provider.dart';
import '../utils/illustration_utils.dart';
import '../utils/step_utils.dart';

class StepDetailBottomSheet extends StatefulWidget {
  const StepDetailBottomSheet({Key? key}) : super(key: key);

  @override
  State<StepDetailBottomSheet> createState() => _StepDetailBottomSheetState();
}

class _StepDetailBottomSheetState extends State<StepDetailBottomSheet> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _emojiController;
  late TextEditingController _orderController;
  late TextEditingController _codeSnippetController;
  late TextEditingController _codeLanguageController;
  late TextEditingController _imageUrlController;
  late StepStatus _status;

  bool _isEditing = false;
  String _activeSubTab = "theory"; // "theory" | "code"
  bool _copied = false;
  String? _initializedStepId;

  @override
  void initState() {
    super.initState();
    _autoHydrateStepData();
  }

  void _autoHydrateStepData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = Provider.of<RoadmapProvider>(context, listen: false);
      final step = provider.selectedStep;
      if (step != null) {
        bool needsUpdate = false;
        List<ChecklistItem>? checklist = step.checklist;
        String? snippet = step.codeSnippet;
        String? language = step.codeLanguage;

        if (checklist == null || checklist.isEmpty) {
          checklist = getDefaultChecklist(step.title, step.id);
          needsUpdate = true;
        }
        if (snippet == null || snippet.isEmpty) {
          final codeData = getStepCodeSnippet(step.title);
          snippet = codeData.code;
          language = codeData.language;
          needsUpdate = true;
        }

        if (needsUpdate) {
          provider.updateStep(
            step.id,
            checklist: checklist,
            codeSnippet: snippet,
            codeLanguage: language,
          );
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final step = Provider.of<RoadmapProvider>(context).selectedStep;
    if (step != null && step.id != _initializedStepId) {
      _initializedStepId = step.id;
      _titleController = TextEditingController(text: step.title);
      _descController = TextEditingController(text: step.description);
      _emojiController = TextEditingController(text: step.emoji);
      _orderController = TextEditingController(text: step.order.toString());
      _codeSnippetController = TextEditingController(text: step.codeSnippet ?? '');
      _codeLanguageController = TextEditingController(text: step.codeLanguage ?? '');
      _imageUrlController = TextEditingController(text: step.imageUrl ?? '');
      _status = step.status;
      _isEditing = false;
      _activeSubTab = "theory";
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _emojiController.dispose();
    _orderController.dispose();
    _codeSnippetController.dispose();
    _codeLanguageController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final provider = Provider.of<RoadmapProvider>(context, listen: false);
    final step = provider.selectedStep;
    if (step != null) {
      provider.updateStep(
        step.id,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        emoji: _emojiController.text.trim(),
        order: int.tryParse(_orderController.text) ?? step.order,
        codeSnippet: _codeSnippetController.text,
        codeLanguage: _codeLanguageController.text.trim(),
        imageUrl: _imageUrlController.text.trim(),
      );
      setState(() {
        _isEditing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RoadmapProvider>(context);
    final step = provider.selectedStep;

    if (step == null) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: Text('Không tìm thấy khái niệm học tập.'),
        ),
      );
    }

    final titleParts = step.title.split('/');
    final viTitle = titleParts[0].trim();
    final enTitle = titleParts.length > 1 ? titleParts[1].trim() : null;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: AnimatedPadding(
          padding: MediaQuery.of(context).viewInsets,
          duration: const Duration(milliseconds: 100),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pull indicator bar
              Container(
                width: 48,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // Drawer Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7ED),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFFEDD5)),
                          ),
                          child: Text(
                            step.emoji,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'KHÁI NIỆM BÀI HỌC',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFEA580C),
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              'Mã số: ${step.id.length > 5 ? step.id.substring(5) : step.id}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF64748B),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF94A3B8), size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 16, color: Color(0xFFF1F5F9)),

              // Scrollable Body Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Tracker Card
                      _buildStatusTracker(provider, step),
                      const SizedBox(height: 16),

                      if (_isEditing)
                        _buildEditPane(step)
                      else
                        _buildViewPane(step, viTitle, enTitle),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusTracker(RoadmapProvider provider, StepNode step) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TRẠNG THÁI HỌC TẬP',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatusButton(
                  isActive: _status == StepStatus.notStarted,
                  label: 'Chưa học',
                  activeBgColor: const Color(0xFFEA580C),
                  onTap: () {
                    setState(() => _status = StepStatus.notStarted);
                    provider.updateStep(step.id, status: StepStatus.notStarted);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatusButton(
                  isActive: _status == StepStatus.inProgress,
                  label: 'Đang học',
                  activeBgColor: const Color(0xFFD97706),
                  onTap: () {
                    setState(() => _status = StepStatus.inProgress);
                    provider.updateStep(step.id, status: StepStatus.inProgress);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatusButton(
                  isActive: _status == StepStatus.completed,
                  label: 'Hoàn thành',
                  activeBgColor: const Color(0xFF059669),
                  onTap: () {
                    setState(() => _status = StepStatus.completed);
                    provider.updateStep(step.id, status: StepStatus.completed);
                  },
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatusButton({
    required bool isActive,
    required String label,
    required Color activeBgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? activeBgColor : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? activeBgColor : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildViewPane(StepNode step, String viTitle, String? enTitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Graphic Banner Illustration
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 120,
            width: double.infinity,
            color: const Color(0xFFF1F5F9),
            child: Image.network(
              step.imageUrl != null && step.imageUrl!.isNotEmpty
                  ? step.imageUrl!
                  : getStepIllustration(step.title, step.order),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: const Color(0xFFFFEDD5),
                child: Center(
                  child: Text(
                    step.emoji,
                    style: const TextStyle(fontSize: 48),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Title Section
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    viTitle,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  if (enTitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      enTitle,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      border: Border.all(color: const Color(0xFFFFE4E6)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Bước ${step.order}'.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFEA580C),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
        const SizedBox(height: 16),

        // Custom Sub Tabs (Theory vs Code)
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => setState(() => _activeSubTab = "theory"),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: _activeSubTab == "theory"
                            ? const Color(0xFFEA580C)
                            : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                  ),
                  child: Text(
                    'LÝ THUYẾT & CHECKLIST',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _activeSubTab == "theory"
                          ? const Color(0xFFEA580C)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () => setState(() => _activeSubTab = "code"),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: _activeSubTab == "code"
                            ? const Color(0xFFEA580C)
                            : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                  ),
                  child: Text(
                    'MÃ NGUỒN MINH HỌA',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _activeSubTab == "code"
                          ? const Color(0xFFEA580C)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Sub Tab Contents
        if (_activeSubTab == "theory")
          _buildTheoryTab(step)
        else
          _buildCodeTab(step),
      ],
    );
  }

  Widget _buildTheoryTab(StepNode step) {
    final provider = Provider.of<RoadmapProvider>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tài liệu & Hướng dẫn học tập',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Text(
            step.description.isNotEmpty
                ? step.description
                : 'Chưa bổ sung mô tả học tập cho khái niệm này.',
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF334155),
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 20),

        Row(
          children: const [
            Icon(Icons.assignment_turned_in, color: Color(0xFF10B981), size: 14),
            SizedBox(width: 6),
            Text(
              'Checklist Việc cần làm (To-Do Checklist)',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFF059669),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: step.checklist == null || step.checklist!.isEmpty
              ? const Center(
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                'Đang khởi tạo mục tiêu học tập...',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ),
          )
              : ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: step.checklist!.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = step.checklist![index];
              return InkWell(
                onTap: () {
                  final updatedList = List<ChecklistItem>.from(step.checklist!);
                  updatedList[index] = ChecklistItem(
                    id: item.id,
                    text: item.text,
                    completed: !item.completed,
                  );
                  provider.updateStep(step.id, checklist: updatedList);
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      item.completed
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      color: item.completed
                          ? const Color(0xFF10B981)
                          : const Color(0xFF94A3B8),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.text,
                        style: TextStyle(
                          fontSize: 10.5,
                          color: item.completed
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF334155),
                          decoration: item.completed
                              ? TextDecoration.lineThrough
                              : null,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCodeTab(StepNode step) {
    final lines = (step.codeSnippet ?? '').split('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Khung mã nguồn phông chữ JetBrains Mono',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 8),

        // Code Editor IDE Style Box
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1E293B)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Editor header with title and Copy Button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: const BoxDecoration(
                  color: Color(0xFF1E293B),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'example.${(step.codeLanguage?.isNotEmpty == true ? step.codeLanguage : "dart")!.toLowerCase()}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFDBA74),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: step.codeSnippet ?? ''));
                        setState(() {
                          _copied = true;
                        });
                        Future.delayed(const Duration(seconds: 2), () {
                          if (mounted) {
                            setState(() {
                              _copied = false;
                            });
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _copied ? const Color(0xFF064E3B) : const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: _copied ? const Color(0xFF10B981) : const Color(0xFF334155),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _copied ? Icons.check : Icons.copy,
                              size: 10,
                              color: _copied ? const Color(0xFF34D399) : const Color(0xFF94A3B8),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _copied ? 'Đã chép!' : 'Sao chép',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: _copied ? const Color(0xFF34D399) : const Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),

              // Code viewer scroll panel
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: const Color(0xFF05070C),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Gutter numbers
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(
                          lines.length,
                              (index) => Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 10,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 1,
                        height: lines.length * 15.0 + 10.0,
                        color: const Color(0xFF1E293B),
                      ),
                      const SizedBox(width: 12),
                      // Text code
                      Text(
                        step.codeSnippet ?? '',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          color: Color(0xFFFFEDD5),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditPane(StepNode step) {
    final imagePresets = [
      { "name": "💻 Lập trình", "url": "https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=500&auto=format&fit=crop&q=80" },
      { "name": "📱 Giao diện", "url": "https://images.unsplash.com/photo-1541462608141-27b2c7453c6f?w=500&auto=format&fit=crop&q=80" },
      { "name": "☁️ Máy chủ", "url": "https://images.unsplash.com/photo-1544383835-bda2bc66a55d?w=500&auto=format&fit=crop&q=80" },
      { "name": "📊 Biểu đồ", "url": "https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=500&auto=format&fit=crop&q=80" },
      { "name": "🧠 AI / LLM", "url": "https://images.unsplash.com/photo-1620712943543-bcc4688e7485?w=500&auto=format&fit=crop&q=80" },
      { "name": "🎨 Ý tưởng", "url": "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=500&auto=format&fit=crop&q=80" }
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CHỈNH SỬA THÔNG TIN',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFFEA580C),
            ),
          ),
          const SizedBox(height: 16),

          // Title input
          const Text('Tiêu đề khái niệm', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
          const SizedBox(height: 4),
          TextField(
            controller: _titleController,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              isDense: true,
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 12),

          // Emoji and Order
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Emoji đại diện', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _emojiController,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 11),
                      decoration: InputDecoration(
                        isDense: true,
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Thứ tự hiển thị', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _orderController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 11),
                      decoration: InputDecoration(
                        isDense: true,
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Description
          const Text('Mô tả lý thuyết', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
          const SizedBox(height: 4),
          TextField(
            controller: _descController,
            maxLines: 4,
            style: const TextStyle(fontSize: 11, height: 1.4),
            decoration: InputDecoration(
              isDense: true,
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 12),

          // Code language
          const Text('Ngôn ngữ minh họa', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
          const SizedBox(height: 4),
          TextField(
            controller: _codeLanguageController,
            style: const TextStyle(fontSize: 11),
            decoration: InputDecoration(
              isDense: true,
              fillColor: Colors.white,
              filled: true,
              hintText: 'dart / java / html / css / javascript / python',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 12),

          // Custom Image URL
          const Text('Ảnh minh họa (URL)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
          const SizedBox(height: 4),
          TextField(
            controller: _imageUrlController,
            style: const TextStyle(fontSize: 10),
            decoration: InputDecoration(
              isDense: true,
              fillColor: Colors.white,
              filled: true,
              hintText: 'https://images.unsplash.com/...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 8),

          // Image presets
          const Text('Chọn nhanh ảnh mẫu:', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: imagePresets.map((preset) {
              final isSelected = _imageUrlController.text == preset['url'];
              return InkWell(
                onTap: () {
                  setState(() {
                    _imageUrlController.text = preset['url']!;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFFFF7ED) : Colors.white,
                    border: Border.all(
                      color: isSelected ? const Color(0xFFFDBA74) : const Color(0xFFE2E8F0),
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    preset['name']!,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? const Color(0xFFEA580C) : const Color(0xFF475569),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Code Snippet block
          const Text('Ví dụ Code minh họa', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
          const SizedBox(height: 4),
          TextField(
            controller: _codeSnippetController,
            maxLines: 6,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 10),
            decoration: InputDecoration(
              isDense: true,
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 20),

          // Save and Cancel buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => setState(() => _isEditing = false),
                child: const Text(
                  'Hủy bỏ',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEA580C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'Lưu thay đổi',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
