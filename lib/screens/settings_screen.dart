import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
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
  late final TextEditingController _apiKey;
  late final TextEditingController _apiEndpoint;
  String _ollamaStatus = '';
  List<String> _ollamaModels = [];

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    _ollamaUrl = TextEditingController(text: settings.ollamaUrl);
    _ollamaModel = TextEditingController(text: settings.ollamaModel);
    _apiProvider = TextEditingController(text: settings.apiProvider);
    _apiKey = TextEditingController(text: settings.apiKey);
    _apiEndpoint = TextEditingController(text: settings.apiEndpoint);
  }

  @override
  void dispose() {
    _ollamaUrl.dispose();
    _ollamaModel.dispose();
    _apiProvider.dispose();
    _apiKey.dispose();
    _apiEndpoint.dispose();
    super.dispose();
  }

  Future<void> _save(SettingsProvider settings) async {
    await settings.save(
      newOllamaUrl: _ollamaUrl.text.trim().isEmpty ? 'http://localhost:11434' : _ollamaUrl.text.trim(),
      newOllamaModel: _ollamaModel.text.trim().isEmpty ? 'mistral' : _ollamaModel.text.trim(),
      newApiProvider: _apiProvider.text.trim().isEmpty ? 'OpenAI' : _apiProvider.text.trim(),
      newApiKey: _apiKey.text.trim(),
      newApiEndpoint: _apiEndpoint.text.trim(),
    );
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Paramètres enregistrés localement.')));
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
        TextField(controller: _ollamaUrl, decoration: const InputDecoration(labelText: 'URL Ollama', hintText: 'http://localhost:11434')),
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
            OutlinedButton.icon(onPressed: _testOllama, icon: const Icon(Icons.wifi_tethering), label: const Text('Tester Ollama')),
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
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('J’autorise les envois vers une API externe'),
          subtitle: const Text('Aucune donnée n’est envoyée sans ce consentement.'),
          value: settings.apiConsent,
          onChanged: (value) => settings.save(consent: value),
        ),
        TextField(controller: _apiProvider, decoration: const InputDecoration(labelText: 'Fournisseur', hintText: 'OpenAI')),
        const SizedBox(height: 12),
        TextField(controller: _apiEndpoint, decoration: const InputDecoration(labelText: 'Endpoint compatible optionnel')),
        const SizedBox(height: 12),
        TextField(controller: _apiKey, obscureText: true, decoration: const InputDecoration(labelText: 'Clé API stockée localement')),
        const SizedBox(height: 16),
        FilledButton.icon(onPressed: () => _save(settings), icon: const Icon(Icons.save), label: const Text('Enregistrer')),
      ],
    );
  }
}
