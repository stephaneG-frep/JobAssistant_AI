import 'package:flutter/material.dart';

import '../models/saved_template.dart';

class TemplateCard extends StatelessWidget {
  const TemplateCard({super.key, required this.template, this.onUse, this.onFavorite, this.onDelete});

  final SavedTemplate template;
  final VoidCallback? onUse;
  final VoidCallback? onFavorite;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(template.favorite ? Icons.star : Icons.article_outlined),
        title: Text(template.title),
        subtitle: Text(template.category, maxLines: 1, overflow: TextOverflow.ellipsis),
        onTap: onUse,
        trailing: Wrap(
          children: [
            IconButton(onPressed: onFavorite, tooltip: 'Favori', icon: const Icon(Icons.star_border)),
            IconButton(onPressed: onDelete, tooltip: 'Supprimer', icon: const Icon(Icons.delete_outline)),
          ],
        ),
      ),
    );
  }
}
