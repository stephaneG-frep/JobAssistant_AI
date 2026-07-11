import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/ai_provider.dart';
import '../providers/history_provider.dart';
import '../providers/profile_provider.dart';
import '../services/ai_request_helper.dart';
import '../services/file_import_service.dart';
import '../services/prompt_builder_service.dart';
import '../widgets/ai_response_card.dart';
import '../widgets/prompt_input_box.dart';
import '../widgets/score_indicator.dart';

class CvMatchScreen extends StatefulWidget {
  const CvMatchScreen({super.key});

  @override
  State<CvMatchScreen> createState() => _CvMatchScreenState();
}

class _CvMatchScreenState extends State<CvMatchScreen> {
  final _cv = TextEditingController();
  final _offer = TextEditingController();
  String _result = '';
  int _score = 0;

  @override
  void dispose() {
    _cv.dispose();
    _offer.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    final profile = context.read<ProfileProvider>().profile;
    final cvText = _cv.text.trim().isEmpty ? profile.defaultCv : _cv.text;
    final result = await AiRequestHelper.generate(context, PromptBuilderService().cvMatch('$cvText\n\n${profile.contextBlock}', _offer.text));
    if (!mounted || result == null) return;
    final match = RegExp(r'(\d{1,3})\s*/\s*100|score\D+(\d{1,3})', caseSensitive: false).firstMatch(result);
    setState(() {
      _result = result;
      _score = int.tryParse(match?.group(1) ?? match?.group(2) ?? '')?.clamp(0, 100) ?? 0;
    });
    await context.read<HistoryProvider>().add(type: 'Comparaison CV', title: 'CV comparé à une offre', content: result);
  }

  Future<void> _improveCv() async {
    final profile = context.read<ProfileProvider>().profile;
    final cvText = _cv.text.trim().isEmpty ? profile.defaultCv : _cv.text;
    final result = await AiRequestHelper.generate(context, PromptBuilderService().improveWithoutInventing(cvText));
    if (!mounted || result == null) return;
    setState(() => _result = result);
    await context.read<HistoryProvider>().add(type: 'Correction', title: 'CV amélioré sans invention', content: result);
  }

  @override
  Widget build(BuildContext context) {
    final ai = context.watch<AiProvider>();
    final profile = context.watch<ProfileProvider>().profile;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Comparaison CV / offre', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        PromptInputBox(
          controller: _cv,
          label: 'CV en texte',
          minLines: 6,
          action: Wrap(
            spacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () async {
                  final text = await FileImportService().pickTextFile();
                  if (text != null) setState(() => _cv.text = text);
                },
                icon: const Icon(Icons.upload_file),
                label: const Text('Importer'),
              ),
              OutlinedButton.icon(
                onPressed: profile.defaultCv.trim().isEmpty ? null : () => setState(() => _cv.text = profile.defaultCv),
                icon: const Icon(Icons.person),
                label: const Text('Profil'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        PromptInputBox(controller: _offer, label: 'Offre ciblée', minLines: 6),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(onPressed: ai.isLoading ? null : _run, icon: const Icon(Icons.compare_arrows), label: Text(ai.isLoading ? 'Comparaison...' : 'Comparer')),
            FilledButton.tonalIcon(onPressed: ai.isLoading ? null : _improveCv, icon: const Icon(Icons.verified_user_outlined), label: const Text('Améliorer sans inventer')),
          ],
        ),
        if (_result.isNotEmpty) Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: ScoreIndicator(score: _score)),
        if (ai.error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(ai.error!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
        AiResponseCard(title: 'Recommandations CV', content: _result, onContentChanged: (value) => setState(() => _result = value)),
      ],
    );
  }
}
