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
    final response = await _request(
      () => http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'model': model, 'prompt': prompt, 'stream': false}),
      ),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AiUnavailableException('Ollama a répondu avec le code ${response.statusCode}. Vérifiez l’URL et le modèle.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['response'] as String? ?? 'Réponse vide du modèle Ollama.';
  }

  Future<List<String>> listModels() async {
    final uri = Uri.parse('${baseUrl.replaceAll(RegExp(r'/$'), '')}/api/tags');
    final response = await _request(() => http.get(uri));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AiUnavailableException('Ollama est joignable, mais la liste des modèles a échoué (${response.statusCode}).');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final models = data['models'] as List<dynamic>? ?? const [];
    return models.map((item) => (item as Map<String, dynamic>)['name'] as String? ?? '').where((name) => name.isNotEmpty).toList();
  }

  Future<http.Response> _request(Future<http.Response> Function() action) async {
    try {
      return await action().timeout(const Duration(seconds: 8));
    } catch (exception) {
      throw AiUnavailableException(_friendlyConnectionError(exception));
    }
  }

  String _friendlyConnectionError(Object exception) {
    final target = baseUrl.trim();
    if (target.contains('localhost') || target.contains('127.0.0.1')) {
      return 'Impossible de joindre Ollama à $target. Sur un téléphone Android réel, localhost désigne le téléphone, pas l’ordinateur. Utilisez l’IP locale du PC, par exemple http://192.168.1.20:11434, et lancez Ollama avec OLLAMA_HOST=0.0.0.0:11434.';
    }
    return 'Impossible de joindre Ollama à $target. Vérifiez que le téléphone et l’ordinateur sont sur le même Wi‑Fi, que l’URL finit par :11434, et que Ollama écoute sur 0.0.0.0. Détail : $exception';
  }
}
