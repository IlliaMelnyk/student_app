import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth_token_model.dart';

class AuthApi {
  final String _authUrl =
      'https://auth.citymind.tech/realms/citymind/protocol/openid-connect/token/';

  Future<AuthTokenModel> login(String username, String password) async {
    final response = await http.post(
      Uri.parse(_authUrl),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'password',
        'username': username,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return AuthTokenModel.fromJson(data);
    } else {
      throw Exception('Chyba API: ${response.statusCode} - ${response.body}');
    }
  }
}
