import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/explore.dart';
import '../models/roadmap.dart';
import '../providers/roadmap_provider.dart';
import 'author_profile_screen.dart';
import 'step_detail_screen.dart';
import 'topic_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  bool _isSearching = false;
  ExploreSearchResult _searchResult = const ExploreSearchResult();
  String _selectedFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _performSearch('');
  }


  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (!mounted) return;
    setState(() {
      _isSearching = true;
    });

    try {
      final provider = context.read<RoadmapProvider>();
      final result = await provider.roadmapService.searchExplore(query);
      if (mounted) {
        setState(() {
          _searchResult = result;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim();

    final filteredAuthors = _searchResult.authors;
    final filteredBlogs = _searchResult.blogs;
    final filteredSteps = _searchResult.steps;


    final totalCount = filteredAuthors.length + filteredBlogs.length + filteredSteps.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Khám Phá & Tìm Kiếm'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Input Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Tìm theo tác giả, blog code, step code...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      )
                    : null,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                _buildFilterChip('Tất cả ($totalCount)', 'ALL'),
                const SizedBox(width: 8),
                _buildFilterChip('Tác giả (${filteredAuthors.length})', 'AUTHORS'),
                const SizedBox(width: 8),
                _buildFilterChip('Blog (${filteredBlogs.length})', 'BLOGS'),
                const SizedBox(width: 8),
                _buildFilterChip('Step (${filteredSteps.length})', 'STEPS'),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Main Results View
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : totalCount == 0
                    ? _buildEmptyState(query)
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          if ((_selectedFilter == 'ALL' || _selectedFilter == 'AUTHORS') &&
                              filteredAuthors.isNotEmpty) ...[
                            _buildSectionHeader('Tác giả (${filteredAuthors.length})', Icons.person_search),
                            const SizedBox(height: 8),
                            ...filteredAuthors.map((author) => _buildAuthorCard(context, author)),
                            const SizedBox(height: 20),
                          ],
                          if ((_selectedFilter == 'ALL' || _selectedFilter == 'BLOGS') &&
                              filteredBlogs.isNotEmpty) ...[
                            _buildSectionHeader('Blog / Chủ đề (${filteredBlogs.length})', Icons.menu_book),
                            const SizedBox(height: 8),
                            ...filteredBlogs.map((blog) => _buildBlogCard(context, blog)),
                            const SizedBox(height: 20),
                          ],
                          if ((_selectedFilter == 'ALL' || _selectedFilter == 'STEPS') &&
                              filteredSteps.isNotEmpty) ...[
                            _buildSectionHeader('Các Bước học / Step (${filteredSteps.length})', Icons.auto_stories),
                            const SizedBox(height: 8),
                            ...filteredSteps.map((step) => _buildStepCard(context, step)),
                            const SizedBox(height: 20),
                          ],
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    final theme = Theme.of(context);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _selectedFilter = value;
        });
      },
      selectedColor: theme.colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: isSelected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildAuthorCard(BuildContext context, AuthorProfile author) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(
            (author.fullName.isNotEmpty ? author.fullName[0] : author.username[0]).toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
              fontSize: 20,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                author.fullName.isNotEmpty ? author.fullName : author.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (author.code.isNotEmpty) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  author.code,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              '@${author.username} • ${author.email}',
              style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
            ),
            if (author.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                author.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
              ),
            ],
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AuthorProfileScreen(author: author),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBlogCard(BuildContext context, Topic blog) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: theme.colorScheme.tertiaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              blog.emoji.isNotEmpty ? blog.emoji : '📖',
              style: const TextStyle(fontSize: 22),
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
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  blog.code!,
                  style: TextStyle(
                    fontSize: 10,
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
        subtitle: Text(
          blog.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall,
        ),
        trailing: const Icon(Icons.chevron_right),
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

  Widget _buildStepCard(BuildContext context, StepNode step) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              step.emoji.isNotEmpty ? step.emoji : '📝',
              style: const TextStyle(fontSize: 22),
            ),
          ),
        ),
        title: Row(
          children: [
            if (step.code != null) ...[
              Container(
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  step.code!,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ),
            ],

            Expanded(
              child: Text(
                step.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        subtitle: Text(
          step.description.isNotEmpty ? step.description : 'Xem chi tiết bước học',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StepDetailScreen(stepId: step.id),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String query) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              query.isEmpty ? Icons.search : Icons.search_off,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              query.isEmpty
                  ? 'Nhập từ khóa để tìm kiếm'
                  : 'Không tìm thấy kết quả nào cho "$query"',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Thử tìm theo username tác giả (@username), mã blog (BLOG-00001), mã step (STEP-00001) hoặc tên bài viết.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
