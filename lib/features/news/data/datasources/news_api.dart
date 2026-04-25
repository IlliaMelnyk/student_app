import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/utils/api_constants.dart';
import '../models/news_model.dart';

class NewsApi {
  Future<List<NewsModel>> fetchMobileNews(
    String langCode, {
    List<int>? categoryIds,
    int page = 0,
    int itemsPerPage = 30,
    String? search,
  }) async {
    final Map<String, String> queryParameters = {
      'page': page.toString(),
      'itemsPerPage': itemsPerPage.toString(),
    };

    if (search != null && search.isNotEmpty) {
      queryParameters['search'] = search;
    }

    if (categoryIds != null && categoryIds.isNotEmpty) {
      queryParameters['categoryIds'] = categoryIds.join(',');
    }

    final Uri url = Uri.parse(
      ApiConstants.newsBaseUrl,
    ).replace(queryParameters: queryParameters);

    try {
      final response = await http.get(
        url,
        headers: {'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> items = data['items'] ?? [];
        return items.map((item) => NewsModel.fromJson(item, langCode)).toList();
      } else {
        print('News API Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('News API Exception: $e');
      return [];
    }
  }
}
