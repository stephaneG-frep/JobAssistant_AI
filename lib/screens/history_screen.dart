import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/history_provider.dart';
import '../providers/template_provider.dart';
import '../services/pdf_export_service.dart';
import '../widgets/history_tile.dart';
import '../widgets/template_card.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryProvider>();
    final templates = context.watch<TemplateProvider>();
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Expanded(child: Text('Historique', style: Theme.of(context).textTheme.headlineSmall)),
                IconButton(
                  tooltip: 'Exporter JSON',
                  onPressed: () => PdfExportService().exportJson(title: 'historique_jobassistant', json: history.exportJson()),
                  icon: const Icon(Icons.data_object),
                ),
                IconButton(
                  tooltip: 'Effacer tout',
                  onPressed: history.items.isEmpty
                      ? null
                      : () async {
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Effacer l’historique ?'),
                              content: const Text('Cette action supprime les contenus stockés localement.'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
                                FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Effacer')),
                              ],
                            ),
                          );
                          if (ok == true && context.mounted) await context.read<HistoryProvider>().clear();
                        },
                  icon: const Icon(Icons.delete_sweep_outlined),
                ),
              ],
            ),
          ),
          const TabBar(tabs: [Tab(text: 'Générations'), Tab(text: 'Favoris et modèles')]),
          Expanded(
            child: TabBarView(
              children: [
                history.items.isEmpty
                    ? const Center(child: Text('Aucune génération enregistrée.'))
                    : ListView.builder(
                        itemCount: history.items.length,
                        itemBuilder: (context, index) => HistoryTile(item: history.items[index], onDelete: () => history.delete(history.items[index]['id'] as String)),
                      ),
                templates.templates.isEmpty
                    ? const Center(child: Text('Aucun modèle sauvegardé.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: templates.templates.length,
                        itemBuilder: (context, index) {
                          final template = templates.templates[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: TemplateCard(
                              template: template,
                              onUse: () => showDialog<void>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: Text(template.title),
                                  content: SingleChildScrollView(child: SelectableText(template.content)),
                                  actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer'))],
                                ),
                              ),
                              onFavorite: () => templates.save(template.copyWith(favorite: !template.favorite)),
                              onDelete: () => templates.delete(template.id),
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
