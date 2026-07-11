import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../services/api_ai_service.dart';
import '../services/ollama_service.dart';
import 'profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _ollamaUrl;
  late final TextEditingController _ollamaModel;
  late final TextEditingController _apiProvider;
  late final TextEditingController _apiModel;
  late final TextEditingController _apiKey;
  late final TextEditingController _apiEndpoint;
  String _ollamaStatus = '';
  String _apiStatus = '';
  List<String> _ollamaModels = [];

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    _ollamaUrl = TextEditingController(text: settings.ollamaUrl);
    _ollamaModel = TextEditingController(text: settings.ollamaModel);
    _apiProvider = TextEditingController(text: settings.apiProvider);
    _apiModel = TextEditingController(text: settings.apiModel);
    _apiKey = TextEditingController(text: settings.apiKey);
    _apiEndpoint = TextEditingController(text: settings.apiEndpoint);
  }

  @override
  void dispose() {
    _ollamaUrl.dispose();
    _ollamaModel.dispose();
    _apiProvider.dispose();
    _apiModel.dispose();
    _apiKey.dispose();
    _apiEndpoint.dispose();
    super.dispose();
  }

  Future<void> _save(SettingsProvider settings, {bool showSnackBar = true}) async {
    await settings.save(
      newOllamaUrl: _ollamaUrl.text.trim().isEmpty ? 'http://localhost:11434' : _ollamaUrl.text.trim(),
      newOllamaModel: _ollamaModel.text.trim().isEmpty ? 'mistral' : _ollamaModel.text.trim(),
      newApiProvider: _apiProvider.text.trim().isEmpty ? 'OpenAI' : _apiProvider.text.trim(),
      newApiModel: _apiModel.text.trim().isEmpty ? _defaultApiModel(_apiProvider.text) : _apiModel.text.trim(),
      newApiKey: _apiKey.text.trim(),
      newApiEndpoint: _apiEndpoint.text.trim(),
    );
    if (mounted && showSnackBar) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Paramètres enregistrés localement.')));
  }

  String _defaultApiModel(String provider) {
    return switch (provider.toLowerCase().trim()) {
      'openai' => 'gpt-4.1-mini',
      'openrouter' => 'openai/gpt-4o-mini',
      'mistral' => 'mistral-small-latest',
      'groq' => 'llama-3.1-8b-instant',
      'anthropic' => 'claude-3-5-haiku-latest',
      'gemini' => 'gemini-1.5-flash',
      _ => 'gpt-4.1-mini',
    };
  }

  List<String> _modelSuggestions(String provider) {
    return switch (provider.toLowerCase().trim()) {
      'openai' => const ['gpt-4.1-mini', 'gpt-4.1', 'gpt-4o-mini'],
      'openrouter' => const ['openai/gpt-4o-mini', 'mistralai/mistral-small-3.1-24b-instruct', 'google/gemini-flash-1.5'],
      'mistral' => const ['mistral-small-latest', 'mistral-large-latest', 'codestral-latest'],
      'groq' => const ['llama-3.1-8b-instant', 'llama-3.3-70b-versatile', 'gemma2-9b-it'],
      'anthropic' => const ['claude-3-5-haiku-latest', 'claude-3-5-sonnet-latest'],
      'gemini' => const ['gemini-1.5-flash', 'gemini-1.5-pro'],
      _ => const ['gpt-4.1-mini'],
    };
  }

  Future<void> _testOllama() async {
    setState(() => _ollamaStatus = 'Test en cours...');
    try {
      final service = OllamaService(baseUrl: _ollamaUrl.text.trim(), model: _ollamaModel.text.trim());
      final models = await service.listModels();
      setState(() {
        _ollamaModels = models;
        _ollamaStatus = models.isEmpty ? 'Ollama répond, aucun modèle installé.' : 'Ollama connecté : ${models.length} modèle(s) disponible(s).';
      });
    } catch (exception) {
      setState(() => _ollamaStatus = exception.toString());
    }
  }

  Future<void> _testApi(SettingsProvider settings) async {
    await _save(settings, showSnackBar: false);
    if (!settings.apiConsent) {
      setState(() => _apiStatus = 'Test bloqué : activez le consentement explicite avant tout appel API.');
      return;
    }
    if (settings.privacyPreset == PrivacyPreset.localOnly) {
      setState(() => _apiStatus = 'Test bloqué : le préréglage "Local uniquement" interdit les appels API.');
      return;
    }

    setState(() => _apiStatus = 'Test API en cours...');
    try {
      final service = ApiAiService(
        provider: _apiProvider.text.trim(),
        model: _apiModel.text.trim(),
        apiKey: _apiKey.text.trim(),
        endpoint: _apiEndpoint.text.trim(),
      );
      final response = await service.testConnection();
      setState(() => _apiStatus = response.trim().isEmpty ? 'API connectée, mais réponse vide.' : 'API connectée : ${response.trim()}');
    } catch (exception) {
      setState(() => _apiStatus = exception.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Paramètres', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Confidentialité', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                const Text('Le mode local est prioritaire. Le mode API externe reste désactivé tant que vous n’activez pas le consentement explicite.'),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Mode sombre'),
                  value: settings.isDarkMode,
                  onChanged: (value) => settings.save(darkMode: value),
                ),
                const SizedBox(height: 8),
                SegmentedButton<PrivacyPreset>(
                  segments: PrivacyPreset.values
                      .map(
                        (preset) => ButtonSegment(
                          value: preset,
                          label: Text(preset.label),
                        ),
                      )
                      .toList(),
                  selected: {settings.privacyPreset},
                  onSelectionChanged: (value) {
                    final preset = value.first;
                    settings.save(
                      newPrivacyPreset: preset,
                      mode: preset == PrivacyPreset.localOnly ? AiMode.local : settings.aiMode,
                    );
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  _privacyDescription(settings.privacyPreset),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Profil local'),
                  subtitle: const Text('CV, compétences, expériences et préférences réutilisables'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SegmentedButton<AiMode>(
          segments: const [
            ButtonSegment(value: AiMode.local, label: Text('IA locale'), icon: Icon(Icons.computer)),
            ButtonSegment(value: AiMode.api, label: Text('API IA'), icon: Icon(Icons.cloud_outlined)),
          ],
          selected: {settings.aiMode},
          onSelectionChanged: (value) => settings.save(mode: value.first),
        ),
        const SizedBox(height: 16),
        Text('Ollama', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: Theme.of(context).colorScheme.tertiary),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Sur Linux/desktop, localhost fonctionne. Sur un Pixel réel, utilisez l’IP locale de l’ordinateur, par exemple http://192.168.1.20:11434. Ollama doit écouter sur 0.0.0.0:11434.',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextField(controller: _ollamaUrl, decoration: const InputDecoration(labelText: 'URL Ollama', hintText: 'http://192.168.1.20:11434')),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ActionChip(
              avatar: const Icon(Icons.computer, size: 18),
              label: const Text('Desktop local'),
              onPressed: () => setState(() => _ollamaUrl.text = 'http://localhost:11434'),
            ),
            ActionChip(
              avatar: const Icon(Icons.phone_android, size: 18),
              label: const Text('Émulateur'),
              onPressed: () => setState(() => _ollamaUrl.text = 'http://10.0.2.2:11434'),
            ),
            if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android)
              ActionChip(
                avatar: const Icon(Icons.wifi, size: 18),
                label: const Text('Pixel: IP du PC'),
                onPressed: () => setState(() => _ollamaUrl.text = 'http://192.168.1.X:11434'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: ['mistral', 'llama3', 'gemma', 'qwen'].contains(_ollamaModel.text) ? _ollamaModel.text : 'autre',
          decoration: const InputDecoration(labelText: 'Modèle'),
          items: const ['mistral', 'llama3', 'gemma', 'qwen', 'autre'].map((model) => DropdownMenuItem(value: model, child: Text(model))).toList(),
          onChanged: (value) => setState(() => _ollamaModel.text = value == 'autre' ? _ollamaModel.text : value ?? _ollamaModel.text),
        ),
        const SizedBox(height: 12),
        TextField(controller: _ollamaModel, decoration: const InputDecoration(labelText: 'Nom du modèle personnalisé')),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: () async {
                await _save(settings);
                await _testOllama();
              },
              icon: const Icon(Icons.wifi_tethering),
              label: const Text('Enregistrer et tester'),
            ),
            if (_ollamaModels.isNotEmpty)
              OutlinedButton.icon(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  builder: (_) => ListView(
                    children: _ollamaModels
                        .map(
                          (model) => ListTile(
                            title: Text(model),
                            onTap: () {
                              setState(() => _ollamaModel.text = model);
                              Navigator.pop(context);
                            },
                          ),
                        )
                        .toList(),
                  ),
                ),
                icon: const Icon(Icons.list),
                label: const Text('Modèles'),
              ),
          ],
        ),
        if (_ollamaStatus.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_ollamaStatus)),
        const SizedBox(height: 24),
        Text('API IA', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lock_outline, color: Theme.of(context).colorScheme.tertiary),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Vous choisissez le fournisseur et le modèle. La clé reste stockée localement. Aucune requête API n’est envoyée tant que le consentement explicite n’est pas activé.',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('J’autorise les envois vers une API externe'),
          subtitle: const Text('Aucune donnée n’est envoyée sans ce consentement.'),
          value: settings.apiConsent,
          onChanged: (value) => settings.save(
            consent: value,
            newPrivacyPreset: value && settings.privacyPreset == PrivacyPreset.localOnly ? PrivacyPreset.apiWithConfirmation : settings.privacyPreset,
          ),
        ),
        DropdownButtonFormField<String>(
          initialValue: const ['OpenAI', 'OpenRouter', 'Mistral', 'Groq', 'Anthropic', 'Gemini', 'Compatible OpenAI'].contains(_apiProvider.text) ? _apiProvider.text : 'Compatible OpenAI',
          decoration: const InputDecoration(labelText: 'Fournisseur API'),
          items: const ['OpenAI', 'OpenRouter', 'Mistral', 'Groq', 'Anthropic', 'Gemini', 'Compatible OpenAI']
              .map((provider) => DropdownMenuItem(value: provider, child: Text(provider)))
              .toList(),
          onChanged: (value) {
            final provider = value ?? 'OpenAI';
            setState(() {
              _apiProvider.text = provider;
              _apiModel.text = _defaultApiModel(provider);
              if (provider != 'Compatible OpenAI') _apiEndpoint.clear();
            });
          },
        ),
        const SizedBox(height: 12),
        TextField(controller: _apiModel, decoration: const InputDecoration(labelText: 'Modèle API')),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _modelSuggestions(_apiProvider.text)
              .map(
                (model) => ActionChip(
                  label: Text(model),
                  onPressed: () => setState(() => _apiModel.text = model),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _apiEndpoint,
          decoration: const InputDecoration(
            labelText: 'Endpoint optionnel',
            hintText: 'Ex: https://api.openai.com/v1/chat/completions',
          ),
        ),
        const SizedBox(height: 12),
        TextField(controller: _apiKey, obscureText: true, decoration: const InputDecoration(labelText: 'Clé API stockée localement')),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(onPressed: () => _save(settings), icon: const Icon(Icons.save), label: const Text('Enregistrer')),
            OutlinedButton.icon(onPressed: () => _testApi(settings), icon: const Icon(Icons.cloud_done_outlined), label: const Text('Tester l’API')),
          ],
        ),
        if (_apiStatus.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_apiStatus)),
      ],
    );
  }

  String _privacyDescription(PrivacyPreset preset) {
    return switch (preset) {
      PrivacyPreset.localOnly => 'Aucun contenu n’est envoyé vers une API externe. Utilise uniquement Ollama si disponible.',
      PrivacyPreset.apiWithConfirmation => 'Chaque génération API affiche une confirmation avec fournisseur, modèle et extrait du contenu.',
      PrivacyPreset.apiDirect => 'Les appels API partent directement si le consentement explicite est actif.',
    };
  }
}
