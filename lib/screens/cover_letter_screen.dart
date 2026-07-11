import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/ai_provider.dart';
import '../providers/history_provider.dart';
import '../providers/template_provider.dart';
import '../services/ai_request_helper.dart';
import '../services/prompt_builder_service.dart';
import '../widgets/ai_response_card.dart';
import '../widgets/prompt_input_box.dart';

class CoverLetterScreen extends StatefulWidget {
  const CoverLetterScreen({super.key});

  @override
  State<CoverLetterScreen> createState() => _CoverLetterScreenState();
}

class _CoverLetterScreenState extends State<CoverLetterScreen> {
  final _position = TextEditingController();
  final _company = TextEditingController();
  final _offer = TextEditingController();
  final _profile = TextEditingController();
  String _tone = 'professionnel';
  String _result = '';

  @override
  void dispose() {
    _position.dispose();
    _company.dispose();
    _offer.dispose();
    _profile.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    final result = await AiRequestHelper.generate(
      context,
          PromptBuilderService().coverLetter(position: _position.text, company: _company.text, offer: _offer.text, profile: _profile.text, tone: _tone),
        );
    if (!mounted || result == null) return;
    setState(() => _result = result);
    await context.read<HistoryProvider>().add(type: 'Lettre', title: 'Lettre ${_position.text}', content: result);
  }

  @override
  Widget build(BuildContext context) {
    final ai = context.watch<AiProvider>();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Lettre de motivation', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        TextField(controller: _position, decoration: const InputDecoration(labelText: 'Poste')),
        const SizedBox(height: 12),
        TextField(controller: _company, decoration: const InputDecoration(labelText: 'Entreprise')),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _tone,
          decoration: const InputDecoration(labelText: 'Ton souhaité'),
          items: const ['professionnel', 'simple', 'motivé', 'court', 'humain', 'original'].map((tone) => DropdownMenuItem(value: tone, child: Text(tone))).toList(),
          onChanged: (value) => setState(() => _tone = value ?? _tone),
        ),
        const SizedBox(height: 12),
        PromptInputBox(controller: _offer, label: 'Offre', minLines: 5),
        const SizedBox(height: 12),
        PromptInputBox(controller: _profile, label: 'Profil personnel réel', hint: 'Expériences, compétences, motivations vérifiables...', minLines: 5),
        const SizedBox(height: 12),
        FilledButton.icon(onPressed: ai.isLoading ? null : _run, icon: const Icon(Icons.mail), label: Text(ai.isLoading ? 'Rédaction...' : 'Générer')),
        if (ai.error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(ai.error!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
        const SizedBox(height: 16),
        AiResponseCard(
          title: 'Lettre générée',
          content: _result,
          onContentChanged: (value) => setState(() => _result = value),
          onSaveTemplate: _result.isEmpty ? null : () => context.read<TemplateProvider>().addFromContent('Lettre ${_position.text}', 'Lettre', _result),
        ),
      ],
    );
  }
}
