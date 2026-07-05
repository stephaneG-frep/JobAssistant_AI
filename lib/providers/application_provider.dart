import 'package:flutter/foundation.dart';

import '../models/application_project.dart';
import '../services/local_database_service.dart';

class ApplicationProvider extends ChangeNotifier {
  ApplicationProvider(this._database);

  final LocalDatabaseService _database;
  List<ApplicationProject> projects = [];

  void load() {
    projects = _database.getApplications().map(ApplicationProject.fromJson).toList();
    notifyListeners();
  }

  Future<void> save(ApplicationProject project) async {
    await _database.saveApplication(project.toJson());
    load();
  }

  Future<void> add({
    required String company,
    required String position,
    String offerText = '',
    String cvText = '',
    String notes = '',
  }) =>
      save(
        ApplicationProject(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          company: company,
          position: position,
          offerText: offerText,
          cvText: cvText,
          notes: notes,
        ),
      );

  Future<void> delete(String id) async {
    await _database.deleteApplication(id);
    load();
  }
}
