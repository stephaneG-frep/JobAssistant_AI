class CoverLetter {
  CoverLetter({required this.id, required this.position, required this.company, required this.tone, required this.result, DateTime? createdAt})
      : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String position;
  final String company;
  final String tone;
  final String result;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'position': position,
        'company': company,
        'tone': tone,
        'result': result,
        'createdAt': createdAt.toIso8601String(),
      };

  factory CoverLetter.fromJson(Map<String, dynamic> json) => CoverLetter(
        id: json['id'] as String? ?? '',
        position: json['position'] as String? ?? '',
        company: json['company'] as String? ?? '',
        tone: json['tone'] as String? ?? 'professionnel',
        result: json['result'] as String? ?? '',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      );
}
