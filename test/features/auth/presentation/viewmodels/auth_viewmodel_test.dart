import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:student_app/features/auth/data/models/auth_token_model.dart';
import 'package:student_app/features/auth/presentation/viewmodels/login_viewmodel.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late AuthViewModel viewModel;
  late MockAuthRepository mockRepo;
  late MockSecureStorageService mockSecureStorage;

  setUp(() {
    mockRepo = MockAuthRepository();
    mockSecureStorage = MockSecureStorageService();
    viewModel = AuthViewModel(
      repository: mockRepo,
      secureStorage: mockSecureStorage,
    );
  });

  test('login() - správně nastaví stavy a dekóduje JWT token', () async {
    const fakeJwt = 'header.eyJuYW1lIjogIklsbGlhIE1lbG55ayJ9.signature';
    when(() => mockRepo.login('a@b.cz', 'heslo')).thenAnswer(
      (_) async => AuthTokenModel(accessToken: fakeJwt, refreshToken: 'r'),
    );
    when(
      () => mockSecureStorage.saveTokens(
        access: any(named: 'access'),
        refresh: any(named: 'refresh'),
      ),
    ).thenAnswer((_) async {});
    when(() => mockSecureStorage.saveUserEmail(any())).thenAnswer((_) async {});
    when(() => mockSecureStorage.write(any(), any())).thenAnswer((_) async {});

    final future = viewModel.login(
      email: 'a@b.cz',
      password: 'heslo',
      emptyFieldsText: 'E',
      serverErrorText: 'E',
    );
    expect(viewModel.state, AuthState.loading);

    await future;

    expect(viewModel.state, AuthState.success);
    expect(viewModel.isAuthenticated, true);
    verify(
      () => mockSecureStorage.write('user_name', 'Illia Melnyk'),
    ).called(1);
  });
}
