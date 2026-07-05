class InterviewSession {
  InterviewSession({required this.id, required this.offerText, required this.result, DateTime? createdAt}) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String offerText;
  final String result;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {'id': id, 'offerText': offerText, 'result': result, 'createdAt': createdAt.toIso8601String()};

  factory InterviewSession.fromJson(Map<String, dynamic> json) => InterviewSession(
        id: json['id'] as String? ?? '',
        offerText: json['offerText'] as String? ?? '',
        result: json['result'] as String? ?? '',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      );
}
