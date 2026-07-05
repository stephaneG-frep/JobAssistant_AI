import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/ai_provider.dart';
import '../providers/history_provider.dart';
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
    final result = await context.read<AiProvider>().generate(PromptBuilderService().cvMatch(_cv.text, _offer.text));
    if (!mounted || result == null) return;
    final match = RegExp(r'(\d{1,3})\s*/\s*100|score\D+(\d{1,3})', caseSensitive: false).firstMatch(result);
    setState(() {
      _result = result;
      _score = int.tryParse(match?.group(1) ?? match?.group(2) ?? '')?.clamp(0, 100) ?? 0;
    });
    await context.read<HistoryProvider>().add(type: 'Comparaison CV', title: 'CV comparé à une offre', content: result);
  }

  @override
  Widget build(BuildContext context) {
    final ai = context.watch<AiProvider>();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Comparaison CV / offre', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        PromptInputBox(controller: _cv, label: 'CV en texte', minLines: 6),
        const SizedBox(height: 12),
        PromptInputBox(controller: _offer, label: 'Offre ciblée', minLines: 6),
        const SizedBox(height: 12),
        FilledButton.icon(onPressed: ai.isLoading ? null : _run, icon: const Icon(Icons.compare_arrows), label: Text(ai.isLoading ? 'Comparaison...' : 'Comparer')),
        if (_result.isNotEmpty) Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: ScoreIndicator(score: _score)),
        if (ai.error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(ai.error!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
        AiResponseCard(title: 'Recommandations CV', content: _result),
      ],
    );
  }
}
