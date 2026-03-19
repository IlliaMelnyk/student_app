import 'package:student_app/features/auth/data/models/auth_token_model.dart';

abstract class AuthRepository {
  Future<AuthTokenModel> login(String email, String password);
}
