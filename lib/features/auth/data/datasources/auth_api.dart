import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:student_app/core/utils/api_constants.dart';
import '../models/auth_token_model.dart';

class AuthApi {
  Future<AuthTokenModel> login(String username, String password) async {
    final response = await http.post(
      Uri.parse(ApiConstants.loginEndpoint),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'password',
        'username': username,
        'password': password,
        'client_id': 'manager',
      },
    );

    if (response.statusCode == 200) {
      print('KEYCLOAK ODPOVĚĎ: ${response.body}');

      final data = json.decode(response.body);
      return AuthTokenModel.fromJson(data);
    } else {
      throw Exception('Chyba API: ${response.statusCode} - ${response.body}');
    }
  }

  Future<AuthTokenModel?> refreshCitymindToken(String refreshToken) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.loginEndpoint),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'refresh_token',
          'client_id': 'manager',
          'refresh_token': refreshToken,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AuthTokenModel.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
