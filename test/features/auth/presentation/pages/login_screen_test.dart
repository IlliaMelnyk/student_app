import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:student_app/features/auth/presentation/pages/login_screen.dart';
import 'package:student_app/features/auth/presentation/viewmodels/login_viewmodel.dart';
import 'package:student_app/l10n/generated/app_localizations.dart';

class MockAuthViewModel extends Mock implements AuthViewModel {}

void main() {
  late MockAuthViewModel mockViewModel;

  setUp(() {
    mockViewModel = MockAuthViewModel();
    when(() => mockViewModel.state).thenReturn(AuthState.idle);
    when(() => mockViewModel.errorMessage).thenReturn(null);
    when(() => mockViewModel.isPasswordVisible).thenReturn(false);
  });

  Widget createTestWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthViewModel>.value(value: mockViewModel),
      ],
      child: const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('en', ''), Locale('cs', '')],
        home: LoginScreen(),
      ),
    );
  }

  group('LoginScreen - Widget Testy', () {
    testWidgets('Vykreslí všechna povinná textová pole a tlačítka', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('Zobrazí chybovou hlášku z ViewModelu přímo do UI', (
      WidgetTester tester,
    ) async {
      when(
        () => mockViewModel.errorMessage,
      ).thenReturn('Špatný email nebo heslo');
      when(() => mockViewModel.state).thenReturn(AuthState.error);

      await tester.pumpWidget(createTestWidget());

      expect(find.text('Špatný email nebo heslo'), findsOneWidget);
    });
  });
}
