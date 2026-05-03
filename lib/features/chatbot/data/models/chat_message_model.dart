class ChatMessageModel {
  final String text;
  final bool isUser;
  final List<String> sources;
  final List<String> faqs;

  ChatMessageModel({
    required this.text,
    required this.isUser,
    List<String>? sources,
    List<String>? faqs,
  }) : sources = sources ?? [],
       faqs = faqs ?? [];

  ChatMessageModel copyWith({
    String? text,
    bool? isUser,
    List<String>? sources,
    List<String>? faqs,
  }) {
    return ChatMessageModel(
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      sources: sources ?? this.sources,
      faqs: faqs ?? this.faqs,
    );
  }
}
