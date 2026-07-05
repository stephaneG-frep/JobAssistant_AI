class PromptBuilderService {
  static const _ethics =
      'Tu es JobAssistant AI. Aide la personne à valoriser son vrai parcours sans inventer d’expérience, diplôme, compétence ou résultat. Réponds en français, de façon structurée et directement exploitable.';

  String offerAnalysis(String offer) => '''
$_ethics
Analyse cette offre d'emploi et fournis : résumé clair, missions principales, compétences demandées, niveau attendu, type de contrat, points importants, mots-clés ATS, questions à poser au recruteur et conseils pour postuler.

Offre :
$offer
''';

  String cvMatch(String cv, String offer) => '''
$_ethics
Compare ce CV avec cette offre. Donne un score de compatibilité sur 100, les points forts, compétences manquantes, expériences à mettre en avant, améliorations proposées, mots-clés à ajouter et une version optimisée du résumé professionnel. Ne propose jamais d'ajouter une expérience fausse.

CV :
$cv

Offre :
$offer
''';

  String coverLetter({required String position, required String company, required String offer, required String profile, required String tone}) => '''
$_ethics
Rédige une lettre de motivation pour le poste "$position" chez "$company" avec un ton $tone. Génère : lettre complète, version courte, version email et message LinkedIn.

Offre :
$offer

Profil réel du candidat :
$profile
''';

  String recruiterReply(String kind, String context) => '''
$_ethics
Génère une réponse recruteur personnalisée de type "$kind". Elle doit être professionnelle, modifiable et cohérente avec le contexte.

Contexte :
$context
''';

  String interviewCoach(String offer, String notes) => '''
$_ethics
Prépare un entretien pour cette candidature. Fournis questions fréquentes, questions adaptées à l'offre, simulation d'entretien, réponses STAR, conseils de présentation, pitch de 30 secondes, questions à poser et grille de débrief.

Offre :
$offer

Notes personnelles :
$notes
''';

  String textCorrection(String text) => '''
$_ethics
Corrige et améliore ce texte. Fournis : correction orthographe, reformulation professionnelle, version plus courte, version plus claire, version plus convaincante et ton plus naturel.

Texte :
$text
''';

  String improveWithoutInventing(String text) => '''
$_ethics
Améliore ce contenu sans ajouter aucun fait non fourni. Tu peux reformuler, clarifier, structurer, rendre plus professionnel et mettre en valeur les éléments existants, mais tu dois signaler explicitement les informations manquantes au lieu de les inventer.

Contenu :
$text
''';
}
