import '../models/roadmap.dart';
import 'api_client.dart';

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
      '/api/v1/auth/login',
      requiresAuth: false,
      body: {
        'username': identifier.trim(),
        'password': password,
      },
    ) as Map<String, dynamic>;

    return AuthSession(
      token: data['token'] as String? ?? '',
      user: LearningUser.fromJson(data['user'] as Map<String, dynamic>),
    );
  }

  Future<AuthSession> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
  }) async {
    final data = await _apiClient.post(
      '/api/v1/auth/register',
      requiresAuth: false,
      body: {
        'username': username.trim(),
        'email': email.trim(),
        'password': password,
        'fullName': fullName.trim(),
      },
    ) as Map<String, dynamic>;

    return AuthSession(
      token: data['token'] as String? ?? '',
      user: LearningUser.fromJson(data['user'] as Map<String, dynamic>),
    );
  }

  Future<LearningUser> getUserById(String userId) async {
    final data = await _apiClient.get('/api/v1/users/$userId') as Map<String, dynamic>;
    return LearningUser.fromJson(data);
  }
}
