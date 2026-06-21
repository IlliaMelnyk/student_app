import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:student_app/features/news/presentation/pages/news_detail_screen.dart';
import 'package:student_app/features/news/data/models/news_model.dart';
import 'package:student_app/core/provider/locale_provider.dart';
import 'package:student_app/l10n/generated/app_localizations.dart';

class MockLocaleProvider extends Mock implements LocaleProvider {}

void main() {
  late MockLocaleProvider mockLocaleProvider;

  setUp(() {
    mockLocaleProvider = MockLocaleProvider();
    when(() => mockLocaleProvider.locale).thenReturn(const Locale('cs'));
  });

  final testNews = NewsModel(
    id: 99,
    title: 'Státnice se blíží',
    text: 'Detailní text o zkouškách',
    unformattedText: 'Detailní text o zkouškách',
    categoryName: 'Zkoušky',
    facultyName: 'PEF',
    startDate: DateTime.now(),
    facultyIds: [],
    audienceIds: [],
  );

  Widget createWidget() {
    return ChangeNotifierProvider<LocaleProvider>.value(
      value: mockLocaleProvider,
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('cs', '')],
        home: NewsDetailScreen(news: testNews),
      ),
    );
  }

  testWidgets(
    'NewsDetailScreen - Správně napojí a zobrazí data předaného objektu',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Státnice se blíží'), findsOneWidget);
      expect(find.text('Detailní text o zkouškách'), findsOneWidget);
    },
  );
}
