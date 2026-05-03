import '../../data/models/chat_request_model.dart';

abstract class ChatbotRepository {
  Stream<Map<String, dynamic>> getChatStream(ChatRequestModel request);
}
