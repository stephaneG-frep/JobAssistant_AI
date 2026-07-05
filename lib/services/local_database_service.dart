import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

class LocalDatabaseService {
  static const historyBox = 'history';
  static const settingsBox = 'settings';
  static const templatesBox = 'templates';

  Future<void> init() async {
    await Hive.openBox<dynamic>(historyBox);
    await Hive.openBox<dynamic>(settingsBox);
    await Hive.openBox<dynamic>(templatesBox);
  }

  Box<dynamic> get _history => Hive.box<dynamic>(historyBox);
  Box<dynamic> get _settings => Hive.box<dynamic>(settingsBox);
  Box<dynamic> get _templates => Hive.box<dynamic>(templatesBox);

  Future<void> saveHistory(Map<String, dynamic> item) => _history.put(item['id'], item);

  List<Map<String, dynamic>> getHistory() => _history.values.map((value) => Map<String, dynamic>.from(value as Map)).toList()
    ..sort((a, b) => (b['createdAt'] as String? ?? '').compareTo(a['createdAt'] as String? ?? ''));

  Future<void> deleteHistory(String id) => _history.delete(id);

  Future<void> clearHistory() => _history.clear();

  String exportHistoryJson() => const JsonEncoder.withIndent('  ').convert(getHistory());

  T setting<T>(String key, T fallback) => (_settings.get(key) as T?) ?? fallback;

  Future<void> setSetting<T>(String key, T value) => _settings.put(key, value);

  Future<void> saveTemplate(Map<String, dynamic> item) => _templates.put(item['id'], item);

  List<Map<String, dynamic>> getTemplates() => _templates.values.map((value) => Map<String, dynamic>.from(value as Map)).toList()
    ..sort((a, b) => (b['updatedAt'] as String? ?? '').compareTo(a['updatedAt'] as String? ?? ''));

  Future<void> deleteTemplate(String id) => _templates.delete(id);
}
