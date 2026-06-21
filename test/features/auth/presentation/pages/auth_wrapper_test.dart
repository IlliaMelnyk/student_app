import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:student_app/features/auth/presentation/pages/auth_wrapper.dart';
import 'package:student_app/features/auth/presentation/pages/welcome_screen.dart';
import 'package:student_app/features/auth/presentation/viewmodels/login_viewmodel.dart';
import 'package:student_app/features/news/presentation/viewmodels/news_viewmodel.dart';
import 'package:student_app/features/reports/presentation/viewmodels/reports_viewmodel.dart';
import 'package:student_app/features/chatbot/presentation/viewmodels/chatbot_viewmodel.dart';
import 'package:student_app/core/provider/locale_provider.dart';
import 'package:student_app/main.dart';
import 'package:student_app/l10n/generated/app_localizations.dart';

class MockAuthViewModel extends Mock implements AuthViewModel {}

class MockNewsViewModel extends Mock implements NewsViewModel {}

class MockReportsViewModel extends Mock implements ReportsViewModel {}

class MockChatbotViewModel extends Mock implements ChatbotViewModel {}

class MockLocaleProvider extends Mock implements LocaleProvider {}

void main() {
  late MockAuthViewModel mockAuthViewModel;
  late MockNewsViewModel mockNewsViewModel;
  late MockReportsViewModel mockReportsViewModel;
  late MockChatbotViewModel mockChatbotViewModel;
  late MockLocaleProvider mockLocaleProvider;

  setUp(() {
    mockAuthViewModel = MockAuthViewModel();
    mockNewsViewModel = MockNewsViewModel();
    mockReportsViewModel = MockReportsViewModel();
    mockChatbotViewModel = MockChatbotViewModel();
    mockLocaleProvider = MockLocaleProvider();

    when(() => mockAuthViewModel.checkAuthStatus()).thenAnswer((_) async {});
    when(() => mockAuthViewModel.isCheckingAuth).thenReturn(false);

    when(() => mockNewsViewModel.loadNews(any())).thenAnswer((_) async {});
    when(() => mockNewsViewModel.isLoading).thenReturn(false);
    when(() => mockNewsViewModel.newsItems).thenReturn([]);

    when(() => mockReportsViewModel.loadReports()).thenAnswer((_) async {});
    when(() => mockReportsViewModel.isLoadingComments).thenReturn(false);
    when(() => mockReportsViewModel.reports).thenReturn([]);

    when(() => mockChatbotViewModel.isLoading).thenReturn(false);
    when(() => mockChatbotViewModel.messages).thenReturn([]);

    when(() => mockLocaleProvider.locale).thenReturn(const Locale('cs'));
  });

  Widget createWrapper() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthViewModel>.value(value: mockAuthViewModel),
        ChangeNotifierProvider<NewsViewModel>.value(value: mockNewsViewModel),
        ChangeNotifierProvider<ReportsViewModel>.value(
          value: mockReportsViewModel,
        ),
        ChangeNotifierProvider<ChatbotViewModel>.value(
          value: mockChatbotViewModel,
        ),
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
        home: AuthWrapper(),
      ),
    );
  }

  group('AuthWrapper - Testy směrování', () {
    testWidgets('Pokud uživatel NENÍ přihlášen, zobrazí se WelcomeScreen', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      when(() => mockAuthViewModel.isAuthenticated).thenReturn(false);

      await tester.pumpWidget(createWrapper());
      await tester.pumpAndSettle();

      expect(find.byType(WelcomeScreen), findsOneWidget);
    });

    testWidgets('Pokud uživatel JE přihlášen, pustí ho to dál na MainScreen', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      when(() => mockAuthViewModel.isAuthenticated).thenReturn(true);

      await tester.pumpWidget(createWrapper());
      await tester.pumpAndSettle();

      expect(find.byType(MainScreen), findsOneWidget);
    });
  });
}
