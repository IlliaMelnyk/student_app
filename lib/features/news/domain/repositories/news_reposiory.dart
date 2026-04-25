import '../../data/models/news_model.dart';

abstract class NewsRepository {
  Future<List<NewsModel>> getNews({
    List<int>? categoryIds,
    List<int>? audienceIds,
    String? search,
    required String langCode,
  });
}
