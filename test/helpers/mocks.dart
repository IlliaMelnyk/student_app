import 'package:mocktail/mocktail.dart';
import 'package:student_app/core/utils/secure_storage_service.dart';
import 'package:student_app/core/utils/shared_prefs_service.dart';
import 'package:student_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:student_app/features/reports/domain/repositories/reports_repository.dart';
import 'package:student_app/features/news/domain/repositories/news_reposiory.dart';
import 'package:student_app/features/chatbot/domain/repositories/chatbot_repository.dart';
import 'package:student_app/features/chatbot/data/models/chat_request_model.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockSecureStorageService extends Mock implements SecureStorageService {}

class MockReportsRepository extends Mock implements ReportsRepository {}

class MockSharedPrefsService extends Mock implements SharedPrefsService {}

class MockNewsRepository extends Mock implements NewsRepository {}

class MockChatbotRepository extends Mock implements ChatbotRepository {}

class FakeChatRequestModel extends Fake implements ChatRequestModel {}
