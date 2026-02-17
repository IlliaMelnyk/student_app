import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../data/chat_service.dart'; // Import Service
import '../data/chat_request_model.dart'; // Import Model

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController =
      ScrollController(); // Pro automatické scrollování dolů

  // Instance naší služby
  final ChatService _chatService = ChatService();

  // Unikátní ID konverzace (vygenerujeme si ho při startu)
  final int _conversationId = DateTime.now().millisecondsSinceEpoch;

  // Seznam zpráv (teď už bude dynamický!)
  final List<Map<String, dynamic>> _messages = [
    // Úvodní zpráva od AI (volitelné)
    {
      "isUser": false,
      "text":
          "Ahoj! Jsem Tessa, tvůj AI průvodce studiem na MENDELU. S čím ti mohu pomoci?",
    },
  ];

  // Stav: Zda se zrovna generuje odpověď (abychom zablokovali tlačítko)
  bool _isLoading = false;

  // --- HLAVNÍ FUNKCE PRO ODESLÁNÍ ---
  void _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    // 1. Přidáme zprávu uživatele do seznamu a smažeme pole
    setState(() {
      _messages.add({"isUser": true, "text": text});
      _isLoading = true; // Zapneme načítání
    });
    _textController.clear();
    _scrollToBottom(); // Sjedeme dolů

    // 2. Připravíme prázdnou bublinu pro AI (do které budeme připisovat text)
    setState(() {
      _messages.add({"isUser": false, "text": ""}); // Zatím prázdný text
    });

    // 3. Vytvoříme data pro server (Model)
    // Potřebujeme historii otázek a odpovědí pro kontext
    List<String> questions = _messages
        .where((m) => m['isUser'] == true)
        .map((m) => m['text'] as String)
        .toList();

    List<String> answers = _messages
        .where(
          (m) => m['isUser'] == false && m['text'] != "",
        ) // Vynecháme tu aktuální prázdnou
        .map((m) => m['text'] as String)
        .toList();

    final request = ChatRequestModel(
      msg: text,
      questions: questions,
      answers: answers,
      conversationId: _conversationId,
    );

    // 4. Spustíme STREAMING (To je ta magie!)
    try {
      // Posloucháme proud dat...
      await for (String chunk in _chatService.streamResponse(request)) {
        setState(() {
          // Najdeme poslední zprávu (tu naši prázdnou bublinu) a přilepíme k ní další kousek textu
          final lastIndex = _messages.length - 1;
          _messages[lastIndex]['text'] = _messages[lastIndex]['text'] + chunk;
        });
        _scrollToBottom(); // Při každém písmenku posuneme chat dolů
      }
    } catch (e) {
      // Kdyby se něco pokazilo
      setState(() {
        final lastIndex = _messages.length - 1;
        _messages[lastIndex]['text'] =
            "Omlouvám se, došlo k chybě připojení: $e";
      });
    } finally {
      // Ať už to dopadne jakkoliv, vypneme načítání
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _scrollToBottom() {
    // Počkáme chvilku, než se UI překreslí, a pak sjedeme dolů
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // --- APP BAR ---
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.textDarkPurple),
          onPressed: () {},
        ),
        title: Image.asset(
          'assets/images/logo.png',
          height: 24,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
        actions: [
          // Tlačítko pro reset (vyčistí chat)
          IconButton(
            icon: const Icon(
              Icons.edit_square,
              color: AppColors.textDarkPurple,
            ),
            onPressed: () {
              setState(() {
                _messages.clear(); // Smaže zprávy
                _messages.add({
                  "isUser": false,
                  "text": "Chat byl resetován. Jak mohu pomoci?",
                });
              });
            },
          ),
        ],
      ),

      // --- TĚLO CHATU ---
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController, // Připojíme scroll controller
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['isUser'];

                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.8,
                    ),
                    decoration: BoxDecoration(
                      color: isUser ? AppColors.primary : AppColors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: isUser
                            ? const Radius.circular(20)
                            : Radius.zero,
                        bottomRight: isUser
                            ? Radius.zero
                            : const Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isUser)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text(
                              "AI",
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        Text(
                          msg['text'],
                          style: TextStyle(
                            color: isUser
                                ? AppColors.white
                                : AppColors.textDarkPurple,
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // --- VSTUPNÍ POLE ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _textController,
                style: const TextStyle(color: AppColors.textDarkPurple),
                // Pokud zrovna načítáme, zakážeme psaní (volitelné)
                enabled: !_isLoading,
                onSubmitted: (_) => _sendMessage(), // Odeslání Enterem
                decoration: InputDecoration(
                  hintText: _isLoading
                      ? "Čekám na odpověď..."
                      : "Zeptej se mě...",
                  hintStyle: TextStyle(
                    color: AppColors.primary.withOpacity(0.7),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),

                  // Ikonka odeslání místo mikrofonu
                  suffixIcon: IconButton(
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ) // Točící kolečko
                        : const Icon(Icons.send, color: AppColors.primary),
                    onPressed: _isLoading
                        ? null
                        : _sendMessage, // Po kliknutí odešle
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
