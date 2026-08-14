import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/explore.dart';
import '../models/roadmap.dart';
import '../providers/roadmap_provider.dart';
import 'topic_detail_screen.dart';

class AuthorProfileScreen extends StatefulWidget {
  const AuthorProfileScreen({
    super.key,
    this.author,
    this.authorIdentifier,
  }) : assert(author != null || authorIdentifier != null,
            'Either author or authorIdentifier must be provided');

  final AuthorProfile? author;
  final String? authorIdentifier;

  @override
  State<AuthorProfileScreen> createState() => _AuthorProfileScreenState();
}

class _AuthorProfileScreenState extends State<AuthorProfileScreen> {
  late AuthorProfile? _author;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _author = widget.author;
    if (_author == null && widget.authorIdentifier != null) {
      _loadAuthorProfile();
    }
  }

  Future<void> _loadAuthorProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final provider = context.read<RoadmapProvider>();
      final profile = await provider.roadmapService.getAuthorProfile(widget.authorIdentifier!);
      if (mounted) {
        setState(() {
          _author = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Không thể tải thông tin tác giả: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_author?.fullName ?? _author?.username ?? 'Hồ sơ Tác giả'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                        const SizedBox(height: 16),
                        Text(_errorMessage!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadAuthorProfile,
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  ),
                )
              : _author == null
                  ? const Center(child: Text('Không tìm thấy thông tin tác giả'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Author Profile Card Header
                          Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 32,
                                        backgroundColor: theme.colorScheme.primaryContainer,
                                        child: Text(
                                          (_author!.fullName.isNotEmpty
                                                  ? _author!.fullName[0]
                                                  : _author!.username.isNotEmpty
                                                      ? _author!.username[0]
                                                      : 'A')
                                              .toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _author!.fullName.isNotEmpty
                                                  ? _author!.fullName
                                                  : _author!.name,
                                              style: theme.textTheme.titleLarge?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '@${_author!.username}',
                                              style: theme.textTheme.bodyMedium?.copyWith(
                                                color: theme.colorScheme.secondary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            if (_author!.code.isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: theme.colorScheme.surfaceContainerHighest,
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  _author!.code,
                                                  style: theme.textTheme.labelSmall?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: theme.colorScheme.onSurfaceVariant,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      Chip(
                                        avatar: const Icon(Icons.verified, size: 16),
                                        label: const Text('AUTHOR'),
                                        backgroundColor: theme.colorScheme.primaryContainer,
                                        labelStyle: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.onPrimaryContainer,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 24),
                                  Row(
                                    children: [
                                      Icon(Icons.email_outlined,
                                          size: 18, color: theme.colorScheme.onSurfaceVariant),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _author!.email.isNotEmpty
                                              ? _author!.email
                                              : 'Chưa cập nhật email',
                                          style: theme.textTheme.bodyMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.description_outlined,
                                          size: 18, color: theme.colorScheme.onSurfaceVariant),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _author!.description.isNotEmpty
                                              ? _author!.description
                                              : 'Chưa có mô tả bản thân.',
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            fontStyle: _author!.description.isEmpty
                                                ? FontStyle.italic
                                                : FontStyle.normal,
                                            color: _author!.description.isEmpty
                                                ? theme.colorScheme.outline
                                                : theme.colorScheme.onSurface,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Published Blogs Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Các Blog đã tạo (${_author!.blogs.length})',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Icon(Icons.library_books_outlined),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // List of Blogs
                          if (_author!.blogs.isEmpty)
                            Card(
                              color: theme.colorScheme.surfaceContainerLow,
                              child: const Padding(
                                padding: EdgeInsets.all(24.0),
                                child: Center(
                                  child: Text('Tác giả chưa tạo blog nào trong hệ thống.'),
                                ),
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _author!.blogs.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final blog = _author!.blogs[index];
                                return _buildBlogCard(context, blog);
                              },
                            ),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildBlogCard(BuildContext context, Topic blog) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              blog.emoji.isNotEmpty ? blog.emoji : '📖',
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        title: Row(
          children: [
            if (blog.code != null) ...[
              Container(
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  blog.code!,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
            Expanded(
              child: Text(
                blog.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),

        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            blog.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TopicDetailScreen(topicId: blog.id),
            ),
          );
        },
      ),
    );
  }
}
