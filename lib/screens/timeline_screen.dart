import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/roadmap.dart';
import '../providers/roadmap_provider.dart';
import 'package:flutter_demo/screens/canvas_screen.dart';

class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RoadmapProvider>(context);
    final topic = provider.selectedTopic;

    if (topic == null) {
      return const Scaffold(
        body: Center(child: Text('Không tìm thấy chủ đề được chọn.')),
      );
    }

    final totalSteps = topic.lessons.expand((e) => e.nodes).length;
    final completedSteps = topic.lessons.expand((e) => e.nodes).where((n) => n.status == StepStatus.completed).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Row(
          children: [
            Text(topic.emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topic.title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w900),
                  ),
                  const Text(
                    'LỘ TRÌNH CHI TIẾT',
                    style: TextStyle(color: Colors.grey, fontSize: 8, fontWeight: FontWeight.bold),
                  )
                ],
              ),
            )
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Stats card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events_outlined, color: Colors.amber, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tiến trình hoàn thành:',
                          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 10),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Đã hoàn thành $completedSteps trên tổng số $totalSteps khái niệm',
                          style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 11),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Lộ trình bài học',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF0F172A)),
                ),
                const SizedBox.shrink()
              ],
            ),
            const SizedBox(height: 10),

            topic.lessons.isEmpty
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.book_outlined, color: Colors.grey, size: 36),
                        const SizedBox(height: 12),
                        const Text('Chưa có bài học nào', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 6),
                        const Text(
                          'Chủ đề này chưa được phân bổ bài học nào.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: topic.lessons.length,
                    itemBuilder: (context, index) {
                      final lesson = topic.lessons[index];
                      return _buildLessonTimelineCard(context, lesson, index, provider);
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonTimelineCard(BuildContext context, Lesson lesson, int index, RoadmapProvider provider) {
    final totalSteps = lesson.nodes.length;
    final completedSteps = lesson.nodes.where((e) => e.status == StepStatus.completed).length;
    final progressVal = totalSteps > 0 ? (completedSteps / totalSteps) : 0.0;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline Indicator
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: progressVal == 1.0 ? const Color(0xFF10B981) : Colors.deepOrange,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: const Color(0xFFE2E8F0),
                ),
              )
            ],
          ),
          const SizedBox(width: 14),

          // Lesson Details Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: InkWell(
                onTap: () {
                  provider.selectLesson(lesson);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const CanvasScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              lesson.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A)),
                            ),
                          ),
                          const SizedBox.shrink()
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lesson.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.grey, fontSize: 10, height: 1.3),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: LinearProgressIndicator(
                                value: progressVal,
                                backgroundColor: const Color(0xFFEEF2F6),
                                color: progressVal == 1.0 ? const Color(0xFF10B981) : Colors.deepOrange,
                                minHeight: 4,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '$completedSteps/$totalSteps khái niệm',
                            style: const TextStyle(color: Colors.grey, fontSize: 8.5, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
