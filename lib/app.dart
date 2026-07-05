import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/settings_provider.dart';
import 'screens/application_projects_screen.dart';
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
    final colorScheme = _jobAssistantColorScheme(settings.isDarkMode);

    return MaterialApp(
      title: 'JobAssistant AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: colorScheme.surface,
        cardTheme: const CardThemeData(margin: EdgeInsets.zero),
        inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            disabledBackgroundColor: colorScheme.onSurface.withValues(alpha: 0.12),
            disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
          ),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(foregroundColor: colorScheme.onSurfaceVariant),
        ),
      ),
      home: const ShellScreen(),
    );
  }

  ColorScheme _jobAssistantColorScheme(bool darkMode) {
    if (darkMode) {
      return ColorScheme.fromSeed(
        seedColor: const Color(0xFF00D5FF),
        brightness: Brightness.dark,
      ).copyWith(
        primary: const Color(0xFF6FE7FF),
        onPrimary: const Color(0xFF071B2C),
        primaryContainer: const Color(0xFF123B57),
        onPrimaryContainer: const Color(0xFFE6FAFF),
        secondary: const Color(0xFFC8BFFF),
        onSecondary: const Color(0xFF211453),
        secondaryContainer: const Color(0xFF3F347C),
        onSecondaryContainer: const Color(0xFFF0EDFF),
        tertiary: const Color(0xFF72F0D4),
        onTertiary: const Color(0xFF00382E),
        surface: const Color(0xFF101823),
        onSurface: const Color(0xFFF4F7FB),
        surfaceContainerHighest: const Color(0xFF263241),
        onSurfaceVariant: const Color(0xFFD3DAE5),
        outline: const Color(0xFF9AA8B8),
        error: const Color(0xFFFFB4AB),
        onError: const Color(0xFF690005),
      );
    }

    return ColorScheme.fromSeed(
      seedColor: const Color(0xFF1D2B53),
      brightness: Brightness.light,
    ).copyWith(
      primary: const Color(0xFF1D2B53),
      onPrimary: const Color(0xFFFFFFFF),
      secondary: const Color(0xFF6554E8),
      onSecondary: const Color(0xFFFFFFFF),
      tertiary: const Color(0xFF00A7C2),
      onTertiary: const Color(0xFFFFFFFF),
      surface: const Color(0xFFFFFBF3),
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
    ApplicationProjectsScreen(),
    OfferAnalysisScreen(),
    CvMatchScreen(),
    CoverLetterScreen(),
    InterviewCoachScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  static const _destinations = [
    _BottomNavItem(Icons.space_dashboard_outlined, Icons.space_dashboard, 'Dashboard'),
    _BottomNavItem(Icons.work_outline, Icons.work, 'Candidatures'),
    _BottomNavItem(Icons.analytics_outlined, Icons.analytics, 'Analyse'),
    _BottomNavItem(Icons.description_outlined, Icons.description, 'CV'),
    _BottomNavItem(Icons.mail_outline, Icons.mail, 'Lettres'),
    _BottomNavItem(Icons.record_voice_over_outlined, Icons.record_voice_over, 'Entretien'),
    _BottomNavItem(Icons.history_outlined, Icons.history, 'Historique'),
    _BottomNavItem(Icons.settings_outlined, Icons.settings, 'Paramètres'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _screens[_index]),
      bottomNavigationBar: _ComfortBottomNav(
        selectedIndex: _index,
        destinations: _destinations,
        onSelected: (value) => setState(() => _index = value),
      ),
    );
  }
}

class _ComfortBottomNav extends StatelessWidget {
  const _ComfortBottomNav({
    required this.selectedIndex,
    required this.destinations,
    required this.onSelected,
  });

  final int selectedIndex;
  final List<_BottomNavItem> destinations;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surface,
      elevation: 3,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 74,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            itemCount: destinations.length,
            separatorBuilder: (_, _) => const SizedBox(width: 6),
            itemBuilder: (context, index) {
              final destination = destinations[index];
              final selected = index == selectedIndex;
              return SizedBox(
                width: 92,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => onSelected(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected ? colorScheme.secondaryContainer : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          selected ? destination.selectedIcon : destination.icon,
                          color: selected ? colorScheme.onSecondaryContainer : colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          destination.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: selected ? colorScheme.onSecondaryContainer : colorScheme.onSurfaceVariant,
                                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem {
  const _BottomNavItem(this.icon, this.selectedIcon, this.label);

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}
