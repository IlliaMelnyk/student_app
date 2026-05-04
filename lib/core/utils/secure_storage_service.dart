import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  final String _tokenKey = 'auth_token';
  final String _refreshTokenKey = 'refresh_token';
  final String _emailKey = 'user_email';
  final String _nameKey = 'user_name';

  Future<void> saveUserName(String name) async {
    await _storage.write(key: _nameKey, value: name);
  }

  Future<String?> getUserName() async {
    return await _storage.read(key: _nameKey);
  }

  Future<void> clearUserData() async {
    await deleteTokens();
    await _storage.delete(key: _emailKey);
    await _storage.delete(key: _nameKey);
  }

  Future<void> saveTokens({
    required String access,
    required String refresh,
  }) async {
    await _storage.write(key: _tokenKey, value: access);
    await _storage.write(key: _refreshTokenKey, value: refresh);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<void> deleteTokens() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  Future<void> saveUserEmail(String email) async {
    await _storage.write(key: _emailKey, value: email);
  }

  Future<String?> getUserEmail() async {
    return await _storage.read(key: _emailKey);
  }

  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }
}
