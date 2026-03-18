import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/report_model.dart';
import '../data/report_answer_model.dart';

class ReportsService {
  Future<List<ReportModel>> fetchReports() async {
    final url = Uri.parse(
      'https://api.citymind.tech/reporting/reports?entity_id=1910',
    );
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final String responseBody = utf8.decode(response.bodyBytes);
        final List<dynamic> jsonData = jsonDecode(responseBody);
        return jsonData.map((item) => ReportModel.fromJson(item)).toList();
      } else {
        print(' SERVER ERROR: Code ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('CONNECTION ERROR: $e');
      return [];
    }
  }

  Future<String?> _getAccessToken() async {
    final url = Uri.parse(
      'https://auth.citymind.tech/realms/citymind/protocol/openid-connect/token/',
    );

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'password',
          'client_id': 'manager',
          'username': 'xmelnyk@mendelu.cz',
          'password': 'Baj.den.5.une',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['access_token'];
      } else {
        print('Error getting token: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Network error during login: $e');
      return null;
    }
  }

  Future<bool> submitReport({
    required String title,
    required String description,
    required String email,
  }) async {
    final token = await _getAccessToken();
    if (token == null) {
      print('No token available, cancelling submission.');
      return false;
    }

    final url = Uri.parse('https://api.manager.citymind.tech/reporting/');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "title": title,
          "description": description,
          "reportType": "REPORT",
          "authorEmail": email,
          "entityId": 1910,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Report submitted successfully!');
        return true;
      } else {
        print(
          'Error submitting report: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Network error during submission: $e');
      return false;
    }
  }

  Future<List<ReportAnswerModel>> fetchReportAnswers(int reportId) async {
    final token = await _getAccessToken();
    if (token == null) return [];

    final url = Uri.parse(
      'https://api.manager.citymind.tech/reporting/report-answers/1910/$reportId',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final String responseBody = utf8.decode(response.bodyBytes);
        final List<dynamic> jsonData = jsonDecode(responseBody);
        return jsonData
            .map((item) => ReportAnswerModel.fromJson(item))
            .toList();
      } else {
        print('Error getting comments: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Network error while fetching comments: $e');
      return [];
    }
  }

  Future<bool> submitReportAnswer(int reportId, String content) async {
    final token = await _getAccessToken();
    if (token == null) return false;

    final url = Uri.parse(
      'https://api.manager.citymind.tech/reporting/create-report-answer/1910',
    );

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "content": content,
          "createdAt": DateTime.now().toUtc().toIso8601String(),
          "reportId": reportId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('Error submitting comment: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Network error while submitting comment: $e');
      return false;
    }
  }
}
