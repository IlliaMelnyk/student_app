class ReportModel {
  final int id;
  final String title;
  final String description;
  final String status;
  final DateTime dateAdded;
  final int upvoteCount;
  final String authorName;
  final String place;
  final int commentCount;
  final String? imageUrl;
  final bool isUpvoted;

  ReportModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.dateAdded,
    required this.upvoteCount,
    required this.authorName,
    required this.place,
    required this.commentCount,
    this.imageUrl,
    this.isUpvoted = false,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['post_id'] ?? json['id'] ?? 0,
      title: json['title'] ?? 'Bez názvu',
      description: json['description'] ?? '',
      status: json['status'] ?? 'NEW',
      dateAdded:
          DateTime.tryParse(json['dateAdded'] ?? json['date_added'] ?? '') ??
          DateTime.now(),
      upvoteCount: json['upvoteCount'] ?? json['upvotes'] ?? 0,
      authorName:
          json['authorName'] ?? json['author_name'] ?? 'Anonymní uživatel',
      place: json['place'] ?? json['location'] ?? 'Neznámá lokace',
      commentCount: json['commentCount'] ?? json['comment_count'] ?? 0,
      imageUrl: json['imageUrl'] ?? json['image_url'],
    );
  }

  ReportModel copyWith({int? upvoteCount, int? commentCount, bool? isUpvoted}) {
    return ReportModel(
      id: id,
      title: title,
      description: description,
      status: status,
      dateAdded: dateAdded,
      upvoteCount: upvoteCount ?? this.upvoteCount,
      authorName: authorName,
      place: place,
      commentCount: commentCount ?? this.commentCount,
      imageUrl: imageUrl,
      isUpvoted: isUpvoted ?? this.isUpvoted,
    );
  }
}
