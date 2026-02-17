import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'chat_request_model.dart';

class ChatService {
  static const String _apiUrl = 'https://api.citymind.tech/get';

  Stream<String> streamResponse(ChatRequestModel requestBody) async* {
    final client = http.Client();

    print("Odesílám na: $_apiUrl");

    final request = http.Request('POST', Uri.parse(_apiUrl));

    request.headers['Content-Type'] = 'application/json';
    request.headers['accept'] = 'application/json';

    request.body = jsonEncode(requestBody.toJson());

    try {
      final response = await client.send(request);

      print("Status kód: ${response.statusCode}");

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

                if (jsonData is Map<String, dynamic> &&
                    jsonData.containsKey('response')) {
                  yield jsonData['response'].toString();
                }
              } catch (e) {
                print("Chyba parsování JSON: $e");
              }
            }
          }
        }
      } else {
        // Pokud to zase hodí chybu, přečteme ji celou
        final errorBody = await response.stream.bytesToString();
        print("CHYBA SERVERU: $errorBody");
        yield "Chyba serveru (${response.statusCode})";
      }
    } catch (e) {
      yield "Chyba připojení: $e";
    } finally {
      client.close();
    }
  }
}
