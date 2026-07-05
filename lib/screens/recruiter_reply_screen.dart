import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/ai_provider.dart';
import '../providers/history_provider.dart';
import '../providers/template_provider.dart';
import '../services/prompt_builder_service.dart';
import '../widgets/ai_response_card.dart';
import '../widgets/prompt_input_box.dart';

class RecruiterReplyScreen extends StatefulWidget {
  const RecruiterReplyScreen({super.key});

  @override
  State<RecruiterReplyScreen> createState() => _RecruiterReplyScreenState();
}

class _RecruiterReplyScreenState extends State<RecruiterReplyScreen> {
  final _context = TextEditingController();
  String _kind = 'Réponse positive';
  String _result = '';

  @override
  void dispose() {
    _context.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    final result = await context.read<AiProvider>().generate(PromptBuilderService().recruiterReply(_kind, _context.text));
    if (!mounted || result == null) return;
    setState(() => _result = result);
    await context.read<HistoryProvider>().add(type: 'Réponse recruteur', title: _kind, content: result);
  }

  @override
  Widget build(BuildContext context) {
    final ai = context.watch<AiProvider>();
    const kinds = [
      'Réponse positive',
      'Demande d’informations',
      'Confirmation d’entretien',
      'Relance après candidature',
      'Relance après entretien',
      'Refus poli',
      'Remerciement',
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Réponses recruteurs')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            initialValue: _kind,
            decoration: const InputDecoration(labelText: 'Modèle'),
            items: kinds.map((kind) => DropdownMenuItem(value: kind, child: Text(kind))).toList(),
            onChanged: (value) => setState(() => _kind = value ?? _kind),
          ),
          const SizedBox(height: 12),
          PromptInputBox(controller: _context, label: 'Contexte à personnaliser', minLines: 5),
          const SizedBox(height: 12),
          FilledButton.icon(onPressed: ai.isLoading ? null : _run, icon: const Icon(Icons.quickreply), label: Text(ai.isLoading ? 'Génération...' : 'Générer')),
          if (ai.error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(ai.error!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
          const SizedBox(height: 16),
          AiResponseCard(
            title: _kind,
            content: _result,
            onSaveTemplate: _result.isEmpty ? null : () => context.read<TemplateProvider>().addFromContent(_kind, 'Réponse recruteur', _result),
          ),
        ],
      ),
    );
  }
}
