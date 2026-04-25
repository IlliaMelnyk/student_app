import 'package:flutter/material.dart';
import 'package:student_app/features/news/domain/repositories/news_reposiory.dart';
import '../../../../core/utils/shared_prefs_service.dart';
import '../../data/models/news_model.dart';

class NewsViewModel extends ChangeNotifier {
  final NewsRepository repository;
  final SharedPrefsService _prefs = SharedPrefsService();

  NewsViewModel({required this.repository});

  List<NewsModel> _allFilteredNews = [];
  List<NewsModel> _displayNews = [];
  bool _isLoading = false;
  int? _selectedCategoryId;

  List<NewsModel> get newsItems => _displayNews;
  bool get isLoading => _isLoading;
  int? get selectedCategoryId => _selectedCategoryId;

  Future<void> loadNews(String langCode, {int? categoryId}) async {
    _isLoading = true;
    _selectedCategoryId = categoryId;
    notifyListeners();

    try {
      final selectedFaculties = await _prefs.getSelectedFaculties();
      final selectedGroups = await _prefs.getSelectedGroups();

      final allNews = await repository.getNews(
        langCode: langCode,
        categoryIds: categoryId != null ? [categoryId] : null,
      );

      _allFilteredNews = allNews.where((news) {
        if (news.imageUrl == null || news.imageUrl!.isEmpty) {
          return false;
        }
        bool matchesFaculty =
            selectedFaculties.isEmpty ||
            news.facultyIds.any((id) => selectedFaculties.contains(id));
        bool matchesAudience =
            selectedGroups.isEmpty ||
            news.audienceIds.any((id) => selectedGroups.contains(id));

        return matchesFaculty && matchesAudience;
      }).toList();

      _displayNews = _allFilteredNews;
    } catch (e) {
      print("Chyba loadNews: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void filterNews(String query) {
    if (query.isEmpty) {
      _displayNews = _allFilteredNews;
    } else {
      final lowerQuery = query.toLowerCase();
      _displayNews = _allFilteredNews.where((news) {
        final titleMatch = news.title.toLowerCase().contains(lowerQuery);
        final contentMatch =
            news.text?.toLowerCase().contains(lowerQuery) ?? false;
        return titleMatch || contentMatch;
      }).toList();
    }
    notifyListeners();
  }

  Future<void> refreshAfterSettings(String langCode) async {
    await loadNews(langCode, categoryId: _selectedCategoryId);
  }
}
