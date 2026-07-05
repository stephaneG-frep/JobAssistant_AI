class UserProfile {
  UserProfile({
    this.fullName = '',
    this.professionalSummary = '',
    this.skills = '',
    this.experiences = '',
    this.preferences = '',
    this.constraints = '',
    this.defaultCv = '',
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  final String fullName;
  final String professionalSummary;
  final String skills;
  final String experiences;
  final String preferences;
  final String constraints;
  final String defaultCv;
  final DateTime updatedAt;

  UserProfile copyWith({
    String? fullName,
    String? professionalSummary,
    String? skills,
    String? experiences,
    String? preferences,
    String? constraints,
    String? defaultCv,
  }) =>
      UserProfile(
        fullName: fullName ?? this.fullName,
        professionalSummary: professionalSummary ?? this.professionalSummary,
        skills: skills ?? this.skills,
        experiences: experiences ?? this.experiences,
        preferences: preferences ?? this.preferences,
        constraints: constraints ?? this.constraints,
        defaultCv: defaultCv ?? this.defaultCv,
      );

  String get contextBlock => '''
Profil local de l'utilisateur :
Nom : $fullName
Résumé : $professionalSummary
Compétences : $skills
Expériences : $experiences
Préférences : $preferences
Contraintes : $constraints
CV par défaut : $defaultCv
''';

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'professionalSummary': professionalSummary,
        'skills': skills,
        'experiences': experiences,
        'preferences': preferences,
        'constraints': constraints,
        'defaultCv': defaultCv,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        fullName: json['fullName'] as String? ?? '',
        professionalSummary: json['professionalSummary'] as String? ?? '',
        skills: json['skills'] as String? ?? '',
        experiences: json['experiences'] as String? ?? '',
        preferences: json['preferences'] as String? ?? '',
        constraints: json['constraints'] as String? ?? '',
        defaultCv: json['defaultCv'] as String? ?? '',
        updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
      );
}
