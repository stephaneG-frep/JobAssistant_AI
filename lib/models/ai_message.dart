class AiMessage {
  AiMessage({required this.role, required this.content, DateTime? createdAt}) : createdAt = createdAt ?? DateTime.now();

  final String role;
  final String content;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {'role': role, 'content': content, 'createdAt': createdAt.toIso8601String()};

  factory AiMessage.fromJson(Map<String, dynamic> json) => AiMessage(
        role: json['role'] as String? ?? 'assistant',
        content: json['content'] as String? ?? '',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      );
}
