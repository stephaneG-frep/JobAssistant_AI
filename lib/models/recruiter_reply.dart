class RecruiterReply {
  RecruiterReply({required this.id, required this.kind, required this.context, required this.result, DateTime? createdAt}) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String kind;
  final String context;
  final String result;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {'id': id, 'kind': kind, 'context': context, 'result': result, 'createdAt': createdAt.toIso8601String()};

  factory RecruiterReply.fromJson(Map<String, dynamic> json) => RecruiterReply(
        id: json['id'] as String? ?? '',
        kind: json['kind'] as String? ?? '',
        context: json['context'] as String? ?? '',
        result: json['result'] as String? ?? '',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      );
}
