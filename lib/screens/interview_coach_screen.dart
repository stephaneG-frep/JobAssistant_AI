import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/ai_provider.dart';
import '../providers/history_provider.dart';
import '../services/ai_request_helper.dart';
import '../services/prompt_builder_service.dart';
import '../widgets/ai_response_card.dart';
import '../widgets/prompt_input_box.dart';

class InterviewCoachScreen extends StatefulWidget {
  const InterviewCoachScreen({super.key});

  @override
  State<InterviewCoachScreen> createState() => _InterviewCoachScreenState();
}

class _InterviewCoachScreenState extends State<InterviewCoachScreen> {
  final _offer = TextEditingController();
  final _notes = TextEditingController();
  String _result = '';

  @override
  void dispose() {
    _offer.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    final result = await AiRequestHelper.generate(context, PromptBuilderService().interviewCoach(_offer.text, _notes.text));
    if (!mounted || result == null) return;
    setState(() => _result = result);
    await context.read<HistoryProvider>().add(type: 'Entretien', title: 'Préparation entretien', content: result);
  }

  @override
  Widget build(BuildContext context) {
    final ai = context.watch<AiProvider>();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Coach entretien', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        PromptInputBox(controller: _offer, label: 'Offre ou poste ciblé', minLines: 6),
        const SizedBox(height: 12),
        PromptInputBox(controller: _notes, label: 'Notes personnelles', hint: 'Expériences à évoquer, points à clarifier, contraintes...', minLines: 4),
        const SizedBox(height: 12),
        FilledButton.icon(onPressed: ai.isLoading ? null : _run, icon: const Icon(Icons.record_voice_over), label: Text(ai.isLoading ? 'Préparation...' : 'Préparer')),
        if (ai.error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(ai.error!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
        const SizedBox(height: 16),
        AiResponseCard(title: 'Préparation entretien', content: _result),
      ],
    );
  }
}
