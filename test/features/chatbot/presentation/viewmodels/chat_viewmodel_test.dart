import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:student_app/features/chatbot/presentation/viewmodels/chatbot_viewmodel.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late ChatbotViewModel viewModel;
  late MockChatbotRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(FakeChatRequestModel());
  });

  setUp(() {
    mockRepo = MockChatbotRepository();
    viewModel = ChatbotViewModel(repository: mockRepo);
  });

  group('ChatbotViewModel - Stream Tests', () {
    test('sendMessage() - správně spojí (zřetězí) data ze Streamu', () async {
      final streamOdpovedi = Stream.fromIterable([
        {'response': 'Ahoj, '},
        {'response': 'jsem '},
        {'response': 'Tessa!'},
        {
          'sources': ['http://mendelu.cz'],
        },
      ]);

      when(
        () => mockRepo.getChatStream(any()),
      ).thenAnswer((_) => streamOdpovedi);

      final future = viewModel.sendMessage('Kdo jsi?', 'cs');

      expect(viewModel.messages.length, 2);
      expect(viewModel.isLoading, true);

      await future;

      final aiMessage = viewModel.messages.last;
      expect(aiMessage.isUser, false);
      expect(aiMessage.text, 'Ahoj, jsem Tessa!');
      expect(aiMessage.sources, ['http://mendelu.cz']);
      expect(viewModel.isLoading, false);
    });

    test('sendMessage() - ignoruje prázdný text', () async {
      await viewModel.sendMessage('   ', 'cs');
      expect(viewModel.messages.isEmpty, true);
      verifyNever(() => mockRepo.getChatStream(any()));
    });
  });
}
