import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/network/api_client.dart';
import '../core/storage/secure_storage_service.dart';
import '../models/roadmap.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._apiClient, this._secureStorage) {
    _authService = AuthService(_apiClient);
    _init();
  }

  final ApiClient _apiClient;
  final SecureStorageService _secureStorage;
  late final AuthService _authService;

  static const _sessionKey = 'kahoa_current_user_v1';

  bool _isLoading = true;
  LearningUser? _currentUser;
  String? _lastError;

  bool get isLoading => _isLoading;
  LearningUser? get currentUser => _currentUser;
  String? get lastError => _lastError;

  String? get authToken => _apiClient.authToken;

  Future<void> _init() async {
    final token = await _secureStorage.getToken();
    final prefs = await SharedPreferences.getInstance();
    final rawUser = prefs.getString(_sessionKey);

    if (token != null && token.isNotEmpty) {
      _apiClient.authToken = token;

      try {
        _currentUser = await _authService.getMe();
      } catch (_) {
        if (rawUser != null) {
          try {
            _currentUser = LearningUser.fromJson(
              jsonDecode(rawUser) as Map<String, dynamic>,
            );
          } catch (_) {
            _currentUser = null;
          }
        }
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<String?> loginWithCredentials({
    required String email,
    required String password,
  }) async {
    final identifier = email.trim();
    final normalizedPassword = password.trim();

    if (identifier.isEmpty || normalizedPassword.isEmpty) {
      return 'Enter both username/email and password.';
    }

    try {
      final session = await _authService.login(
        identifier: identifier,
        password: normalizedPassword,
      );

      _apiClient.authToken = session.token;
      _currentUser = session.user;
      await _persistSession();
      notifyListeners();
      return null;
    } on ApiException catch (error) {
      await _clearSession();
      notifyListeners();
      return error.message;
    } catch (_) {
      await _clearSession();
      notifyListeners();
      return 'Unable to sign in right now. Please try again.';
    }
  }

  Future<String?> registerAccount({
    required String username,
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final session = await _authService.register(
        username: username,
        email: email,
        password: password,
        fullName: fullName,
      );

      _apiClient.authToken = session.token;
      _currentUser = session.user;
      await _persistSession();
      notifyListeners();
      return null;
    } on ApiException catch (error) {
      await _clearSession();
      notifyListeners();
      return error.message;
    } catch (_) {
      await _clearSession();
      notifyListeners();
      return 'Unable to register right now. Please try again.';
    }
  }

  Future<void> logout() async {
    await _clearSession();
    notifyListeners();
  }

  void updateUser(LearningUser user) {
    _currentUser = user;
    _persistSession();
    notifyListeners();
  }

  Future<LearningUser?> refreshUser() async {
    try {
      final user = await _authService.getMe();
      _currentUser = user;
      await _persistSession();
      notifyListeners();
      return user;
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        await _clearSession();
        notifyListeners();
      }
      return null;
    } catch (_) {
      return _currentUser;
    }
  }

  Future<void> _persistSession() async {
    if (_apiClient.authToken != null && _apiClient.authToken!.isNotEmpty) {
      await _secureStorage.saveToken(_apiClient.authToken!);
    }
    final prefs = await SharedPreferences.getInstance();
    if (_currentUser != null) {
      await prefs.setString(_sessionKey, jsonEncode(_currentUser!.toJson()));
    }
  }

  Future<void> _clearSession() async {
    _apiClient.authToken = null;
    _currentUser = null;
    await _secureStorage.deleteToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }
}
