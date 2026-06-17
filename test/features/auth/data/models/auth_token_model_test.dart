import 'package:flutter_test/flutter_test.dart';
import 'package:student_app/features/auth/data/models/auth_token_model.dart';

void main() {
  group('AuthTokenModel - Unit Testy', () {
    test('fromJson() - úspěšně vytvoří model s oběma tokeny', () {
      // 1. ARRANGE:
      final Map<String, dynamic> jsonMap = {
        "access_token": "superSecretAccess123",
        "refresh_token": "superSecretRefresh456",
      };

      // 2. ACT
      final model = AuthTokenModel.fromJson(jsonMap);

      // 3. ASSERT
      expect(model.accessToken, "superSecretAccess123");
      expect(model.refreshToken, "superSecretRefresh456");
    });

    test(
      'fromJson() - nespadne při chybějících klíčích a dosadí prázdný string',
      () {
        // 1. ARRANGE:
        final Map<String, dynamic> emptyJson = {};

        // 2. ACT
        final model = AuthTokenModel.fromJson(emptyJson);

        // 3. ASSERT:
        expect(model.accessToken, "");
        expect(model.refreshToken, "");
      },
    );
  });
}
