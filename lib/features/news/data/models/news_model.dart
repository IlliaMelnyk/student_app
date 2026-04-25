class NewsModel {
  final int id;
  final String title;
  final String text;
  final String unformattedText;
  final String? imageUrl;
  final String categoryName;
  final String facultyName;
  final DateTime startDate;
  final String? customPlace;

  final List<int> facultyIds;
  final List<int> audienceIds;

  NewsModel({
    required this.id,
    required this.title,
    required this.text,
    required this.unformattedText,
    this.imageUrl,
    required this.categoryName,
    required this.facultyName,
    required this.startDate,
    this.customPlace,
    required this.facultyIds,
    required this.audienceIds,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json, String langCode) {
    final localized =
        json['localizedAttributes']?[langCode] ??
        json['localizedAttributes']?['cz'];

    final categoryList = json['category'] as List?;
    final categoryLocalized = (categoryList != null && categoryList.isNotEmpty)
        ? (categoryList[0]['localizedAttributes']?[langCode] ??
              categoryList[0]['localizedAttributes']?['cz'])
        : null;

    final facultyList = json['faculty'] as List?;
    final facultyLocalized = (facultyList != null && facultyList.isNotEmpty)
        ? (facultyList[0]['localizedAttributes']?[langCode] ??
              facultyList[0]['localizedAttributes']?['cz'])
        : null;

    return NewsModel(
      id: json['id'] ?? 0,
      title: localized?['title'] ?? 'No Title',
      text: localized?['text'] ?? '',
      unformattedText: localized?['unformattedText'] ?? '',
      customPlace: localized?['customPlace'],
      imageUrl: json['titleImageUrl'],
      categoryName: categoryLocalized?['name'] ?? 'News',
      facultyName: facultyLocalized?['name'] ?? 'MENDELU',
      startDate: DateTime.tryParse(json['startDate'] ?? '') ?? DateTime.now(),
      facultyIds: facultyList?.map((f) => f['id'] as int).toList() ?? [],
      audienceIds:
          (json['audience'] as List?)?.map((a) => a['id'] as int).toList() ??
          [],
    );
  }
}
