import 'dart:convert';

import 'package:http/http.dart' as http;

import 'ai_service.dart';

class ApiAiService implements AiService {
  ApiAiService({
    required this.provider,
    required this.model,
    required this.apiKey,
    this.endpoint,
  });

  final String provider;
  final String model;
  final String apiKey;
  final String? endpoint;

  @override
  Future<String> generate(String prompt) async {
    if (apiKey.trim().isEmpty) {
      throw AiUnavailableException('Ajoutez une clé API dans les paramètres avant d’utiliser le mode API.');
    }

    final normalized = provider.toLowerCase().trim();
    if (normalized == 'openai') return _openAiResponses(prompt);
    if (normalized == 'anthropic') return _anthropic(prompt);
    if (normalized == 'gemini') return _gemini(prompt);
    if (['openrouter', 'mistral', 'groq', 'compatible openai'].contains(normalized)) {
      return _chatCompletions(prompt, defaultEndpoint: _defaultChatEndpoint(normalized));
    }

    throw AiUnavailableException('Fournisseur "$provider" non reconnu. Choisissez un fournisseur dans les paramètres.');
  }

  Future<String> testConnection() => generate('Réponds uniquement par : OK JobAssistant AI');

  Future<String> _openAiResponses(String prompt) async {
    final response = await _post(
      Uri.parse(_endpointOr('https://api.openai.com/v1/responses')),
      headers: {'Authorization': 'Bearer $apiKey', 'Content-Type': 'application/json'},
      body: {
        'model': model.trim().isEmpty ? 'gpt-4.1-mini' : model.trim(),
        'input': prompt,
      },
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final outputText = data['output_text'] as String?;
    if (outputText != null && outputText.trim().isNotEmpty) return outputText.trim();
    final output = data['output'] as List<dynamic>? ?? const [];
    final parts = output.expand((item) => (item as Map<String, dynamic>)['content'] as List<dynamic>? ?? const []);
    return parts.map((part) => (part as Map<String, dynamic>)['text'] ?? '').join('\n').trim();
  }

  Future<String> _chatCompletions(String prompt, {required String defaultEndpoint}) async {
    final response = await _post(
      Uri.parse(_endpointOr(defaultEndpoint)),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
        if (provider.toLowerCase() == 'openrouter') 'HTTP-Referer': 'https://jobassistant.local',
        if (provider.toLowerCase() == 'openrouter') 'X-Title': 'JobAssistant AI',
      },
      body: {
        'model': model.trim(),
        'messages': [
          {'role': 'system', 'content': 'Tu es JobAssistant AI. Tu aides à valoriser un parcours réel sans inventer.'},
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.4,
      },
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = data['choices'] as List<dynamic>? ?? const [];
    if (choices.isEmpty) return '';
    final message = (choices.first as Map<String, dynamic>)['message'] as Map<String, dynamic>? ?? const {};
    return (message['content'] as String? ?? '').trim();
  }

  Future<String> _anthropic(String prompt) async {
    final response = await _post(
      Uri.parse(_endpointOr('https://api.anthropic.com/v1/messages')),
      headers: {
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
        'Content-Type': 'application/json',
      },
      body: {
        'model': model.trim().isEmpty ? 'claude-3-5-haiku-latest' : model.trim(),
        'max_tokens': 1800,
        'system': 'Tu es JobAssistant AI. Tu aides à valoriser un parcours réel sans inventer.',
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
      },
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final content = data['content'] as List<dynamic>? ?? const [];
    return content.map((part) => (part as Map<String, dynamic>)['text'] ?? '').join('\n').trim();
  }

  Future<String> _gemini(String prompt) async {
    final selectedModel = model.trim().isEmpty ? 'gemini-1.5-flash' : model.trim();
    final uri = Uri.parse(_endpointOr('https://generativelanguage.googleapis.com/v1beta/models/$selectedModel:generateContent?key=$apiKey'));
    final response = await _post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: {
        'systemInstruction': {
          'parts': [
            {'text': 'Tu es JobAssistant AI. Tu aides à valoriser un parcours réel sans inventer.'},
          ],
        },
        'contents': [
          {
            'parts': [
              {'text': prompt},
            ],
          },
        ],
      },
      includeAuthorization: false,
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = data['candidates'] as List<dynamic>? ?? const [];
    if (candidates.isEmpty) return '';
    final content = (candidates.first as Map<String, dynamic>)['content'] as Map<String, dynamic>? ?? const {};
    final parts = content['parts'] as List<dynamic>? ?? const [];
    return parts.map((part) => (part as Map<String, dynamic>)['text'] ?? '').join('\n').trim();
  }

  Future<http.Response> _post(
    Uri uri, {
    required Map<String, String> headers,
    required Map<String, dynamic> body,
    bool includeAuthorization = true,
  }) async {
    try {
      final response = await http
          .post(
            uri,
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 45));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw AiUnavailableException('API IA indisponible (${response.statusCode}). Vérifiez fournisseur, modèle, clé et endpoint.');
      }
      return response;
    } on AiUnavailableException {
      rethrow;
    } catch (exception) {
      throw AiUnavailableException('Impossible de joindre le fournisseur "$provider". Détail : $exception');
    }
  }

  String _endpointOr(String fallback) => endpoint?.trim().isNotEmpty == true ? endpoint!.trim() : fallback;

  String _defaultChatEndpoint(String normalizedProvider) {
    return switch (normalizedProvider) {
      'openrouter' => 'https://openrouter.ai/api/v1/chat/completions',
      'mistral' => 'https://api.mistral.ai/v1/chat/completions',
      'groq' => 'https://api.groq.com/openai/v1/chat/completions',
      _ => 'https://api.openai.com/v1/chat/completions',
    };
  }
}
