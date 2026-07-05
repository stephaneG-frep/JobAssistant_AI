import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/history_provider.dart';
import 'offer_analysis_screen.dart';
import 'recruiter_reply_screen.dart';
import 'text_corrector_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryProvider>().items;
    final recent = history.take(5).toList();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('JobAssistant AI', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 6),
        Text('Assistant local pour valoriser votre vrai parcours.', style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OfferAnalysisScreen())),
              icon: const Icon(Icons.analytics),
              label: const Text('Analyser une offre'),
            ),
            FilledButton.tonalIcon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RecruiterReplyScreen())),
              icon: const Icon(Icons.quickreply_outlined),
              label: const Text('Réponse recruteur'),
            ),
            FilledButton.tonalIcon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TextCorrectorScreen())),
              icon: const Icon(Icons.edit_note),
              label: const Text('Corriger un texte'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _StatsGrid(items: history),
        const SizedBox(height: 24),
        Text('Activité récente', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        if (recent.isEmpty)
          const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('Aucun contenu généré pour le moment.')))
        else
          ...recent.map(
            (item) => Card(
              child: ListTile(
                leading: const Icon(Icons.auto_awesome),
                title: Text(item['title'] as String? ?? ''),
                subtitle: Text(item['type'] as String? ?? ''),
              ),
            ),
          ),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.items});

  final List<Map<String, dynamic>> items;

  @override
  Widget build(BuildContext context) {
    final counts = {
      'Offres': items.where((e) => e['type'] == 'Analyse offre').length,
      'CV': items.where((e) => e['type'] == 'Comparaison CV').length,
      'Lettres': items.where((e) => e['type'] == 'Lettre').length,
      'Entretiens': items.where((e) => e['type'] == 'Entretien').length,
      'Conseils': items.where((e) => e['type'] == 'Correction').length,
    };
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 700 ? 5 : 2;
        return GridView.count(
          crossAxisCount: columns,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.8,
          children: counts.entries
              .map((entry) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(entry.value.toString(), style: Theme.of(context).textTheme.headlineSmall),
                        const Spacer(),
                        Text(entry.key),
                      ]),
                    ),
                  ))
              .toList(),
        );
      },
    );
  }
}
