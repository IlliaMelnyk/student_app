import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_request_model.dart';
import '../../../../core/utils/api_constants.dart';
import '../../../../core/utils/secure_storage_service.dart';

class ChatbotApi {
  final SecureStorageService _storage = SecureStorageService();

  Stream<Map<String, dynamic>> streamResponse(
    ChatRequestModel requestBody,
  ) async* {
    final client = http.Client();
    final request = http.Request('POST', Uri.parse(ApiConstants.chatbotUrl));

    final token = await _storage.getToken();
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Content-Type'] = 'application/json';
    request.headers['accept'] = 'application/json';
    request.body = requestBody.toJsonString();

    try {
      final response = await client.send(request);

      if (response.statusCode == 200) {
        Stream<String> byteStream = response.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter());

        await for (String line in byteStream) {
          if (line.startsWith('data: ')) {
            final jsonString = line.substring(6).trim();
            if (jsonString.isNotEmpty && jsonString != "[DONE]") {
              try {
                final jsonData = jsonDecode(jsonString);
                if (jsonData is Map<String, dynamic>) {
                  yield jsonData;
                }
              } catch (_) {}
            }
          }
        }
      } else {
        yield {"error": "Chyba serveru (${response.statusCode})"};
      }
    } catch (e) {
      yield {"error": "Chyba připojení: $e"};
    } finally {
      client.close();
    }
  }
}
