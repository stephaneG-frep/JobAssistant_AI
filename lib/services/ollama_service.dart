import 'dart:convert';

import 'package:http/http.dart' as http;

import 'ai_service.dart';

class OllamaService implements AiService {
  OllamaService({required this.baseUrl, required this.model});

  final String baseUrl;
  final String model;

  @override
  Future<String> generate(String prompt) async {
    final uri = Uri.parse('${baseUrl.replaceAll(RegExp(r'/$'), '')}/api/generate');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'model': model, 'prompt': prompt, 'stream': false}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AiUnavailableException('Ollama a répondu avec le code ${response.statusCode}. Vérifiez l’URL et le modèle.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['response'] as String? ?? 'Réponse vide du modèle Ollama.';
  }
}
