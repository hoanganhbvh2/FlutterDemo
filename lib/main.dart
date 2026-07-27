import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    const primaryGreen = Color(0xFF4EB748);

    return ChangeNotifierProvider(
      create: (_) => RoadmapProvider(),
      child: MaterialApp(
        title: 'Học Mẹo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: primaryGreen,
            primary: primaryGreen,
            secondary: const Color(0xFF124DA3),
            tertiary: const Color(0xFFF37022),
            surface: const Color(0xFFF8FAFC),
          ),
          textTheme: GoogleFonts.interTextTheme(),
          scaffoldBackgroundColor: const Color(0xFFF8FAFC),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.transparent,
            foregroundColor: const Color(0xFF0F172A),
            elevation: 0,
            centerTitle: false,
            titleTextStyle: GoogleFonts.inter(
              color: const Color(0xFF0F172A),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
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
