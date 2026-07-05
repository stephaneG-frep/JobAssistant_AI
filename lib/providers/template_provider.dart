import 'package:flutter/foundation.dart';

import '../models/saved_template.dart';
import '../services/local_database_service.dart';

class TemplateProvider extends ChangeNotifier {
  TemplateProvider(this._database);

  final LocalDatabaseService _database;
  List<SavedTemplate> templates = [];

  void load() {
    templates = _database.getTemplates().map(SavedTemplate.fromJson).toList();
    notifyListeners();
  }

  Future<void> save(SavedTemplate template) async {
    await _database.saveTemplate(template.toJson());
    load();
  }

  Future<void> addFromContent(String title, String category, String content) => save(
        SavedTemplate(id: DateTime.now().microsecondsSinceEpoch.toString(), title: title, category: category, content: content),
      );

  Future<void> delete(String id) async {
    await _database.deleteTemplate(id);
    load();
  }
}
