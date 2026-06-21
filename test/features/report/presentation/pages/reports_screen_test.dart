import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:student_app/features/reports/presentation/pages/reports_screen.dart';
import 'package:student_app/features/reports/presentation/viewmodels/reports_viewmodel.dart';
import 'package:student_app/features/reports/data/models/report_model.dart';
import 'package:student_app/features/reports/presentation/widgets/report_card.dart';
import 'package:student_app/core/provider/locale_provider.dart';
import 'package:student_app/l10n/generated/app_localizations.dart';

class MockReportsViewModel extends Mock implements ReportsViewModel {}

class MockLocaleProvider extends Mock implements LocaleProvider {}

void main() {
  late MockReportsViewModel mockViewModel;
  late MockLocaleProvider mockLocaleProvider;

  final testReport = ReportModel(
    id: 1,
    title: 'Rozbité okno na Q',
    description: 'Fouká sem',
    status: 'NEW',
    dateAdded: DateTime.now(),
    upvoteCount: 5,
    authorName: 'Illia Melnyk',
    place: 'Budova Q',
    commentCount: 0,
    isUpvoted: false,
  );

  setUp(() {
    mockViewModel = MockReportsViewModel();
    mockLocaleProvider = MockLocaleProvider();

    when(() => mockLocaleProvider.locale).thenReturn(const Locale('cs'));
    when(() => mockViewModel.loadReports()).thenAnswer((_) async {});
    when(() => mockViewModel.isLoading).thenReturn(false);

    when(() => mockViewModel.reports).thenReturn([testReport]);

    when(() => mockViewModel.myReports).thenReturn([testReport]);

    when(() => mockViewModel.isLoadingComments).thenReturn(false);
  });

  Widget createWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ReportsViewModel>.value(value: mockViewModel),
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
        home: ReportsScreen(),
      ),
    );
  }

  testWidgets('ReportsScreen - Vykreslí seznam závad', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    expect(find.text('Rozbité okno na Q'), findsOneWidget);
    expect(find.byType(ReportCard), findsOneWidget);
  });
}
