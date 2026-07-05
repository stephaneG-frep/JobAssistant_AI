import 'package:flutter/foundation.dart';

import '../services/ai_service.dart';
import '../services/api_ai_service.dart';
import '../services/ollama_service.dart';
import 'settings_provider.dart';

class AiProvider extends ChangeNotifier {
  SettingsProvider? settings;
  bool isLoading = false;
  String? error;

  Future<String?> generate(String prompt) async {
    final current = settings;
    if (current == null) return null;
    if (current.aiMode == AiMode.api && !current.apiConsent) {
      error = 'Mode API bloqué : activez le consentement explicite dans les paramètres avant tout envoi externe.';
      notifyListeners();
      return null;
    }

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final AiService service = current.aiMode == AiMode.local
          ? OllamaService(baseUrl: current.ollamaUrl, model: current.ollamaModel)
          : ApiAiService(provider: current.apiProvider, apiKey: current.apiKey, endpoint: current.apiEndpoint);
      final result = await service.generate(prompt);
      return result.trim().isEmpty ? 'Le modèle a renvoyé une réponse vide.' : result.trim();
    } catch (exception) {
      error = exception.toString();
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
