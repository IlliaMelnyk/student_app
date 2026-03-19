import 'package:flutter/material.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/utils/secure_storage_service.dart';
import '../../data/models/auth_token_model.dart';

enum AuthState { idle, loading, success, error }

class AuthViewModel extends ChangeNotifier {
  final AuthRepository repository;
  final SecureStorageService secureStorage;

  AuthViewModel({required this.repository, required this.secureStorage});

  AuthState state = AuthState.idle;
  String? errorMessage;
  bool isPasswordVisible = false;

  bool isCheckingAuth = true;
  bool isAuthenticated = false;

  Future<void> checkAuthStatus() async {
    isCheckingAuth = true;
    notifyListeners();

    final token = await secureStorage.getToken();

    if (token != null && token.isNotEmpty) {
      isAuthenticated = true;
      print("Token nájdený, preskakujem login!");
    } else {
      isAuthenticated = false;
      print("Žiadny token, ideme na login.");
    }

    isCheckingAuth = false;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    notifyListeners();
  }

  Future<bool> login({
    required String email,
    required String password,
    required String emptyFieldsText,
    required String serverErrorText,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      errorMessage = emptyFieldsText;
      state = AuthState.error;
      notifyListeners();
      return false;
    }

    state = AuthState.loading;
    errorMessage = null;
    notifyListeners();

    try {
      final AuthTokenModel tokenModel = await repository.login(email, password);
      await secureStorage.saveToken(tokenModel.accessToken);
      print("MÁME TOKEN A JE ULOŽENÝ: ${tokenModel.accessToken}");

      state = AuthState.success;
      notifyListeners();
      return true;
    } catch (e) {
      print("Chyba loginu: $e");
      errorMessage = serverErrorText;
      state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await secureStorage.deleteToken();
    isAuthenticated = false;
    notifyListeners();
  }
}
