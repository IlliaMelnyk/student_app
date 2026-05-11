import 'dart:convert';

class ChatRequestModel {
  final int entityId;
  final String msg;
  final List<String> questions;
  final List<String> answers;
  final int conversationId;
  final String conversationLang;
  final List<dynamic> contextIds;
  final List<dynamic> additionalDatasets;
  final Map<String, dynamic> webConfig;

  ChatRequestModel({
    required this.msg,
    required this.questions,
    required this.answers,
    required this.conversationId,
    this.entityId = 1910,
    required this.conversationLang,
    this.contextIds = const [null],
    this.additionalDatasets = const [],
    this.webConfig = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      "entityId": entityId,
      "msg": msg,
      "questions": questions,
      "answers": answers,
      "conversationId": conversationId,
      "conversationLang": conversationLang,
      "contextIds": contextIds,
      "additionalDatasets": additionalDatasets,
      "webConfig": webConfig,
    };
  }

  String toJsonString() => json.encode(toJson());
}
