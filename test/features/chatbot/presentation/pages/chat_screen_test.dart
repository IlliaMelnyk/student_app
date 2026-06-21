import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:student_app/features/chatbot/presentation/pages/chat_screen.dart'; // Uprav cestu
import 'package:student_app/features/chatbot/presentation/viewmodels/chatbot_viewmodel.dart'; // Uprav cestu
import 'package:student_app/features/chatbot/data/models/chat_message_model.dart'; // Uprav cestu
import 'package:student_app/features/auth/presentation/viewmodels/login_viewmodel.dart'; // Uprav cestu
import 'package:student_app/core/provider/locale_provider.dart';
import 'package:student_app/l10n/generated/app_localizations.dart';

class MockChatbotViewModel extends Mock implements ChatbotViewModel {}

class MockAuthViewModel extends Mock implements AuthViewModel {}

class MockLocaleProvider extends Mock implements LocaleProvider {}

void main() {
  late MockChatbotViewModel mockViewModel;
  late MockAuthViewModel mockAuthViewModel;
  late MockLocaleProvider mockLocaleProvider;

  // GOD-MODE ošetření fontů a registrace generických typů pro mocktail
  setUpAll(() {
    registerFallbackValue(
      <String>[],
    ); // Nutné pro volání setInitialGreeting(..., List<String>)
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exceptionAsString().contains('RenderFlex overflowed')) {
        return; // Ignoruj odchylky v šířce Linux fontů
      }
      originalOnError?.call(details);
    };
  });

  setUp(() {
    mockViewModel = MockChatbotViewModel();
    mockAuthViewModel = MockAuthViewModel();
    mockLocaleProvider = MockLocaleProvider();

    when(() => mockLocaleProvider.locale).thenReturn(const Locale('cs'));

    // Ošetření asynchronních a prázdných volání v didChangeDependencies() a UI
    when(
      () => mockViewModel.setInitialGreeting(any(), any()),
    ).thenAnswer((_) {});
    when(
      () => mockViewModel.sendMessage(any(), any()),
    ).thenAnswer((_) async {});
    when(() => mockViewModel.isLoading).thenReturn(false);
    when(() => mockViewModel.messages).thenReturn([]);
  });

  Widget createWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ChatbotViewModel>.value(value: mockViewModel),
        ChangeNotifierProvider<AuthViewModel>.value(value: mockAuthViewModel),
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
        home: ChatScreen(),
      ),
    );
  }

  group('ChatScreen - Widget Testy', () {
    testWidgets(
      'SCÉNÁŘ 1: Zobrazí uzamčenou obrazovku s ikonou zámku, pokud uživatel NENÍ přihlášen',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        // ARRANGE: Nasimulujeme odhlášeného uživatele
        when(() => mockAuthViewModel.isAuthenticated).thenReturn(false);

        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();

        // ASSERT: Obrazovka nesmí zobrazit chat, ale zamykací hlášku a tlačítko Login
        expect(find.byIcon(Icons.lock_outline), findsOneWidget);
        expect(find.byType(ElevatedButton), findsOneWidget);
      },
    );

    testWidgets(
      'SCÉNÁŘ 2: Vykreslí chatovací bubliny, Markdown, zdroje a FAQ čipy, pokud JE uživatel přihlášen',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        // ARRANGE: Nasimulujeme přihlášeného uživatele
        when(() => mockAuthViewModel.isAuthenticated).thenReturn(true);

        // Podstrčíme mu bohatou konverzaci o testování na MENDELU
        when(() => mockViewModel.messages).thenReturn([
          ChatMessageModel(text: "Kde najdu studijní oddělení?", isUser: true),
          ChatMessageModel(
            text: "Studijní oddělení se nachází v **přízemí budovy PEF**.",
            isUser: false,
            sources: ["https://mendelu.cz/kontakty.pdf"],
            faqs: ["Jaké jsou úřední hodiny?"],
          ),
        ]);

        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();

        // ASSERT 1: Ověříme, že se vykreslila bublina s dotazem studenta
        expect(find.text("Kde najdu studijní oddělení?"), findsOneWidget);

        // ASSERT 2: Ověříme, že odpověď AI korektně prošla přes MarkdownBody
        expect(find.byType(MarkdownBody), findsOneWidget);

        // ASSERT 3: Ověříme, že kód správně vyparsoval název PDF souboru ze zdroje
        expect(find.text("kontakty.pdf"), findsOneWidget);

        // ASSERT 4: Ověříme, že se dole vykreslil interaktivní čip s FAQ otázkou
        expect(find.text("Jaké jsou úřední hodiny?"), findsOneWidget);

        // ASSERT 5: Ověříme přítomnost textového pole pro psaní dalšího dotazu
        expect(find.byType(TextField), findsOneWidget);
      },
    );
  });
}
