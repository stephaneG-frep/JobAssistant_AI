class CvReview {
  CvReview({required this.id, required this.cvText, required this.offerText, required this.result, required this.score, DateTime? createdAt})
      : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String cvText;
  final String offerText;
  final String result;
  final int score;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'cvText': cvText,
        'offerText': offerText,
        'result': result,
        'score': score,
        'createdAt': createdAt.toIso8601String(),
      };

  factory CvReview.fromJson(Map<String, dynamic> json) => CvReview(
        id: json['id'] as String? ?? '',
        cvText: json['cvText'] as String? ?? '',
        offerText: json['offerText'] as String? ?? '',
        result: json['result'] as String? ?? '',
        score: json['score'] as int? ?? 0,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      );
}
