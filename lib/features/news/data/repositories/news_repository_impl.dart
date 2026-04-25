import 'package:student_app/features/news/data/datasources/news_api.dart';

import '../../domain/repositories/news_reposiory.dart';
import '../models/news_model.dart';

class NewsRepositoryImpl implements NewsRepository {
  final NewsApi api;
  NewsRepositoryImpl({required this.api});

  @override
  Future<List<NewsModel>> getNews({
    List<int>? categoryIds,
    List<int>? audienceIds,
    String? search,
    required String langCode,
  }) async {
    return await api.fetchMobileNews(
      langCode,
      categoryIds: categoryIds,
      search: search,
    );
  }
}
