import 'package:flutter_test/flutter_test.dart';
import 'package:student_app/features/chatbot/data/models/chat_request_model.dart';

void main() {
  group('ChatRequestModel - Unit Testy', () {
    test(
      'toJson() - správně vygeneruje mapu s dodanými i výchozími parametry',
      () {
        // 1. ARRANGE:
        final request = ChatRequestModel(
          msg: "Ahoj, potřebuji poradit.",
          questions: ["Jak se máš?", "Kde je menza?"],
          answers: ["Mám se dobře."],
          conversationId: 999,
          conversationLang: "cs",
        );

        // 2. ACT:
        final json = request.toJson();

        // 3. ASSERT:
        expect(json['msg'], "Ahoj, potřebuji poradit.");
        expect(json['questions'], ["Jak se máš?", "Kde je menza?"]);
        expect(json['answers'], ["Mám se dobře."]);
        expect(json['conversationId'], 999);
        expect(json['conversationLang'], "cs");

        // ASSERT:
        expect(json['entityId'], 1910);
        expect(json['contextIds'], [null]);
        expect(json['additionalDatasets'], isEmpty);
        expect(json['webConfig'], isEmpty);
      },
    );

    test(
      'toJsonString() - správně převede celý model na validní JSON string',
      () {
        // 1. ARRANGE
        final request = ChatRequestModel(
          msg: "Testovací zpráva",
          questions: [],
          answers: [],
          conversationId: 1,
          conversationLang: "en",
        );

        // 2. ACT
        final jsonString = request.toJsonString();

        // 3. ASSERT:
        expect(jsonString.contains('"msg":"Testovací zpráva"'), true);
        expect(jsonString.contains('"conversationId":1'), true);
        expect(jsonString.contains('"conversationLang":"en"'), true);
        expect(jsonString.contains('"entityId":1910'), true);
      },
    );
  });
}
