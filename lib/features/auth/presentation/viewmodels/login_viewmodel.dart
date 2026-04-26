import 'dart:convert';
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
      print("Citymind token nalezen, uživatel je přihlášen!");
    } else {
      isAuthenticated = false;
      print("Žádný token, uživatel je odhlášen.");
    }

    isCheckingAuth = false;
    notifyListeners();
  }

  String? _getNameFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = parts[1];
      final String decoded = utf8.decode(
        base64Url.decode(base64Url.normalize(payload)),
      );
      final Map<String, dynamic> claims = json.decode(decoded);
      return claims['name'];
    } catch (e) {
      print("Chyba dekódování jména: $e");
      return null;
    }
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

      final realName = _getNameFromToken(tokenModel.accessToken) ?? "Student";

      await secureStorage.saveTokens(
        access: tokenModel.accessToken,
        refresh: tokenModel.refreshToken,
      );
      await secureStorage.saveUserEmail(email);
      await secureStorage.write('user_name', realName);

      isAuthenticated = true;
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
