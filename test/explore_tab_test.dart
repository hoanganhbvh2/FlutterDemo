import 'package:flutter/material.dart';
import 'package:flutter_demo/core/network/api_client.dart';
import 'package:flutter_demo/core/storage/secure_storage_service.dart';
import 'package:flutter_demo/models/explore.dart';
import 'package:flutter_demo/models/roadmap.dart';
import 'package:flutter_demo/providers/auth_provider.dart';
import 'package:flutter_demo/providers/plan_request_provider.dart';
import 'package:flutter_demo/providers/roadmap_provider.dart';
import 'package:flutter_demo/screens/app_shell.dart';
import 'package:flutter_demo/screens/author_profile_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';


void main() {
  testWidgets('AppShell renders Explore tab with search icon', (WidgetTester tester) async {
    final apiClient = ApiClient();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => AuthProvider(apiClient, SecureStorageService()),
          ),
          ChangeNotifierProxyProvider<AuthProvider, RoadmapProvider>(
            create: (_) => RoadmapProvider(apiClient),
            update: (_, auth, roadmap) => roadmap!..updateAuth(auth),
          ),
          ChangeNotifierProvider(
            create: (_) => PlanRequestProvider(apiClient),
          ),
        ],
        child: const MaterialApp(
          home: AppShell(),
        ),
      ),
    );

    // Verify navigation destination labels
    expect(find.text('Learn'), findsOneWidget);
    expect(find.text('Explore'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    // Tap Explore tab (index 1)
    await tester.tap(find.text('Explore'));
    await tester.pumpAndSettle();

    // Verify ExploreScreen renders
    expect(find.text('Khám Phá & Tìm Kiếm'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('AuthorProfileScreen renders profile details and published blogs', (WidgetTester tester) async {
    const author = AuthorProfile(
      id: '10',
      code: 'USR-00010',
      username: 'johnauthor',
      name: 'John Author',
      fullName: 'John Author',
      email: 'john@author.com',
      description: 'Expert Dart & Flutter Developer',
      role: 'AUTHOR',
      blogs: [
        Topic(
          id: '100',
          code: 'BLOG-00100',
          title: 'Flutter Architecture Best Practices',
          description: 'Comprehensive guide to Flutter state management',
          emoji: '🚀',
          levelLabel: 'Intermediate',
          estimatedHours: 5,
          lessons: [],
        ),
      ],
    );

    final apiClient = ApiClient();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => AuthProvider(apiClient, SecureStorageService()),
          ),
          ChangeNotifierProxyProvider<AuthProvider, RoadmapProvider>(
            create: (_) => RoadmapProvider(apiClient),
            update: (_, auth, roadmap) => roadmap!..updateAuth(auth),
          ),
          ChangeNotifierProvider(
            create: (_) => PlanRequestProvider(apiClient),
          ),
        ],
        child: const MaterialApp(
          home: AuthorProfileScreen(author: author),
        ),
      ),
    );

    // Verify profile fields
    expect(find.text('John Author'), findsWidgets);
    expect(find.text('@johnauthor'), findsOneWidget);
    expect(find.text('john@author.com'), findsOneWidget);
    expect(find.text('Expert Dart & Flutter Developer'), findsOneWidget);
    expect(find.text('USR-00010'), findsOneWidget);
    expect(find.text('AUTHOR'), findsOneWidget);

    // Verify published blog card
    expect(find.text('Flutter Architecture Best Practices'), findsOneWidget);
    expect(find.text('BLOG-00100'), findsOneWidget);
  });
}
