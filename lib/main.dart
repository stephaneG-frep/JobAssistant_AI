import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/ai_provider.dart';
import 'providers/history_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/template_provider.dart';
import 'services/local_database_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final database = LocalDatabaseService();
  await database.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider(database)..load()),
        ChangeNotifierProxyProvider<SettingsProvider, AiProvider>(
          create: (_) => AiProvider(),
          update: (_, settings, ai) => (ai ?? AiProvider())..settings = settings,
        ),
        ChangeNotifierProvider(create: (_) => HistoryProvider(database)..load()),
        ChangeNotifierProvider(create: (_) => TemplateProvider(database)..load()),
      ],
      child: const JobAssistantApp(),
    ),
  );
}
