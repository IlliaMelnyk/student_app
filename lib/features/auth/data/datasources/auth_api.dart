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
      final data = json.decode(response.body);
      return AuthTokenModel.fromJson(data);
    } else {
      throw Exception('Chyba API: ${response.statusCode} - ${response.body}');
    }
  }
}
