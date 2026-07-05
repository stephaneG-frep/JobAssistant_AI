class SavedTemplate {
  SavedTemplate({required this.id, required this.title, required this.category, required this.content, this.favorite = false, DateTime? updatedAt})
      : updatedAt = updatedAt ?? DateTime.now();

  final String id;
  final String title;
  final String category;
  final String content;
  final bool favorite;
  final DateTime updatedAt;

  SavedTemplate copyWith({String? title, String? category, String? content, bool? favorite}) => SavedTemplate(
        id: id,
        title: title ?? this.title,
        category: category ?? this.category,
        content: content ?? this.content,
        favorite: favorite ?? this.favorite,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'content': content,
        'favorite': favorite,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory SavedTemplate.fromJson(Map<String, dynamic> json) => SavedTemplate(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        category: json['category'] as String? ?? '',
        content: json['content'] as String? ?? '',
        favorite: json['favorite'] as bool? ?? false,
        updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
      );
}
