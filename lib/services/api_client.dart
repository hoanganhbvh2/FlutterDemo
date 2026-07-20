import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({
    http.Client? httpClient,
    String? baseUrl,
  })  : _httpClient = httpClient ?? http.Client(),
        baseUrl = (baseUrl != null && baseUrl.isNotEmpty)
            ? baseUrl
            : _defaultBaseUrl();

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
      if (requiresAuth && authToken != null) 'Authorization': 'Bearer $authToken',
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
      throw ApiException(
        'Cannot reach the backend at $baseUrl. Check the API URL and server status.',
      );
    }

    final payload = response.body.isEmpty ? null : jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        _extractMessage(payload) ?? 'Request failed with status ${response.statusCode}.',
        statusCode: response.statusCode,
      );
    }

    if (payload is Map<String, dynamic>) {
      final code = payload['code'];
      if (code is int && code != 1000) {
        throw ApiException(
          _extractMessage(payload) ?? 'The backend returned an unexpected response.',
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

  static String _defaultBaseUrl() {
    const configured = String.fromEnvironment('API_BASE_URL');
    if (configured.isNotEmpty) {
      return configured;
    }

    if (kIsWeb) {
      return 'http://localhost:5001';
    }

    return defaultTargetPlatform == TargetPlatform.android
        ? 'http://10.0.2.2:5001'
        : 'http://localhost:5001';
  }
}

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
