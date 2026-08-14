import 'api_config.dart';

/// Resolves partial or Google Drive image URLs to their fully-qualified form.
String resolveImageUrl(String url) {
  if (url.isEmpty) return url;

  String processed = url.trim();

  final fileMatch = RegExp(
    r'drive\.google\.com/file/d/([a-zA-Z0-9_-]+)',
  ).firstMatch(processed);
  if (fileMatch != null) {
    return 'https://lh3.googleusercontent.com/d/${fileMatch.group(1)}';
  }

  final idMatch = RegExp(
    r'drive\.google\.com/(?:open|uc)\?.*?id=([a-zA-Z0-9_-]+)',
  ).firstMatch(processed);
  if (idMatch != null) {
    return 'https://lh3.googleusercontent.com/d/${idMatch.group(1)}';
  }

  final thumbMatch = RegExp(
    r'drive\.google\.com/thumbnail\?.*?id=([a-zA-Z0-9_-]+)',
  ).firstMatch(processed);
  if (thumbMatch != null) {
    return 'https://lh3.googleusercontent.com/d/${thumbMatch.group(1)}';
  }

  final serverOrigin = ApiConfig.defaultBaseUrl()
      .replaceAll(RegExp(r'/api(?:/v\d+)?/?$', caseSensitive: false), '')
      .replaceAll(RegExp(r'/+$'), '');

  if (processed.contains('localhost:5001') ||
      processed.contains('127.0.0.1:5001')) {
    return processed.replaceAll(
      RegExp(r'https?://(?:localhost|127\.0\.0\.1):5001'),
      serverOrigin,
    );
  }

  if (processed.startsWith('/upload/') || processed.startsWith('upload/')) {
    final cleanPath =
        processed.startsWith('/') ? processed : '/$processed';
    return '$serverOrigin$cleanPath';
  }

  return processed;
}
