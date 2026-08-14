import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/roadmap.dart';

class AuthSession {
  const AuthSession({
    required this.token,
    required this.user,
  });

  final String token;
  final LearningUser user;
}

class AuthService {
  AuthService(this._apiClient);

  final ApiClient _apiClient;

  Future<AuthSession> login({
    required String identifier,
    required String password,
  }) async {
    final data = await _apiClient.post(
      ApiEndpoints.login,
      requiresAuth: false,
      body: {
        'username': identifier.trim(),
        'password': password,
      },
    ) as Map<String, dynamic>;

    final userJson = (data['user'] as Map<String, dynamic>?) ?? data;

    return AuthSession(
      token: data['token'] as String? ?? '',
      user: LearningUser.fromJson(userJson),
    );
  }

  Future<AuthSession> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
  }) async {
    final data = await _apiClient.post(
      ApiEndpoints.register,
      requiresAuth: false,
      body: {
        'username': username.trim(),
        'email': email.trim(),
        'password': password,
        'fullName': fullName.trim(),
      },
    ) as Map<String, dynamic>;

    final userJson = (data['user'] as Map<String, dynamic>?) ?? data;

    return AuthSession(
      token: data['token'] as String? ?? '',
      user: LearningUser.fromJson(userJson),
    );
  }

  Future<LearningUser> getUserById(String userId) async {
    final data = await _apiClient.get(
      ApiEndpoints.userDetail(userId),
    ) as Map<String, dynamic>;
    return LearningUser.fromJson(data);
  }

  Future<LearningUser> getMe() async {
    final data =
        await _apiClient.get(ApiEndpoints.me) as Map<String, dynamic>;
    return LearningUser.fromJson(data);
  }
}
