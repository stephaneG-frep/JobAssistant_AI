import 'package:flutter/foundation.dart';

import '../models/saved_template.dart';
import '../services/local_database_service.dart';

class TemplateProvider extends ChangeNotifier {
  TemplateProvider(this._database);

  final LocalDatabaseService _database;
  List<SavedTemplate> templates = [];

  void load() {
    templates = _database.getTemplates().map(SavedTemplate.fromJson).toList();
    if (templates.isEmpty) {
      _seedDefaults();
      return;
    }
    notifyListeners();
  }

  Future<void> save(SavedTemplate template) async {
    await _database.saveTemplate(template.toJson());
    load();
  }

  Future<void> addFromContent(String title, String category, String content) => save(
        SavedTemplate(id: DateTime.now().microsecondsSinceEpoch.toString(), title: title, category: category, content: content),
      );

  Future<void> delete(String id) async {
    await _database.deleteTemplate(id);
    load();
  }

  Future<void> _seedDefaults() async {
    final defaults = [
      SavedTemplate(
        id: 'default_positive_reply',
        title: 'Acceptation entretien',
        category: 'Réponse recruteur',
        content: 'Bonjour,\n\nMerci pour votre retour. Je vous confirme mon intérêt pour le poste et suis disponible pour échanger aux créneaux proposés.\n\nBien cordialement,',
      ),
      SavedTemplate(
        id: 'default_info_request',
        title: 'Demande d’informations',
        category: 'Réponse recruteur',
        content: 'Bonjour,\n\nMerci pour votre message. Avant de confirmer la suite, pourriez-vous me préciser les missions principales, le format de travail et les prochaines étapes du processus ?\n\nBien cordialement,',
      ),
      SavedTemplate(
        id: 'default_application_followup',
        title: 'Relance candidature',
        category: 'Relance',
        content: 'Bonjour,\n\nJe me permets de revenir vers vous concernant ma candidature pour le poste. Je reste très intéressé par l’opportunité et disponible pour échanger si mon profil correspond à vos attentes.\n\nBien cordialement,',
      ),
      SavedTemplate(
        id: 'default_interview_followup',
        title: 'Relance après entretien',
        category: 'Relance',
        content: 'Bonjour,\n\nMerci encore pour notre échange. Il a renforcé mon intérêt pour le poste et pour votre équipe. Je reste disponible pour toute information complémentaire.\n\nBien cordialement,',
      ),
      SavedTemplate(
        id: 'default_polite_refusal',
        title: 'Refus poli',
        category: 'Réponse recruteur',
        content: 'Bonjour,\n\nMerci pour votre retour et pour le temps accordé à ma candidature. Après réflexion, je préfère ne pas poursuivre le processus pour cette opportunité. Je vous souhaite une excellente continuation dans votre recherche.\n\nBien cordialement,',
      ),
      SavedTemplate(
        id: 'default_linkedin_short',
        title: 'Message LinkedIn court',
        category: 'LinkedIn',
        content: 'Bonjour,\n\nJe me permets de vous contacter au sujet de votre offre. Mon parcours semble aligné avec plusieurs besoins du poste, et je serais ravi d’échanger brièvement avec vous.\n\nBien cordialement,',
      ),
    ];
    for (final template in defaults) {
      await _database.saveTemplate(template.toJson());
    }
    templates = _database.getTemplates().map(SavedTemplate.fromJson).toList();
    notifyListeners();
  }
}
