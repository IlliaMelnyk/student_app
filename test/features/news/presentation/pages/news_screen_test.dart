import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:student_app/features/news/presentation/pages/news_screen.dart'; // Uprav cestu
import 'package:student_app/features/news/presentation/viewmodels/news_viewmodel.dart'; // Uprav cestu
import 'package:student_app/features/news/data/models/news_model.dart'; // Uprav cestu
import 'package:student_app/core/provider/locale_provider.dart'; // Uprav cestu
import 'package:student_app/features/news/presentation/widgets/news_card.dart';
import 'package:student_app/l10n/generated/app_localizations.dart';

class MockNewsViewModel extends Mock implements NewsViewModel {}

class MockLocaleProvider extends Mock implements LocaleProvider {}

void main() {
  late MockNewsViewModel mockViewModel;
  late MockLocaleProvider mockLocaleProvider;

  setUp(() {
    mockViewModel = MockNewsViewModel();
    mockLocaleProvider = MockLocaleProvider();

    when(() => mockLocaleProvider.locale).thenReturn(const Locale('cs'));

    when(() => mockViewModel.loadNews(any())).thenAnswer((_) async {});

    when(() => mockViewModel.isLoading).thenReturn(false);
    when(() => mockViewModel.newsItems).thenReturn([
      NewsModel(
        id: 1,
        title: 'Zpráva z PEF',
        text: 'Obsah',
        unformattedText: 'Obsah',
        categoryName: 'Aktuality',
        facultyName: 'PEF',
        startDate: DateTime.now(),
        facultyIds: [],
        audienceIds: [],
      ),
    ]);
  });

  Widget createWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<NewsViewModel>.value(value: mockViewModel),
        ChangeNotifierProvider<LocaleProvider>.value(value: mockLocaleProvider),
      ],
      child: const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('cs', ''), Locale('en', '')],
        home: NewsScreen(),
      ),
    );
  }

  testWidgets('NewsScreen - Vykreslí seznam novinek', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    expect(find.text('Zpráva z PEF'), findsOneWidget);

    expect(find.byType(NewsCard), findsOneWidget);
  });
}
