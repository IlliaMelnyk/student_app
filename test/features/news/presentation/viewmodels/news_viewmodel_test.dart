import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:student_app/features/news/presentation/viewmodels/news_viewmodel.dart';
import 'package:student_app/features/news/data/models/news_model.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late NewsViewModel viewModel;
  late MockNewsRepository mockRepo;
  late MockSharedPrefsService mockPrefs;

  setUp(() {
    mockRepo = MockNewsRepository();
    mockPrefs = MockSharedPrefsService();
    viewModel = NewsViewModel(repository: mockRepo, prefs: mockPrefs);
  });

  group('NewsViewModel - Filtrování zpráv', () {
    final testNewsList = [
      NewsModel(
        id: 1,
        title: 'Zpráva s obrázkem',
        text: 'T',
        unformattedText: 'U',
        imageUrl: 'url',
        categoryName: 'Aktuality',
        facultyName: 'PEF',
        startDate: DateTime.now(),
        facultyIds: [1],
        audienceIds: [1],
      ),
      NewsModel(
        id: 2,
        title: 'Bez obrázku',
        text: 'T',
        unformattedText: 'U',
        imageUrl: null,
        categoryName: 'Aktuality',
        facultyName: 'PEF',
        startDate: DateTime.now(),
        facultyIds: [1],
        audienceIds: [1],
      ),
      NewsModel(
        id: 3,
        title: 'Zpráva LDF',
        text: 'T',
        unformattedText: 'U',
        imageUrl: 'url',
        categoryName: 'Aktuality',
        facultyName: 'LDF',
        startDate: DateTime.now(),
        facultyIds: [2],
        audienceIds: [1],
      ),
    ];

    test(
      'loadNews() - odfiltruje zprávy bez obrázku a aplikuje filtry fakult',
      () async {
        when(
          () => mockPrefs.getSelectedFaculties(),
        ).thenAnswer((_) async => [1]);
        when(() => mockPrefs.getSelectedGroups()).thenAnswer((_) async => [1]);
        when(
          () => mockRepo.getNews(
            langCode: 'cs',
            categoryIds: any(named: 'categoryIds'),
          ),
        ).thenAnswer((_) async => testNewsList);

        await viewModel.loadNews('cs');

        expect(viewModel.newsItems.length, 1);
        expect(viewModel.newsItems.first.id, 1);
      },
    );
  });
}
