import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';

class ApiClient {
  ApiClient({
    http.Client? httpClient,
    String? baseUrl,
  })  : _httpClient = httpClient ?? http.Client(),
        baseUrl = (baseUrl != null && baseUrl.isNotEmpty)
            ? baseUrl
            : ApiConfig.defaultBaseUrl();

  final http.Client _httpClient;
  final String baseUrl;

  String? authToken;

  Future<dynamic> get(
    String path, {
    bool requiresAuth = true,
  }) {
    return _send(
      method: 'GET',
      path: path,
      requiresAuth: requiresAuth,
    );
  }

  Future<dynamic> post(
    String path, {
    Object? body,
    bool requiresAuth = true,
  }) {
    return _send(
      method: 'POST',
      path: path,
      body: body,
      requiresAuth: requiresAuth,
    );
  }

  Future<dynamic> put(
    String path, {
    Object? body,
    bool requiresAuth = true,
  }) {
    return _send(
      method: 'PUT',
      path: path,
      body: body,
      requiresAuth: requiresAuth,
    );
  }

  Future<dynamic> patch(
    String path, {
    Object? body,
    bool requiresAuth = true,
  }) {
    return _send(
      method: 'PATCH',
      path: path,
      body: body,
      requiresAuth: requiresAuth,
    );
  }

  Future<dynamic> _send({
    required String method,
    required String path,
    Object? body,
    required bool requiresAuth,
  }) async {
    if (requiresAuth && (authToken == null || authToken!.isEmpty)) {
      throw const ApiException('Your session has expired. Please sign in again.');
    }

    final uri = Uri.parse('$baseUrl$path');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (authToken != null && authToken!.isNotEmpty)
        'Authorization': 'Bearer $authToken',
    };

    late final http.Response response;
    try {
      switch (method) {
        case 'POST':
          response = await _httpClient
              .post(
                uri,
                headers: headers,
                body: body == null ? null : jsonEncode(body),
              )
              .timeout(const Duration(seconds: 20));
          break;
        case 'PUT':
          response = await _httpClient
              .put(
                uri,
                headers: headers,
                body: body == null ? null : jsonEncode(body),
              )
              .timeout(const Duration(seconds: 20));
          break;
        case 'PATCH':
          response = await _httpClient
              .patch(
                uri,
                headers: headers,
                body: body == null ? null : jsonEncode(body),
              )
              .timeout(const Duration(seconds: 20));
          break;
        default:
          response = await _httpClient
              .get(
                uri,
                headers: headers,
              )
              .timeout(const Duration(seconds: 20));
      }
    } on TimeoutException {
      throw const ApiException('The server took too long to respond.');
    } on http.ClientException {
      throw ApiException(_connectionErrorMessage());
    }

    final payload =
        response.body.isEmpty ? null : jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        _extractMessage(payload) ??
            'Request failed with status ${response.statusCode}.',
        statusCode: response.statusCode,
      );
    }

    if (payload is Map<String, dynamic>) {
      final code = payload['code'];
      if (code is int && code != 1000) {
        throw ApiException(
          _extractMessage(payload) ??
              'The backend returned an unexpected response.',
          statusCode: response.statusCode,
        );
      }
      return payload.containsKey('data') ? payload['data'] : payload;
    }

    return payload;
  }

  String? _extractMessage(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      final message = payload['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }
    }
    return null;
  }

  String _connectionErrorMessage() {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      if (baseUrl.contains('10.0.2.2')) {
        return 'The app is using $baseUrl. 10.0.2.2 only works on Android emulator. '
            'On iPhone, run Flutter with --dart-define=API_BASE_URL=http://<your-computer-LAN-IP>:5001.';
      }

      if (baseUrl.contains('localhost') || baseUrl.contains('127.0.0.1')) {
        return 'Cannot reach the backend at $baseUrl. On a real iPhone, localhost points to the '
            'phone itself. Run Flutter with --dart-define=API_BASE_URL=http://<your-computer-LAN-IP>:5001.';
      }
    }

    return 'Cannot reach the backend at $baseUrl. Check the API URL and server status.';
  }
}

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
