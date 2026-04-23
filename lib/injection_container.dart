import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:student_app/features/news/data/datasources/news_api.dart';
import 'package:student_app/features/news/data/repositories/news_repository_impl.dart';
import 'package:student_app/features/news/presentation/viewmodels/news_viewmodel.dart';
import 'package:student_app/features/reports/data/datasources/reports_api.dart';
import 'package:student_app/features/reports/data/repositories/reports_repository_impl.dart';
import 'package:student_app/features/reports/presentation/viewmodels/reports_viewmodel.dart';

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

  final reportsApi = ReportsApi();
  final reportsRepository = ReportsRepositoryImpl(api: reportsApi);

  final newsApi = NewsApi();
  final newsRepository = NewsRepositoryImpl(api: newsApi);

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
    ChangeNotifierProvider(
      create: (_) => ReportsViewModel(repository: reportsRepository),
    ),
    ChangeNotifierProvider(
      create: (_) => NewsViewModel(repository: newsRepository),
    ),
  ];
}
