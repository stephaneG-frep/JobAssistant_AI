enum ApplicationStatus {
  toApply('à postuler'),
  sent('envoyée'),
  followUp('relance'),
  interview('entretien'),
  rejected('refus'),
  accepted('acceptée');

  const ApplicationStatus(this.label);
  final String label;

  static ApplicationStatus fromName(String value) => ApplicationStatus.values.firstWhere(
        (status) => status.name == value,
        orElse: () => ApplicationStatus.toApply,
      );
}

class ApplicationProject {
  ApplicationProject({
    required this.id,
    required this.company,
    required this.position,
    this.status = ApplicationStatus.toApply,
    this.offerText = '',
    this.cvText = '',
    this.coverLetter = '',
    this.notes = '',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  final String id;
  final String company;
  final String position;
  final ApplicationStatus status;
  final String offerText;
  final String cvText;
  final String coverLetter;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  ApplicationProject copyWith({
    String? company,
    String? position,
    ApplicationStatus? status,
    String? offerText,
    String? cvText,
    String? coverLetter,
    String? notes,
  }) =>
      ApplicationProject(
        id: id,
        company: company ?? this.company,
        position: position ?? this.position,
        status: status ?? this.status,
        offerText: offerText ?? this.offerText,
        cvText: cvText ?? this.cvText,
        coverLetter: coverLetter ?? this.coverLetter,
        notes: notes ?? this.notes,
        createdAt: createdAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'company': company,
        'position': position,
        'status': status.name,
        'offerText': offerText,
        'cvText': cvText,
        'coverLetter': coverLetter,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory ApplicationProject.fromJson(Map<String, dynamic> json) => ApplicationProject(
        id: json['id'] as String? ?? '',
        company: json['company'] as String? ?? '',
        position: json['position'] as String? ?? '',
        status: ApplicationStatus.fromName(json['status'] as String? ?? ''),
        offerText: json['offerText'] as String? ?? '',
        cvText: json['cvText'] as String? ?? '',
        coverLetter: json['coverLetter'] as String? ?? '',
        notes: json['notes'] as String? ?? '',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
        updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
      );
}
