import 'package:flutter/foundation.dart';

import '../services/local_database_service.dart';

class HistoryProvider extends ChangeNotifier {
  HistoryProvider(this._database);

  final LocalDatabaseService _database;
  List<Map<String, dynamic>> items = [];

  void load() {
    items = _database.getHistory();
    notifyListeners();
  }

  Future<void> add({required String type, required String title, required String content, Map<String, dynamic> metadata = const {}}) async {
    final item = {
      'id': DateTime.now().microsecondsSinceEpoch.toString(),
      'type': type,
      'title': title,
      'content': content,
      'metadata': metadata,
      'createdAt': DateTime.now().toIso8601String(),
    };
    await _database.saveHistory(item);
    load();
  }

  Future<void> delete(String id) async {
    await _database.deleteHistory(id);
    load();
  }

  Future<void> clear() async {
    await _database.clearHistory();
    load();
  }

  String exportJson() => _database.exportHistoryJson();
}
