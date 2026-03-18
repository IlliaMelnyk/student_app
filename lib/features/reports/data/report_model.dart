class ReportModel {
  final int id;
  final String title;
  final String description;
  final String status;
  final DateTime dateAdded;
  final int upvotes;

  ReportModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.dateAdded,
    required this.upvotes,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Bez názvu',
      description: json['description'] ?? '',
      status: json['status'] ?? 'NEW',
      dateAdded: DateTime.tryParse(json['date_added'] ?? '') ?? DateTime.now(),
      upvotes: json['upvotes'] ?? 0,
    );
  }
}
