import 'package:flutter/material.dart';
import '../../domain/repositories/chatbot_repository.dart';
import '../../data/models/chat_message_model.dart';
import '../../data/models/chat_request_model.dart';

class ChatbotViewModel extends ChangeNotifier {
  final ChatbotRepository repository;

  ChatbotViewModel({required this.repository});

  final int _conversationId = DateTime.now().millisecondsSinceEpoch;
  final List<ChatMessageModel> _messages = [
    ChatMessageModel(
      text:
          "Ahoj! Jsem Tessa, tvůj AI průvodce studiem na MENDELU. S čím ti mohu pomoci?",
      isUser: false,
    ),
  ];

  bool _isLoading = false;

  List<ChatMessageModel> get messages => _messages;
  bool get isLoading => _isLoading;

  void resetChat() {
    _messages.clear();
    _messages.add(
      ChatMessageModel(
        text: "Chat byl resetován. Jak mohu pomoci?",
        isUser: false,
      ),
    );
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    _messages.add(ChatMessageModel(text: text, isUser: true));
    _isLoading = true;
    notifyListeners();

    _messages.add(ChatMessageModel(text: "", isUser: false));
    final aiMessageIndex = _messages.length - 1;
    notifyListeners();

    List<String> questions = _messages
        .where((m) => m.isUser)
        .map((m) => m.text)
        .toList();
    List<String> answers = _messages
        .where((m) => !m.isUser && m.text.isNotEmpty)
        .map((m) => m.text)
        .toList();

    final request = ChatRequestModel(
      msg: text,
      questions: questions,
      answers: answers,
      conversationId: _conversationId,
    );

    try {
      await for (String chunk in repository.getChatStream(request)) {
        final currentText = _messages[aiMessageIndex].text;
        _messages[aiMessageIndex] = _messages[aiMessageIndex].copyWith(
          text: currentText + chunk,
        );
        notifyListeners();
      }
    } catch (e) {
      _messages[aiMessageIndex] = _messages[aiMessageIndex].copyWith(
        text: "Chyba spojení: $e",
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
