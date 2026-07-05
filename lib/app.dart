import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/settings_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/history_screen.dart';
import 'screens/interview_coach_screen.dart';
import 'screens/cover_letter_screen.dart';
import 'screens/cv_match_screen.dart';
import 'screens/offer_analysis_screen.dart';
import 'screens/settings_screen.dart';

class JobAssistantApp extends StatelessWidget {
  const JobAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1D2B53),
      brightness: settings.isDarkMode ? Brightness.dark : Brightness.light,
    ).copyWith(
      primary: const Color(0xFF1D2B53),
      secondary: const Color(0xFF6554E8),
      tertiary: const Color(0xFF00A7C2),
      surface: settings.isDarkMode ? const Color(0xFF111827) : const Color(0xFFFFFBF3),
    );

    return MaterialApp(
      title: 'JobAssistant AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: colorScheme.surface,
        cardTheme: const CardThemeData(margin: EdgeInsets.zero),
        inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
      ),
      home: const ShellScreen(),
    );
  }
}

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _index = 0;

  static const _screens = [
    DashboardScreen(),
    OfferAnalysisScreen(),
    CvMatchScreen(),
    CoverLetterScreen(),
    InterviewCoachScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _screens[_index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.space_dashboard_outlined), selectedIcon: Icon(Icons.space_dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.analytics_outlined), selectedIcon: Icon(Icons.analytics), label: 'Analyse'),
          NavigationDestination(icon: Icon(Icons.description_outlined), selectedIcon: Icon(Icons.description), label: 'CV'),
          NavigationDestination(icon: Icon(Icons.mail_outline), selectedIcon: Icon(Icons.mail), label: 'Lettres'),
          NavigationDestination(icon: Icon(Icons.record_voice_over_outlined), selectedIcon: Icon(Icons.record_voice_over), label: 'Entretien'),
          NavigationDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history), label: 'Historique'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Paramètres'),
        ],
      ),
    );
  }
}
