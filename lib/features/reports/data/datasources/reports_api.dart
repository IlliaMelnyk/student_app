import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:student_app/features/auth/data/datasources/auth_api.dart';
import '../../../../core/utils/secure_storage_service.dart';
import '../../../../core/utils/api_constants.dart';
import '../models/report_model.dart';
import '../models/report_answer_model.dart';
import 'package:crypto/crypto.dart';

class ReportsApi {
  final SecureStorageService _storage = SecureStorageService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<ReportModel>> fetchReports() async {
    final url = Uri.parse('${ApiConstants.communityBoardBaseUrl}/posts');
    final headers = await _getHeaders();
    try {
      final response = await http.get(url, headers: headers);

      print("STATUS CODE: ${response.statusCode}");
      print("RAW JSON: ${utf8.decode(response.bodyBytes)}");

      if (response.statusCode == 401 || response.statusCode == 403) {
        print("TOKEN EXPIROVAL NEBO JE NEPLATNÝ");
        return [];
      }

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(
          utf8.decode(response.bodyBytes),
        );
        return jsonData.map((item) => ReportModel.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print("CHYBA SÍTĚ: $e");
      return [];
    }
  }

  Future<bool> sendReport(
    String title,
    String description,
    String place,
  ) async {
    final url = Uri.parse(
      '${ApiConstants.communityBoardBaseUrl}/api/submit-post',
    );

    final String authorEmail =
        await _storage.getUserEmail() ?? "neznamy@email.cz";
    final String authorName =
        await _storage.read('user_name') ?? "Student MENDELU";

    final bodyData = {
      "title": title,
      "description": description,
      "postType": "POST",
      "place": place,
      "authorName": authorName,
      "authorEmail": authorEmail,
      "entityId": 1910,
    };

    var headers = await _getHeaders();
    var response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(bodyData),
    );

    if (response.statusCode == 401) {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken != null) {
        final newTokens = await AuthApi().refreshCitymindToken(refreshToken);

        if (newTokens != null) {
          await _storage.saveTokens(
            access: newTokens.accessToken,
            refresh: newTokens.refreshToken,
          );

          headers = await _getHeaders();
          response = await http.post(
            url,
            headers: headers,
            body: jsonEncode(bodyData),
          );
        }
      }
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      print('CHYBA ODESLÁNÍ: ${response.statusCode} - ${response.body}');
      return false;
    }
  }

  Future<List<ReportAnswerModel>> fetchAnswers(int reportId) async {
    final headers = await _getHeaders();
    // ZMĚNA: GET /reports/{id}/answers -> /posts/{id}/answers
    final url = Uri.parse(
      '${ApiConstants.communityBoardBaseUrl}/posts/$reportId/answers',
    );

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(
          utf8.decode(response.bodyBytes),
        );
        return jsonData
            .map((item) => ReportAnswerModel.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> submitReportAnswer(int reportId, String content) async {
    final headers = await _getHeaders();
    // ZMĚNA: /create-report-answer -> /create-post-answer (odvozeno z logiky přejmenování)
    final url = Uri.parse(
      '${ApiConstants.communityBoardBaseUrl}/create-post-answer/1910',
    );
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({
          "content": content,
          "postId": reportId,
          "createdAt": DateTime.now().toUtc().toIso8601String(),
        }),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> upvoteReport(int reportId) async {
    final headers = await _getHeaders();
    final String userEmail = await _storage.getUserEmail() ?? "anonymous";

    final bytes = utf8.encode(userEmail);
    final digest = sha256.convert(bytes);
    final String hashedEmail = digest.toString();

    final url = Uri.parse(
      '${ApiConstants.communityBoardBaseUrl}/toggle-upvote',
    );

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({"postId": reportId, "upvoterEmailHash": hashedEmail}),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
