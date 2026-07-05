import 'dart:convert';

import 'package:http/http.dart' as http;

import 'ai_service.dart';

class ApiAiService implements AiService {
  ApiAiService({required this.provider, required this.apiKey, this.endpoint});

  final String provider;
  final String apiKey;
  final String? endpoint;

  @override
  Future<String> generate(String prompt) async {
    if (apiKey.trim().isEmpty) {
      throw AiUnavailableException('Ajoutez une clé API dans les paramètres avant d’utiliser le mode API.');
    }

    if (provider.toLowerCase() == 'openai') {
      return _openAi(prompt);
    }

    throw AiUnavailableException('Fournisseur "$provider" non configuré. Utilisez OpenAI ou renseignez un service compatible dans api_ai_service.dart.');
  }

  Future<String> _openAi(String prompt) async {
    final uri = Uri.parse(endpoint?.trim().isNotEmpty == true ? endpoint! : 'https://api.openai.com/v1/responses');
    final response = await http.post(
      uri,
      headers: {'Authorization': 'Bearer $apiKey', 'Content-Type': 'application/json'},
      body: jsonEncode({
        'model': 'gpt-4.1-mini',
        'input': prompt,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AiUnavailableException('API IA indisponible (${response.statusCode}). Aucun nouvel envoi ne sera tenté sans action volontaire.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final output = data['output'] as List<dynamic>? ?? const [];
    final parts = output.expand((item) => (item as Map<String, dynamic>)['content'] as List<dynamic>? ?? const []);
    return parts.map((part) => (part as Map<String, dynamic>)['text'] ?? '').join('\n').trim();
  }
}
