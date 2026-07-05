import 'package:flutter/material.dart';

import 'export_button.dart';

class AiResponseCard extends StatefulWidget {
  const AiResponseCard({super.key, required this.title, required this.content, this.onSaveTemplate, this.onContentChanged});

  final String title;
  final String content;
  final VoidCallback? onSaveTemplate;
  final ValueChanged<String>? onContentChanged;

  @override
  State<AiResponseCard> createState() => _AiResponseCardState();
}

class _AiResponseCardState extends State<AiResponseCard> {
  late String _content;

  @override
  void initState() {
    super.initState();
    _content = widget.content;
  }

  @override
  void didUpdateWidget(covariant AiResponseCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.content != widget.content) _content = widget.content;
  }

  Future<void> _edit() async {
    final controller = TextEditingController(text: _content);
    final next = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Modifier ${widget.title}'),
        content: SizedBox(
          width: 620,
          child: TextField(controller: controller, minLines: 12, maxLines: null, decoration: const InputDecoration(labelText: 'Texte éditable')),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Appliquer')),
        ],
      ),
    );
    if (next == null) return;
    setState(() => _content = next);
    widget.onContentChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    if (_content.trim().isEmpty) return const SizedBox.shrink();
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
                Expanded(child: Text(widget.title, style: Theme.of(context).textTheme.titleMedium)),
                IconButton(onPressed: _edit, tooltip: 'Modifier', icon: const Icon(Icons.edit_outlined)),
                ExportButton(title: widget.title, content: _content),
                if (widget.onSaveTemplate != null) IconButton(onPressed: widget.onSaveTemplate, tooltip: 'Sauvegarder en modèle', icon: const Icon(Icons.bookmark_add_outlined)),
              ],
            ),
            const Divider(height: 24),
            SelectableText(_content),
          ],
        ),
      ),
    );
  }
}
