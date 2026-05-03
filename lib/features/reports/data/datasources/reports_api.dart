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
  final int entityId = 1910;

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<ReportModel>> fetchReports() async {
    final url = Uri.parse('${ApiConstants.communityBoardBaseUrl}/$entityId');
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
    final url = Uri.parse('${ApiConstants.communityBoardBaseUrl}/');

    final String authorEmail =
        await _storage.getUserEmail() ?? "neznamy@email.cz";
    final String authorName =
        await _storage.read('user_name') ?? "Student MENDELU";

    final bodyData = {
      "authorEmail": authorEmail,
      "authorName": authorName,
      "description": description,
      "entityId": 1910,
      "place": place,
      "postType": "POST",
      "title": title,
    };

    final bodyStr = jsonEncode(bodyData);
    var headers = await _getHeaders();

    print("--- START SEND REPORT ---");
    print("URL: $url");
    print("BODY: $bodyStr");

    var response = await http.post(url, headers: headers, body: bodyStr);

    print("SEND REPORT STATUS CODE: ${response.statusCode}");
    print("SEND REPORT RESPONSE: ${response.body}");

    if (response.statusCode == 401) {
      print("SEND REPORT: 401 Token vypršel, zkouším refresh...");
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken != null) {
        final newTokens = await AuthApi().refreshCitymindToken(refreshToken);

        if (newTokens != null) {
          await _storage.saveTokens(
            access: newTokens.accessToken,
            refresh: newTokens.refreshToken,
          );

          headers = await _getHeaders();
          response = await http.post(url, headers: headers, body: bodyStr);

          print("RETRY SEND REPORT STATUS CODE: ${response.statusCode}");
          print("RETRY SEND REPORT RESPONSE: ${response.body}");
        }
      }
    }

    if (response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 204) {
      return true;
    } else {
      return false;
    }
  }

  Future<List<ReportAnswerModel>> fetchAnswers(int reportId) async {
    final headers = await _getHeaders();
    final url = Uri.parse(
      '${ApiConstants.communityBoardBaseUrl}/comments/$entityId/$reportId',
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
    final String authorName =
        await _storage.read('user_name') ?? "Student MENDELU";
    final url = Uri.parse(
      '${ApiConstants.communityBoardBaseUrl}/create-comment/$entityId',
    );
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({
          "content": content,
          "postId": reportId,
          "createdAt": DateTime.now().toUtc().toIso8601String(),
          "authorName": authorName,
        }),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> upvoteReport(int postId) async {
    final headers = await _getHeaders();
    final String userEmail = await _storage.getUserEmail() ?? "anonymous";

    final bytes = utf8.encode(userEmail);
    final digest = sha256.convert(bytes);
    final String hashedEmail = digest.toString();

    final url = Uri.parse('${ApiConstants.communityBoardBaseUrl}/upvote');

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({"postId": postId, "upvoterEmailHash": hashedEmail}),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Chyba při odesílání upvote: $e");
      return false;
    }
  }

  Future<bool> removeUpvote(int postId) async {
    final headers = await _getHeaders();
    final String userEmail = await _storage.getUserEmail() ?? "anonymous";

    final bytes = utf8.encode(userEmail);
    final digest = sha256.convert(bytes);
    final String hashedEmail = digest.toString();

    final url = Uri.parse('${ApiConstants.communityBoardBaseUrl}/upvote');

    try {
      final request = http.Request('DELETE', url)
        ..headers.addAll(headers)
        ..body = jsonEncode({
          "postId": postId,
          "upvoterEmailHash": hashedEmail,
        });

      final response = await http.Client().send(request);
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print("Chyba při mazání upvote: $e");
      return false;
    }
  }
}
