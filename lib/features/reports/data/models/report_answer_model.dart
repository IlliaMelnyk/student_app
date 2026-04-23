class ReportAnswerModel {
  final String content;
  final DateTime createdAt;
  final String authorName;

  ReportAnswerModel({
    required this.content,
    required this.createdAt,
    required this.authorName,
  });

  factory ReportAnswerModel.fromJson(Map<String, dynamic> json) {
    return ReportAnswerModel(
      content: json['content'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      authorName: json['authorName'] ?? 'Neznámý uživatel',
    );
  }
}
