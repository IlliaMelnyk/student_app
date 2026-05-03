import 'package:student_app/features/reports/data/models/report_answer_model.dart';
import 'package:student_app/features/reports/data/models/report_model.dart';

abstract class ReportsRepository {
  Future<List<ReportModel>> getAllReports();
  Future<bool> createReport(String title, String desc, String place);

  Future<List<ReportAnswerModel>> getAnswers(int reportId);

  Future<bool> sendAnswer(int reportId, String content);

  Future<bool> upvoteReport(int reportId);

  Future<bool> unvoteReport(int reportId);
}
