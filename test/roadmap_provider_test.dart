import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_demo/core/network/api_client.dart';
import 'package:flutter_demo/core/storage/secure_storage_service.dart';
import 'package:flutter_demo/providers/auth_provider.dart';
import 'package:flutter_demo/providers/roadmap_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  group('RoadmapProvider Unit Tests', () {
    test('initializes state and loads fallback topics on network error', () async {
      final apiClient = ApiClient();
      final provider = RoadmapProvider(apiClient);
      final authProvider = AuthProvider(apiClient, SecureStorageService());

      // Wait for AuthProvider initialization to finish
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Trigger updateAuth so RoadmapProvider bootstraps
      provider.updateAuth(authProvider);

      // Wait for data load to complete
      await Future<void>.delayed(const Duration(milliseconds: 300));

      expect(provider.topics, isNotEmpty);
      expect(provider.categories, isNotEmpty);
      expect(provider.currentUser, isNull);
    });

    test('setCategoryFilter and setSearchQuery update filtered topics', () async {
      final apiClient = ApiClient();
      final provider = RoadmapProvider(apiClient);
      final authProvider = AuthProvider(apiClient, SecureStorageService());

      await Future<void>.delayed(const Duration(milliseconds: 100));
      provider.updateAuth(authProvider);
      await Future<void>.delayed(const Duration(milliseconds: 300));

      expect(provider.selectedCategoryId, isNull);

      provider.setCategoryFilter('mobile');
      expect(provider.selectedCategoryId, equals('mobile'));

      provider.setSearchQuery('flutter');
      expect(provider.searchQuery, equals('flutter'));

      provider.setCategoryFilter(null);
      expect(provider.selectedCategoryId, isNull);
    });

    test('AuthProvider logout clears user state', () async {
      final apiClient = ApiClient();
      final authProvider = AuthProvider(apiClient, SecureStorageService());

      await Future<void>.delayed(const Duration(milliseconds: 100));

      await authProvider.logout();
      expect(authProvider.currentUser, isNull);
    });
  });
}
