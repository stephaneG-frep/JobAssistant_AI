import 'package:flutter/foundation.dart';

import '../services/local_database_service.dart';

enum AiMode { local, api }

class SettingsProvider extends ChangeNotifier {
  SettingsProvider(this._database);

  final LocalDatabaseService _database;

  AiMode aiMode = AiMode.local;
  String ollamaUrl = 'http://localhost:11434';
  String ollamaModel = 'mistral';
  String apiProvider = 'OpenAI';
  String apiKey = '';
  String apiEndpoint = '';
  bool apiConsent = false;
  bool isDarkMode = false;

  Future<void> load() async {
    aiMode = _database.setting('aiMode', 'local') == 'api' ? AiMode.api : AiMode.local;
    ollamaUrl = _database.setting('ollamaUrl', ollamaUrl);
    ollamaModel = _database.setting('ollamaModel', ollamaModel);
    apiProvider = _database.setting('apiProvider', apiProvider);
    apiKey = _database.setting('apiKey', apiKey);
    apiEndpoint = _database.setting('apiEndpoint', apiEndpoint);
    apiConsent = _database.setting('apiConsent', false);
    isDarkMode = _database.setting('isDarkMode', false);
    notifyListeners();
  }

  Future<void> save({
    AiMode? mode,
    String? newOllamaUrl,
    String? newOllamaModel,
    String? newApiProvider,
    String? newApiKey,
    String? newApiEndpoint,
    bool? consent,
    bool? darkMode,
  }) async {
    aiMode = mode ?? aiMode;
    ollamaUrl = newOllamaUrl ?? ollamaUrl;
    ollamaModel = newOllamaModel ?? ollamaModel;
    apiProvider = newApiProvider ?? apiProvider;
    apiKey = newApiKey ?? apiKey;
    apiEndpoint = newApiEndpoint ?? apiEndpoint;
    apiConsent = consent ?? apiConsent;
    isDarkMode = darkMode ?? isDarkMode;

    await _database.setSetting('aiMode', aiMode.name);
    await _database.setSetting('ollamaUrl', ollamaUrl);
    await _database.setSetting('ollamaModel', ollamaModel);
    await _database.setSetting('apiProvider', apiProvider);
    await _database.setSetting('apiKey', apiKey);
    await _database.setSetting('apiEndpoint', apiEndpoint);
    await _database.setSetting('apiConsent', apiConsent);
    await _database.setSetting('isDarkMode', isDarkMode);
    notifyListeners();
  }
}
