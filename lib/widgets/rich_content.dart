import 'package:flutter/material.dart';

import '../models/roadmap.dart';

class RichContentText extends StatelessWidget {
  const RichContentText(
    this.text, {
    super.key,
    required this.style,
  });

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: _buildInlineSpans(style),
      ),
    );
  }

  List<InlineSpan> _buildInlineSpans(TextStyle baseStyle) {
    final matches = RegExp(r'(\*\*.*?\*\*|`.*?`)').allMatches(text);
    if (matches.isEmpty) {
      return [TextSpan(text: text, style: baseStyle)];
    }

    final spans = <InlineSpan>[];
    var cursor = 0;

    for (final match in matches) {
      if (match.start > cursor) {
        spans.add(
          TextSpan(
            text: text.substring(cursor, match.start),
            style: baseStyle,
          ),
        );
      }

      final token = match.group(0) ?? '';
      if (token.startsWith('**') && token.endsWith('**')) {
        spans.add(
          TextSpan(
            text: token.substring(2, token.length - 2),
            style: baseStyle.copyWith(fontWeight: FontWeight.w700),
          ),
        );
      } else if (token.startsWith('`') && token.endsWith('`')) {
        spans.add(
          TextSpan(
            text: token.substring(1, token.length - 1),
            style: baseStyle.copyWith(
              fontFamily: 'monospace',
              backgroundColor: const Color(0xFFE2E8F0),
              color: const Color(0xFF0F172A),
            ),
          ),
        );
      }

      cursor = match.end;
    }

    if (cursor < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(cursor),
          style: baseStyle,
        ),
      );
    }

    return spans;
  }
}

class StepContentRenderer extends StatelessWidget {
  const StepContentRenderer({
    super.key,
    required this.blocks,
  });

  final List<StepContentBlock> blocks;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: blocks
          .asMap()
          .entries
          .map(
            (entry) => Padding(
              padding: EdgeInsets.only(
                bottom: entry.key == blocks.length - 1 ? 0 : 24,
              ),
              child: _ContentBlockView(block: entry.value),
            ),
          )
          .toList(),
    );
  }
}

class _ContentBlockView extends StatelessWidget {
  const _ContentBlockView({required this.block});

  final StepContentBlock block;

  @override
  Widget build(BuildContext context) {
    switch (block.type) {
      case StepContentBlockType.heading:
        return _HeadingBlock(block: block);
      case StepContentBlockType.paragraph:
        return _ParagraphBlock(block: block);
      case StepContentBlockType.callout:
        return _CalloutBlock(block: block);
      case StepContentBlockType.bullets:
        return _BulletBlock(block: block);
      case StepContentBlockType.quote:
        return _QuoteBlock(block: block);
      case StepContentBlockType.image:
        return _MediaBlock(block: block, label: 'Image');
      case StepContentBlockType.audio:
        return _MediaBlock(block: block, label: 'Audio');
      case StepContentBlockType.code:
        return _CodeBlock(block: block);
      case StepContentBlockType.divider:
        return _DividerBlock(block: block);
    }
  }
}

class _HeadingBlock extends StatelessWidget {
  const _HeadingBlock({required this.block});

  final StepContentBlock block;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (block.title.trim().isNotEmpty)
          RichContentText(
            block.title,
            style: const TextStyle(
              fontSize: 22,
              height: 1.2,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
        if (block.body.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          RichContentText(
            block.body,
            style: const TextStyle(
              fontSize: 15,
              height: 1.7,
              color: Color(0xFF475569),
            ),
          ),
        ],
      ],
    );
  }
}

class _ParagraphBlock extends StatelessWidget {
  const _ParagraphBlock({required this.block});

  final StepContentBlock block;

  @override
  Widget build(BuildContext context) {
    return RichContentText(
      block.body,
      style: const TextStyle(
        fontSize: 15,
        height: 1.82,
        color: Color(0xFF334155),
      ),
    );
  }
}

class _CalloutBlock extends StatelessWidget {
  const _CalloutBlock({required this.block});

  final StepContentBlock block;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (block.title.trim().isNotEmpty)
            Text(
              block.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
          if (block.title.trim().isNotEmpty && block.body.trim().isNotEmpty)
            const SizedBox(height: 8),
          if (block.body.trim().isNotEmpty)
            RichContentText(
              block.body,
              style: const TextStyle(
                fontSize: 14,
                height: 1.7,
                color: Color(0xFF475569),
              ),
            ),
        ],
      ),
    );
  }
}

class _BulletBlock extends StatelessWidget {
  const _BulletBlock({required this.block});

  final StepContentBlock block;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (block.title.trim().isNotEmpty) ...[
          Text(
            block.title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),
        ],
        ...block.items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2563EB),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: RichContentText(
                    item,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.7,
                      color: Color(0xFF334155),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _QuoteBlock extends StatelessWidget {
  const _QuoteBlock({required this.block});

  final StepContentBlock block;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 8, 0, 8),
      decoration: const BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Color(0xFFCBD5E1),
            width: 3,
          ),
        ),
      ),
      child: RichContentText(
        block.body,
        style: const TextStyle(
          fontSize: 15,
          height: 1.75,
          color: Color(0xFF475569),
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}

class _MediaBlock extends StatelessWidget {
  const _MediaBlock({
    required this.block,
    required this.label,
  });

  final StepContentBlock block;
  final String label;

  @override
  Widget build(BuildContext context) {
    final hasMedia = block.mediaUrl.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (block.title.trim().isNotEmpty) ...[
          Text(
            block.title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: hasMedia && block.type == StepContentBlockType.image
                ? Image.network(
                    block.mediaUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _MediaPlaceholder(label: label),
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) {
                        return child;
                      }
                      return const _MediaPlaceholder(label: 'Loading image');
                    },
                  )
                : _MediaPlaceholder(label: hasMedia ? '$label source ready' : '$label block ready'),
          ),
        ),
        if (block.caption.trim().isNotEmpty) ...[
          const SizedBox(height: 10),
          RichContentText(
            block.caption,
            style: const TextStyle(
              fontSize: 13,
              height: 1.6,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ],
    );
  }
}

class _MediaPlaceholder extends StatelessWidget {
  const _MediaPlaceholder({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE2E8F0),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Color(0xFF475569),
        ),
      ),
    );
  }
}

class _CodeBlock extends StatelessWidget {
  const _CodeBlock({required this.block});

  final StepContentBlock block;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            (block.codeLanguage.isEmpty ? 'text' : block.codeLanguage).toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w700,
              color: Color(0xFF93C5FD),
            ),
          ),
          const SizedBox(height: 10),
          SelectableText(
            block.body,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              height: 1.6,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _DividerBlock extends StatelessWidget {
  const _DividerBlock({required this.block});

  final StepContentBlock block;

  @override
  Widget build(BuildContext context) {
    if (block.title.trim().isEmpty) {
      return const Divider(height: 1, color: Color(0xFFE2E8F0));
    }

    return Row(
      children: [
        const Expanded(child: Divider(height: 1, color: Color(0xFFE2E8F0))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            block.title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF94A3B8),
            ),
          ),
        ),
        const Expanded(child: Divider(height: 1, color: Color(0xFFE2E8F0))),
      ],
    );
  }
}
