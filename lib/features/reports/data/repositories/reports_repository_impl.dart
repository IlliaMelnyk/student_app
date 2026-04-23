import '../../domain/repositories/reports_repository.dart';
import '../datasources/reports_api.dart';
import '../models/report_model.dart';
import '../models/report_answer_model.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsApi api;
  ReportsRepositoryImpl({required this.api});

  @override
  Future<List<ReportModel>> getAllReports() => api.fetchReports();

  @override
  Future<bool> createReport(
    String title,
    String desc,
    String place,
    String authorName,
  ) => api.sendReport(title, desc, place);

  @override
  Future<List<ReportAnswerModel>> getAnswers(int reportId) =>
      api.fetchAnswers(reportId);

  @override
  Future<bool> sendAnswer(int reportId, String content) {
    return api.submitReportAnswer(reportId, content);
  }

  @override
  Future<bool> upvoteReport(int reportId) => api.upvoteReport(reportId);
}
