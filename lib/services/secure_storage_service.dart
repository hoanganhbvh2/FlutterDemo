import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  SecureStorageService()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(
            encryptedSharedPreferences: true,
          ),
          iOptions: IOSOptions(
            accessibility: KeychainAccessibility.first_unlock,
          ),
        );

  final FlutterSecureStorage _storage;

  static const String _authTokenKey = 'secure_auth_token_v1';

  Future<String?> getToken() async {
    try {
      return await _storage.read(key: _authTokenKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: _authTokenKey, value: token);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _authTokenKey);
  }
}
