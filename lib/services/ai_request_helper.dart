import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/ai_provider.dart';
import '../providers/settings_provider.dart';

class AiRequestHelper {
  static Future<String?> generate(BuildContext context, String prompt) {
    return context.read<AiProvider>().generate(
          prompt,
          confirmExternalSend: () => _confirmExternalSend(context, prompt),
        );
  }

  static Future<bool> _confirmExternalSend(BuildContext context, String prompt) async {
    final settings = context.read<SettingsProvider>();
    if (settings.aiMode != AiMode.api || settings.privacyPreset != PrivacyPreset.apiWithConfirmation) {
      return true;
    }

    final preview = prompt.trim().replaceAll(RegExp(r'\s+'), ' ');
    final accepted = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmer l’envoi API'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Fournisseur : ${settings.apiProvider}'),
              Text('Modèle : ${settings.apiModel}'),
              const SizedBox(height: 12),
              const Text('Un extrait du contenu va être envoyé au fournisseur externe :'),
              const SizedBox(height: 8),
              Text(
                preview.length > 420 ? '${preview.substring(0, 420)}...' : preview,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Envoyer')),
        ],
      ),
    );
    return accepted == true;
  }
}
