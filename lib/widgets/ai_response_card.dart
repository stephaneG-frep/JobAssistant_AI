import 'package:flutter/material.dart';

import 'export_button.dart';

class AiResponseCard extends StatelessWidget {
  const AiResponseCard({super.key, required this.title, required this.content, this.onSaveTemplate});

  final String title;
  final String content;
  final VoidCallback? onSaveTemplate;

  @override
  Widget build(BuildContext context) {
    if (content.trim().isEmpty) return const SizedBox.shrink();
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: Theme.of(context).colorScheme.secondary),
                const SizedBox(width: 8),
                Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
                ExportButton(title: title, content: content),
                if (onSaveTemplate != null) IconButton(onPressed: onSaveTemplate, tooltip: 'Sauvegarder en modèle', icon: const Icon(Icons.bookmark_add_outlined)),
              ],
            ),
            const Divider(height: 24),
            SelectableText(content),
          ],
        ),
      ),
    );
  }
}
