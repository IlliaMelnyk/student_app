import '../../domain/repositories/chatbot_repository.dart';
import '../datasources/chatbot_api.dart';
import '../models/chat_request_model.dart';

class ChatbotRepositoryImpl implements ChatbotRepository {
  final ChatbotApi api;

  ChatbotRepositoryImpl({required this.api});

  @override
  Stream<Map<String, dynamic>> getChatStream(ChatRequestModel request) {
    return api.streamResponse(request);
  }
}
