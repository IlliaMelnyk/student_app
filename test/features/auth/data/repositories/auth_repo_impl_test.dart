import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:student_app/features/auth/data/datasources/auth_api.dart';
import 'package:student_app/features/auth/data/repositories/auth_repo_impl.dart';
import 'package:student_app/features/auth/data/models/auth_token_model.dart';

class MockAuthApi extends Mock implements AuthApi {}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthApi mockApi;

  setUp(() {
    mockApi = MockAuthApi();
    repository = AuthRepositoryImpl(api: mockApi);
  });

  group('AuthRepositoryImpl - Unit Testy', () {
    test(
      'login() - úspěšně zavolá API a přepošle hotový AuthTokenModel',
      () async {
        // 1. ARRANGE:
        final fakeToken = AuthTokenModel(
          accessToken: "token123",
          refreshToken: "refresh456",
        );

        when(
          () => mockApi.login(any(), any()),
        ).thenAnswer((_) async => fakeToken);

        // 2. ACT:
        final result = await repository.login('illia@mendelu.cz', 'heslo123');

        // 3. ASSERT:
        expect(result, isA<AuthTokenModel>());
        expect(result.accessToken, 'token123');
        expect(result.refreshToken, 'refresh456');

        // ASSERT:
        verify(() => mockApi.login('illia@mendelu.cz', 'heslo123')).called(1);
      },
    );
  });
}
