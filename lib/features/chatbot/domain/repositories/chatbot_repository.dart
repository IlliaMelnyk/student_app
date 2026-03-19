import '../../data/models/chat_request_model.dart';

abstract class ChatbotRepository {
  Stream<String> getChatStream(ChatRequestModel request);
}
