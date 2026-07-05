import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryTile extends StatelessWidget {
  const HistoryTile({super.key, required this.item, this.onDelete});

  final Map<String, dynamic> item;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(item['createdAt'] as String? ?? '');
    return ListTile(
      leading: const Icon(Icons.history),
      title: Text(item['title'] as String? ?? 'Sans titre', maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text('${item['type'] ?? 'contenu'} • ${date == null ? '' : DateFormat('dd/MM/yyyy HH:mm').format(date)}'),
      trailing: onDelete == null ? null : IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline), tooltip: 'Supprimer'),
      onTap: () => showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(item['title'] as String? ?? 'Historique'),
          content: SingleChildScrollView(child: SelectableText(item['content'] as String? ?? '')),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer'))],
        ),
      ),
    );
  }
}
