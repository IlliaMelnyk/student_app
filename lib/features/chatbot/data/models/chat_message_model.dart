class ChatMessageModel {
  final String text;
  final bool isUser;

  ChatMessageModel({required this.text, required this.isUser});

  ChatMessageModel copyWith({String? text, bool? isUser}) {
    return ChatMessageModel(
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
    );
  }
}
