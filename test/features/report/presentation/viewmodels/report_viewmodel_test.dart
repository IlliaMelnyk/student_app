import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:student_app/features/reports/presentation/viewmodels/reports_viewmodel.dart';
import 'package:student_app/features/reports/data/models/report_model.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late ReportsViewModel viewModel;
  late MockReportsRepository mockRepo;

  setUp(() {
    mockRepo = MockReportsRepository();
    viewModel = ReportsViewModel(
      repository: mockRepo,
      prefsService: MockSharedPrefsService(),
      secureStorage: MockSecureStorageService(),
    );
  });

  group('ReportsViewModel - Rollback mechanismus', () {
    test(
      'toggleUpvote() - při selhání sítě provede okamžitý Rollback',
      () async {
        final report = ReportModel(
          id: 1,
          title: "Test",
          description: "Desc",
          status: "NEW",
          dateAdded: DateTime.now(),
          upvoteCount: 10,
          authorName: "Illia",
          place: "Q01",
          commentCount: 0,
          isUpvoted: false,
        );

        viewModel.reports.add(report);

        when(() => mockRepo.upvoteReport(1)).thenAnswer((_) async => false);

        await viewModel.toggleUpvote(1);

        expect(viewModel.reports.first.upvoteCount, 10);
        expect(viewModel.reports.first.isUpvoted, false);
      },
    );
  });
}
