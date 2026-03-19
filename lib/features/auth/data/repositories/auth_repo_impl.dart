import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_api.dart';
import '../models/auth_token_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApi api;

  AuthRepositoryImpl({required this.api});

  @override
  Future<AuthTokenModel> login(String username, String password) async {
    return await api.login(username, password);
  }
}
