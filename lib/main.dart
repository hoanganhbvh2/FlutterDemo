import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/network/api_client.dart';
import 'core/storage/secure_storage_service.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/plan_request_provider.dart';
import 'providers/roadmap_provider.dart';
import 'screens/app_shell.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Shared infrastructure — single instances injected into all providers.
    final apiClient = ApiClient();
    final secureStorage = SecureStorageService();

    return MultiProvider(
      providers: [
        // Auth must be first — other providers depend on it.
        ChangeNotifierProvider(
          create: (_) => AuthProvider(apiClient, secureStorage),
        ),

        // RoadmapProvider shares the same ApiClient and receives AuthProvider
        // updates via ProxyProvider so it can re-bootstrap on auth changes.
        ChangeNotifierProxyProvider<AuthProvider, RoadmapProvider>(
          create: (_) => RoadmapProvider(apiClient),
          update: (_, auth, roadmap) => roadmap!..updateAuth(auth),
        ),

        // PlanRequestProvider shares the same ApiClient.
        ChangeNotifierProvider(
          create: (_) => PlanRequestProvider(apiClient),
        ),
      ],
      child: MaterialApp(
        title: 'Học Mẹo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: Consumer2<AuthProvider, RoadmapProvider>(
          builder: (context, auth, roadmap, _) {
            // Show splash while auth is initialising OR while first data loads.
            if (auth.isLoading || roadmap.isLoading) {
              return const SplashScreen();
            }
            if (auth.currentUser == null) {
              return const LoginScreen();
            }
            return const AppShell();
          },
        ),
      ),
    );
  }
}
