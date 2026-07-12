import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/roadmap.dart';
import '../providers/roadmap_provider.dart';
import '../services/api_service.dart';
import 'timeline_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();

  // Dialog triggers for manual Topic creation
  void _showAddTopicDialog(BuildContext context) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Thêm chủ đề mới', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Nhập tên chủ đề (VD: Flutter, React, Devops...)',
            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              final val = textController.text.trim();
              if (val.isNotEmpty) {
                Provider.of<RoadmapProvider>(context, listen: false).addTopic(val);
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Tạo', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  // AI Roadmap Generator Dialog Modal
  void _showAIGenerationDialog(BuildContext context) {
    final topicController = TextEditingController();
    final descController = TextEditingController();
    bool isGenerating = false;
    String? errorMessage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AnimatedPadding(
              padding: MediaQuery.of(context).viewInsets + const EdgeInsets.all(24),
              duration: const Duration(milliseconds: 100),
              curve: Curves.decelerate,
              child: SingleChildScrollView(
                child: isGenerating
                    ? Container(
                        height: 280,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 60,
                              height: 60,
                              child: CircularProgressIndicator(
                                color: Colors.deepOrange,
                                strokeWidth: 4.5,
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Gemini AI đang tư duy...',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.deepOrange),
                            ),
                            const SizedBox(height: 8),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24.0),
                              child: Text(
                                'Chúng tôi đang phân tích cấu trúc kiến thức, soạn thảo nội dung song ngữ và thiết lập sơ đồ tối ưu.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.deepOrange.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.bolt, color: Colors.deepOrange, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'Lộ trình tự động bằng AI',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                      Text(
                                        'Sử dụng Gemini để sinh giáo trình & sơ đồ',
                                        style: TextStyle(fontSize: 11, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => Navigator.of(ctx).pop(),
                              )
                            ],
                          ),
                          const Divider(height: 24),
                          if (errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                border: Border.all(color: Colors.red.shade100),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                errorMessage!,
                                style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          const Text(
                            'Tên chủ đề học tập *',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: topicController,
                            decoration: InputDecoration(
                              hintText: 'VD: ReactJS, Docker Container, Web3...',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Yêu cầu đặc biệt (Không bắt buộc)',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: descController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'VD: Lộ trình cho người mới, tập trung thực hành, học trong 4 tuần...',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepOrange,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                elevation: 0,
                              ),
                              onPressed: () async {
                                final topic = topicController.text.trim();
                                final desc = descController.text.trim();
                                if (topic.isEmpty) return;

                                setModalState(() {
                                  isGenerating = true;
                                  errorMessage = null;
                                });

                                try {
                                  final newTopic = await _apiService.generateRoadmap(topic, desc);
                                  if (!context.mounted) return;
                                  await Provider.of<RoadmapProvider>(context, listen: false).addGeneratedTopic(newTopic);
                                  Navigator.of(ctx).pop();
                                  
                                  // Navigate to the newly generated Topic's timeline
                                  if (context.mounted) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => const TimelineScreen(),
                                      ),
                                    );
                                  }
                                } catch (err) {
                                  setModalState(() {
                                    isGenerating = false;
                                    errorMessage = err.toString();
                                  });
                                }
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.auto_awesome, size: 18, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    'Bắt đầu Tạo Lộ trình',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RoadmapProvider>(context);
    final stats = provider.getOverallStats();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.deepOrange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.school, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.currentStudent?.name ?? 'Học sinh',
                  style: const TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w900),
                ),
                Text(
                  provider.currentClass?.name ?? 'LỚP HỌC',
                  style: const TextStyle(color: Colors.grey, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                )
              ],
            )
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Đăng xuất',
            icon: const Icon(Icons.logout, color: Colors.deepOrange, size: 20),
            onPressed: () async {
              await provider.logoutStudent();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          )
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.deepOrange))
          : SizedBox.expand(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Banner Card
                          Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF97316), Color(0xFFD97706)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepOrange.withValues(alpha: 0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 10),
                                  SizedBox(width: 4),
                                  Text(
                                    provider.currentClass?.name ?? "AI Learning hỗ trợ bạn",
                                    style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Bắt đầu lộ trình học cá nhân',
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Liên kết mọi kiến thức thành sơ đồ mạng lưới trực quan. Chạm vào một chủ đề để học ngay.',
                              style: TextStyle(color: Color(0xFFFFE3E3), fontSize: 12, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Progress Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Tiến trình tổng quan', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                                Text('${stats['percent']}%', style: const TextStyle(color: Colors.deepOrange, fontSize: 14, fontWeight: FontWeight.w900)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: LinearProgressIndicator(
                                value: stats['percent'] / 100.0,
                                backgroundColor: const Color(0xFFE2E8F0),
                                color: Colors.deepOrange,
                                minHeight: 6,
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Section Title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Chủ đề học tập',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF0F172A)),
                          ),
                          const SizedBox.shrink()
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Topics List
                      provider.topics.isEmpty
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
                                  const Icon(Icons.explore_outlined, color: Colors.grey, size: 36),
                                  const SizedBox(height: 12),
                                  const Text('Chưa có chủ đề nào', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Liên hệ giảng viên hoặc quản trị viên để nhận phân bổ chủ đề học tập.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey, fontSize: 10),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: provider.topics.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final topic = provider.topics[index];
                                return _buildTopicCard(context, topic, provider);
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                // Floating Stats Dashboard
                Positioned(
                  bottom: 30,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.all(Radius.circular(16)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 25,
                          offset: const Offset(-4, -4),
                        )
                      ],
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildStatItem('Chủ đề', stats['totalTopics'].toString()),
                        const SizedBox(height: 10),
                        _buildStatItem('Bài học', stats['totalLessons'].toString()),
                        const SizedBox(height: 10),
                        _buildStatItem('Khái niệm', stats['totalSteps'].toString()),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      floatingActionButton: null,
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(label.toUpperCase(), style: const TextStyle(color: Colors.grey, fontSize: 8, fontWeight: FontWeight.w800, letterSpacing: 0.6)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildTopicCard(BuildContext context, Topic topic, RoadmapProvider provider) {
    final int stepCount = topic.lessons.expand((element) => element.nodes).length;
    final int completedCount = topic.lessons.expand((element) => element.nodes).where((e) => e.status == StepStatus.completed).length;
    
    return InkWell(
      onTap: () {
        provider.selectTopic(topic);
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const TimelineScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2F6),
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Text(topic.emoji, style: const TextStyle(fontSize: 28)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topic.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    topic.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.deepOrange.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${topic.lessons.length} bài học',
                          style: const TextStyle(color: Colors.deepOrange, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Đã xong $completedCount/$stepCount bước',
                        style: const TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

// Simple extension helper for Widget mapping
extension WidgetHelper<T> on T {
  Widget child(Widget child) => child;
}
