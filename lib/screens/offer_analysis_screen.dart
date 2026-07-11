import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/ai_provider.dart';
import '../providers/history_provider.dart';
import '../services/ai_request_helper.dart';
import '../services/prompt_builder_service.dart';
import '../widgets/ai_response_card.dart';
import '../widgets/prompt_input_box.dart';

class OfferAnalysisScreen extends StatefulWidget {
  const OfferAnalysisScreen({super.key});

  @override
  State<OfferAnalysisScreen> createState() => _OfferAnalysisScreenState();
}

class _OfferAnalysisScreenState extends State<OfferAnalysisScreen> {
  final _offer = TextEditingController();
  String _result = '';

  @override
  void dispose() {
    _offer.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    final result = await AiRequestHelper.generate(context, PromptBuilderService().offerAnalysis(_offer.text));
    if (!mounted || result == null) return;
    setState(() => _result = result);
    await context.read<HistoryProvider>().add(type: 'Analyse offre', title: 'Analyse d’offre', content: result, metadata: {'offer': _offer.text});
  }

  @override
  Widget build(BuildContext context) {
    final ai = context.watch<AiProvider>();
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Analyse d’offre', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          PromptInputBox(controller: _offer, label: 'Collez l’offre d’emploi', hint: 'Missions, profil recherché, contrat, entreprise...'),
          const SizedBox(height: 12),
          FilledButton.icon(onPressed: ai.isLoading ? null : _run, icon: const Icon(Icons.auto_awesome), label: Text(ai.isLoading ? 'Analyse en cours...' : 'Analyser')),
          if (ai.error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(ai.error!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
          const SizedBox(height: 16),
          AiResponseCard(title: 'Analyse générée', content: _result),
        ],
      ),
    );
  }
}
