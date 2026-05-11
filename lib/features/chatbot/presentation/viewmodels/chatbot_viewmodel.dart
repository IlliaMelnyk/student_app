import 'package:flutter/material.dart';
import '../../domain/repositories/chatbot_repository.dart';
import '../../data/models/chat_message_model.dart';
import '../../data/models/chat_request_model.dart';

class ChatbotViewModel extends ChangeNotifier {
  final ChatbotRepository repository;

  ChatbotViewModel({required this.repository});

  int _conversationId = DateTime.now().millisecondsSinceEpoch;

  final List<ChatMessageModel> _messages = [];

  bool _isLoading = false;

  List<ChatMessageModel> get messages => _messages;
  bool get isLoading => _isLoading;

  void setInitialGreeting(String greetingText, List<String> faqs) {
    if (_messages.isEmpty) {
      _messages.add(
        ChatMessageModel(text: greetingText, isUser: false, faqs: faqs),
      );
      Future.microtask(() => notifyListeners());
    } else if (!_messages.first.isUser) {
      _messages[0] = _messages[0].copyWith(text: greetingText, faqs: faqs);
      Future.microtask(() => notifyListeners());
    }
  }

  void resetChat(String resetMessage) {
    _messages.clear();
    _messages.add(ChatMessageModel(text: resetMessage, isUser: false));
    notifyListeners();
  }

  String _currentLang = 'cs';

  void updateLanguage(String newLang) {
    _currentLang = newLang;
    notifyListeners();
  }

  Future<void> sendMessage(String text, String languageCode) async {
    _currentLang = languageCode;
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
      conversationLang: languageCode,
    );

    try {
      await for (Map<String, dynamic> event in repository.getChatStream(
        request,
      )) {
        print("--- PŘIJATÝ EVENT Z BACKENDU ---");
        print(event);
        var currentMsg = _messages[aiMessageIndex];

        if (event.containsKey('error')) {
          _messages[aiMessageIndex] = currentMsg.copyWith(
            text: currentMsg.text + event['error'].toString(),
          );
        } else if (event.containsKey('response')) {
          _messages[aiMessageIndex] = currentMsg.copyWith(
            text: currentMsg.text + event['response'].toString(),
          );
        } else if (event.containsKey('sources')) {
          var sourcesData = event['sources'];
          List<String> extractedUrls = [];

          if (sourcesData is Map) {
            sourcesData.forEach((domain, links) {
              if (links is Iterable) {
                for (var link in links) {
                  if (link is Map && link.containsKey('url')) {
                    extractedUrls.add(link['url'].toString());
                  }
                }
              }
            });
          } else if (sourcesData is Iterable) {
            extractedUrls = List<String>.from(
              sourcesData.map((s) => s.toString()),
            );
          }

          _messages[aiMessageIndex] = currentMsg.copyWith(
            sources: extractedUrls,
          );
        } else if (event.containsKey('faq')) {
          var faqData = event['faq'];
          if (faqData is Iterable) {
            _messages[aiMessageIndex] = currentMsg.copyWith(
              faqs: List<String>.from(faqData),
            );
          } else if (faqData is Map) {
            print("VAROVÁNÍ: API poslalo FAQ jako Map místo List!");
          }
        }

        notifyListeners();
      }
    } catch (e) {
      _messages[aiMessageIndex] = _messages[aiMessageIndex].copyWith(
        text: "Error: $e",
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearEntireHistory() {
    _messages.clear();
    _conversationId = DateTime.now().millisecondsSinceEpoch;
    notifyListeners();
  }
}
