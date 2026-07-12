import 'package:flutter/material.dart';
import 'package:flutter_demo/screens/login_screen.dart';
import 'package:flutter_demo/screens/splash_screen.dart';
import 'package:provider/provider.dart';
import 'providers/roadmap_provider.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RoadmapProvider()),
      ],
      child: MaterialApp(
        title: 'Learning Roadmap Platform',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.deepOrange,
          primaryColor: Colors.deepOrange,
          fontFamily: 'Inter',
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF8FAFC),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0.5,
            iconTheme: IconThemeData(color: Colors.black87),
            titleTextStyle: TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
          ),
        ),
        home: Consumer<RoadmapProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const SplashScreen();
            }
            if (provider.currentStudent == null) {
              return const LoginScreen();
            }
            return const DashboardScreen();
          },
        ),
      ),
    );
  }
}
