import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    const seedColor = Color(0xFF124DA3);

    return ChangeNotifierProvider(
      create: (_) => RoadmapProvider(),
      child: MaterialApp(
        title: 'Học Mẹo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: seedColor,
            primary: const Color(0xFF124DA3),
            secondary: const Color(0xFF4EB748),
            tertiary: const Color(0xFFF37022),
            brightness: Brightness.light,
            surface: const Color(0xFFF8FAFC),
          ),
          scaffoldBackgroundColor: const Color(0xFFF8FAFC),
          fontFamily: 'Roboto',
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            foregroundColor: Color(0xFF0F172A),
            elevation: 0,
            centerTitle: false,
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
          ),
        ),
        home: Consumer<RoadmapProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const SplashScreen();
            }
            if (provider.currentUser == null) {
              return const LoginScreen();
            }
            return const AppShell();
          },
        ),
      ),
    );
  }
}
