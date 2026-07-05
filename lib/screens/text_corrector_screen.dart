import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/ai_provider.dart';
import '../providers/history_provider.dart';
import '../services/prompt_builder_service.dart';
import '../widgets/ai_response_card.dart';
import '../widgets/prompt_input_box.dart';

class TextCorrectorScreen extends StatefulWidget {
  const TextCorrectorScreen({super.key});

  @override
  State<TextCorrectorScreen> createState() => _TextCorrectorScreenState();
}

class _TextCorrectorScreenState extends State<TextCorrectorScreen> {
  final _text = TextEditingController();
  String _result = '';

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    final result = await context.read<AiProvider>().generate(PromptBuilderService().textCorrection(_text.text));
    if (!mounted || result == null) return;
    setState(() => _result = result);
    await context.read<HistoryProvider>().add(type: 'Correction', title: 'Correction professionnelle', content: result);
  }

  Future<void> _improveTruthfully() async {
    final result = await context.read<AiProvider>().generate(PromptBuilderService().improveWithoutInventing(_text.text));
    if (!mounted || result == null) return;
    setState(() => _result = result);
    await context.read<HistoryProvider>().add(type: 'Correction', title: 'Amélioration sans invention', content: result);
  }

  @override
  Widget build(BuildContext context) {
    final ai = context.watch<AiProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Correcteur professionnel')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PromptInputBox(controller: _text, label: 'Texte à améliorer', minLines: 8),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(onPressed: ai.isLoading ? null : _run, icon: const Icon(Icons.edit_note), label: Text(ai.isLoading ? 'Correction...' : 'Corriger')),
              FilledButton.tonalIcon(onPressed: ai.isLoading ? null : _improveTruthfully, icon: const Icon(Icons.verified_user_outlined), label: const Text('Améliorer sans inventer')),
            ],
          ),
          if (ai.error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(ai.error!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
          const SizedBox(height: 16),
          AiResponseCard(title: 'Texte amélioré', content: _result, onContentChanged: (value) => setState(() => _result = value)),
        ],
      ),
    );
  }
}
