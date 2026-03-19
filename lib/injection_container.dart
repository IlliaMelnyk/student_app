import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'core/utils/secure_storage_service.dart';
import 'features/auth/data/datasources/auth_api.dart';
import 'features/auth/data/repositories/auth_repo_impl.dart';
import 'features/auth/presentation/viewmodels/login_viewmodel.dart';

import 'features/chatbot/data/datasources/chatbot_api.dart';
import 'features/chatbot/data/repositories/chatbot_repository_impl.dart';
import 'features/chatbot/presentation/viewmodels/chatbot_viewmodel.dart';

Future<List<SingleChildWidget>> initDependencies() async {
  final secureStorage = SecureStorageService();

  final authApi = AuthApi();
  final authRepository = AuthRepositoryImpl(api: authApi);

  final chatbotApi = ChatbotApi();
  final chatbotRepository = ChatbotRepositoryImpl(api: chatbotApi);

  return [
    ChangeNotifierProvider(
      create: (_) => AuthViewModel(
        repository: authRepository,
        secureStorage: secureStorage,
      ),
    ),
    ChangeNotifierProvider(
      create: (_) => ChatbotViewModel(repository: chatbotRepository),
    ),
  ];
}
