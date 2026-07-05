import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/application_project.dart';
import '../providers/application_provider.dart';

class ApplicationProjectsScreen extends StatelessWidget {
  const ApplicationProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ApplicationProvider>();
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(child: Text('Candidatures', style: Theme.of(context).textTheme.headlineSmall)),
              FilledButton.icon(
                onPressed: () => _showProjectDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Ajouter'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (provider.projects.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Aucune candidature suivie. Ajoutez une offre pour regrouper CV, lettre, statut, notes et relances.'),
              ),
            )
          else
            ...provider.projects.map((project) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ApplicationCard(project: project),
                )),
        ],
      ),
    );
  }

  Future<void> _showProjectDialog(BuildContext context, {ApplicationProject? project}) async {
    final company = TextEditingController(text: project?.company ?? '');
    final position = TextEditingController(text: project?.position ?? '');
    final offer = TextEditingController(text: project?.offerText ?? '');
    final cv = TextEditingController(text: project?.cvText ?? '');
    final notes = TextEditingController(text: project?.notes ?? '');
    var status = project?.status ?? ApplicationStatus.toApply;

    await showDialog<void>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(project == null ? 'Nouvelle candidature' : 'Modifier la candidature'),
          content: SizedBox(
            width: 560,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: company, decoration: const InputDecoration(labelText: 'Entreprise')),
                  const SizedBox(height: 10),
                  TextField(controller: position, decoration: const InputDecoration(labelText: 'Poste')),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<ApplicationStatus>(
                    initialValue: status,
                    decoration: const InputDecoration(labelText: 'Statut'),
                    items: ApplicationStatus.values.map((item) => DropdownMenuItem(value: item, child: Text(item.label))).toList(),
                    onChanged: (value) => setState(() => status = value ?? status),
                  ),
                  const SizedBox(height: 10),
                  TextField(controller: offer, minLines: 3, maxLines: null, decoration: const InputDecoration(labelText: 'Offre')),
                  const SizedBox(height: 10),
                  TextField(controller: cv, minLines: 3, maxLines: null, decoration: const InputDecoration(labelText: 'CV utilisé')),
                  const SizedBox(height: 10),
                  TextField(controller: notes, minLines: 3, maxLines: null, decoration: const InputDecoration(labelText: 'Notes')),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
            FilledButton(
              onPressed: () async {
                final provider = context.read<ApplicationProvider>();
                if (project == null) {
                  await provider.add(company: company.text, position: position.text, offerText: offer.text, cvText: cv.text, notes: notes.text);
                } else {
                  await provider.save(project.copyWith(company: company.text, position: position.text, status: status, offerText: offer.text, cvText: cv.text, notes: notes.text));
                }
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard({required this.project});

  final ApplicationProject project;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(project.position.isEmpty ? 'Poste non renseigné' : project.position, style: Theme.of(context).textTheme.titleMedium)),
                Chip(label: Text(project.status.label)),
              ],
            ),
            Text(project.company.isEmpty ? 'Entreprise non renseignée' : project.company),
            const SizedBox(height: 8),
            if (project.notes.isNotEmpty) Text(project.notes, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => ApplicationProjectsScreen()._showProjectDialog(context, project: project),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Modifier'),
                ),
                IconButton(
                  tooltip: 'Supprimer',
                  onPressed: () => context.read<ApplicationProvider>().delete(project.id),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
