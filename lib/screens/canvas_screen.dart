import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/roadmap.dart';
import '../providers/roadmap_provider.dart';
import '../utils/illustration_utils.dart';
import '../widgets/step_detail_bottom_sheet.dart';

class CanvasScreen extends StatelessWidget {
  const CanvasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RoadmapProvider>(context);
    final lesson = provider.selectedLesson;

    if (lesson == null) {
      return const Scaffold(
        body: Center(child: Text('Không tìm thấy bài học được chọn.')),
      );
    }

    // Sort nodes sequentially
    final sortedNodes = List<StepNode>.from(lesson.nodes)
      ..sort((a, b) => a.order.compareTo(b.order));

    final totalCount = sortedNodes.length;
    final completedCount = sortedNodes.where((e) => e.status == StepStatus.completed).length;
    final inProgressCount = sortedNodes.where((e) => e.status == StepStatus.inProgress).length;
    final notStartedCount = totalCount - completedCount - inProgressCount;
    
    final percentCompleted = totalCount > 0 ? ((completedCount / totalCount) * 100).round() : 0;
    final percentInProgress = totalCount > 0 ? ((inProgressCount / totalCount) * 100).round() : 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sơ đồ Roadmap',
              style: TextStyle(color: Colors.grey, fontSize: 8, fontWeight: FontWeight.bold),
            ),
            Text(
              lesson.title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w900),
            )
          ],
        ),
      ),
      body: Column(
        children: [
          // Sub-Header: Progress Metrics & Adding concept
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.bookmark_outline, color: Colors.deepOrange, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Tiến trình Khái niệm ($completedCount/$totalCount)',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xFF0F172A)),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Multi-colored progress line
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Container(
                    height: 8,
                    width: double.infinity,
                    color: const Color(0xFFF1F5F9),
                    child: Row(
                      children: [
                        if (percentCompleted > 0)
                          Expanded(
                            flex: percentCompleted,
                            child: Container(color: const Color(0xFF10B981)),
                          ),
                        if (percentInProgress > 0)
                          Expanded(
                            flex: percentInProgress,
                            child: Container(color: Colors.amber),
                          ),
                        if (notStartedCount > 0)
                          Expanded(
                            flex: (100 - percentCompleted - percentInProgress).clamp(0, 100),
                            child: Container(color: const Color(0xFFE2E8F0)),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                
                // Legends description
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildLegendItem(const Color(0xFF10B981), 'Hoàn thành: $percentCompleted%'),
                    _buildLegendItem(Colors.amber, 'Đang học: $inProgressCount'),
                    _buildLegendItem(Colors.grey, 'Chưa học: $notStartedCount'),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // Main Roadmap Steps Area
          Expanded(
            child: sortedNodes.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.help_outline, color: Colors.grey, size: 48),
                          const SizedBox(height: 16),
                          const Text(
                            'Chưa có khái niệm nào',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Bài học này chưa có khái niệm nào được thiết lập.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  )
                : Stack(
                    children: [
                      // Centered vertical dotted flow trail line
                      Positioned(
                        top: 24,
                        bottom: 24,
                        left: MediaQuery.of(context).size.width / 2 - 1,
                        child: CustomPaint(
                          size: const Size(2, double.infinity),
                          painter: DottedLinePainter(),
                        ),
                      ),

                      // List of alternating concept blocks
                      ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                        itemCount: sortedNodes.length,
                        itemBuilder: (context, index) {
                          final node = sortedNodes[index];
                          final isLeft = index % 2 == 0;
                          
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: isLeft
                                      ? Row(
                                          children: [
                                            Expanded(child: _buildConceptCard(context, node, index, provider)),
                                            const SizedBox(width: 8),
                                            _buildConnectorLine(isLeft, node),
                                            const SizedBox(width: 8),
                                          ],
                                        )
                                      : const SizedBox.shrink(),
                                ),
                                _buildTimelineDot(node),
                                Expanded(
                                  child: !isLeft
                                      ? Row(
                                          children: [
                                            const SizedBox(width: 8),
                                            _buildConnectorLine(isLeft, node),
                                            const SizedBox(width: 8),
                                            Expanded(child: _buildConceptCard(context, node, index, provider)),
                                          ],
                                        )
                                      : const SizedBox.shrink(),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
          )
        ],
      ),
    );
  }

  Widget _buildTimelineDot(StepNode node) {
    Color dotColor;
    switch (node.status) {
      case StepStatus.completed:
        dotColor = const Color(0xFF10B981);
        break;
      case StepStatus.inProgress:
        dotColor = Colors.amber;
        break;
      case StepStatus.notStarted:
        dotColor = const Color(0xFFCBD5E1);
    }

    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: dotColor, width: 3),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: dotColor.withValues(alpha: 0.3),
            blurRadius: 4,
            spreadRadius: 1,
          )
        ],
      ),
    );
  }

  Widget _buildConnectorLine(bool isLeft, StepNode node) {
    Color lineColor;
    switch (node.status) {
      case StepStatus.completed:
        lineColor = const Color(0xFF10B981).withValues(alpha: 0.3);
        break;
      case StepStatus.inProgress:
        lineColor = Colors.amber.withValues(alpha: 0.4);
        break;
      case StepStatus.notStarted:
        lineColor = const Color(0xFF64748B).withValues(alpha: 0.15);
    }

    return CustomPaint(
      size: const Size(20, 2),
      painter: DashedConnectorPainter(color: lineColor),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 8.5, fontWeight: FontWeight.bold),
        )
      ],
    );
  }

  Widget _buildConceptCard(BuildContext context, StepNode node, int index, RoadmapProvider provider) {
    BorderSide borderSide;
    switch (node.status) {
      case StepStatus.completed:
        borderSide = const BorderSide(color: Color(0xFFD1FAE5), width: 1);
        break;
      case StepStatus.inProgress:
        borderSide = const BorderSide(color: Color(0xFFFEF3C7), width: 1);
        break;
      case StepStatus.notStarted:
        borderSide = const BorderSide(color: Color(0xFFE2E8F0), width: 1);
    }

    return InkWell(
      onTap: () {
        provider.selectStep(node);
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (context) => const StepDetailBottomSheet(),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.fromBorderSide(borderSide),
          boxShadow: const [
            BoxShadow(color: Color(0x05000000), blurRadius: 4, offset: Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom card illustration banner
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 54,
                width: double.infinity,
                color: const Color(0xFFF1F5F9),
                child: Stack(
                  children: [
                    Image.network(
                      getStepIllustration(node.title, index),
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(color: Colors.deepOrange.shade50),
                    ),
                    Positioned(
                      bottom: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(node.emoji, style: const TextStyle(fontSize: 11)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bước ${node.order}'.toUpperCase(),
              style: const TextStyle(color: Colors.deepOrange, fontSize: 7, fontWeight: FontWeight.w900, letterSpacing: 0.5),
            ),
            const SizedBox(height: 2),
            Text(
              node.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 4),
            Text(
              node.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.grey, fontSize: 8),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: node.status == StepStatus.completed
                        ? const Color(0xFF10B981).withValues(alpha: 0.1)
                        : node.status == StepStatus.inProgress
                            ? Colors.amber.shade50
                            : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    node.status == StepStatus.completed
                        ? 'Đã xong'
                        : node.status == StepStatus.inProgress
                            ? 'Đang học'
                            : 'Chưa học',
                    style: TextStyle(
                      fontSize: 7.5,
                      fontWeight: FontWeight.bold,
                      color: node.status == StepStatus.completed
                          ? const Color(0xFF047857)
                          : node.status == StepStatus.inProgress
                              ? Colors.amber.shade700
                              : Colors.grey,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 14, color: Colors.grey),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onSelected: (action) {
                    if (action == 'delete') {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Xóa khái niệm?'),
                          content: Text('Bạn chắc chắn muốn xóa "${node.title}"?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Hủy')),
                            TextButton(
                              onPressed: () {
                                provider.deleteStep(node.id);
                                Navigator.of(ctx).pop();
                              },
                              child: const Text('Xóa', style: TextStyle(color: Colors.red)),
                            )
                          ],
                        ),
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Xóa khái niệm', style: TextStyle(fontSize: 12, color: Colors.red)),
                    ),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

// Painter to draw dashed axis line down the timeline
class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = size.width
      ..style = PaintingStyle.stroke;

    double maxExtent = size.height;
    double dashHeight = 5.0;
    double dashSpace = 4.0;
    double currentY = 0.0;

    while (currentY < maxExtent) {
      canvas.drawLine(Offset(size.width / 2, currentY), Offset(size.width / 2, currentY + dashHeight), paint);
      currentY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Painter to draw dashed connector branching out from axis
class DashedConnectorPainter extends CustomPainter {
  final Color color;

  DashedConnectorPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    double maxExtent = size.width;
    double dashWidth = 3.0;
    double dashSpace = 3.0;
    double currentX = 0.0;

    while (currentX < maxExtent) {
      canvas.drawLine(Offset(currentX, size.height / 2), Offset(currentX + dashWidth, size.height / 2), paint);
      currentX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
