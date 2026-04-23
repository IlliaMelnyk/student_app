import 'package:flutter/material.dart';
import '../../domain/repositories/reports_repository.dart';
import '../../data/models/report_model.dart';
import '../../data/models/report_answer_model.dart';
import '../../../../core/utils/shared_prefs_service.dart';

class ReportsViewModel extends ChangeNotifier {
  final ReportsRepository repository;
  final SharedPrefsService _prefsService = SharedPrefsService();

  ReportsViewModel({required this.repository});

  List<ReportModel> _reports = [];
  bool _isLoading = false;

  List<ReportAnswerModel> _currentComments = [];
  bool _isLoadingComments = false;

  List<ReportModel> get reports => _reports;
  bool get isLoading => _isLoading;
  List<ReportAnswerModel> get currentComments => _currentComments;
  bool get isLoadingComments => _isLoadingComments;

  Future<void> loadReports() async {
    _isLoading = true;
    notifyListeners();

    final fetchedReports = await repository.getAllReports();

    final upvotedIds = await _prefsService.getUpvotedReportIds();

    _reports = fetchedReports.map((report) {
      if (upvotedIds.contains(report.id)) {
        return report.copyWith(isUpvoted: true);
      }
      return report;
    }).toList();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadComments(int reportId) async {
    _isLoadingComments = true;
    _currentComments = [];
    notifyListeners();
    _currentComments = await repository.getAnswers(reportId);
    _isLoadingComments = false;
    notifyListeners();
  }

  Future<bool> addReport(
    String title,
    String desc,
    String place,
    String authorName,
  ) async {
    final success = await repository.createReport(
      title,
      desc,
      place,
      authorName,
    );
    if (success) await loadReports();
    return success;
  }

  Future<bool> sendAnswer(int reportId, String content) async {
    if (content.trim().isEmpty) return false;
    _isLoadingComments = true;
    notifyListeners();

    final success = await repository.sendAnswer(reportId, content);

    if (success) {
      await loadComments(reportId);
      final index = _reports.indexWhere((r) => r.id == reportId);
      if (index != -1) {
        _reports[index] = _reports[index].copyWith(
          commentCount: _reports[index].commentCount + 1,
        );
        notifyListeners();
      }
    } else {
      _isLoadingComments = false;
      notifyListeners();
    }

    return success;
  }

  Future<void> toggleUpvote(int reportId) async {
    final index = _reports.indexWhere((r) => r.id == reportId);
    if (index == -1) return;

    final report = _reports[index];

    if (report.isUpvoted) {
      await _prefsService.removeUpvotedReportId(reportId);

      _reports[index] = report.copyWith(
        upvoteCount: report.upvoteCount - 1,
        isUpvoted: false,
      );
      notifyListeners();
    } else {
      final success = await repository.upvoteReport(reportId);

      if (success) {
        await _prefsService.saveUpvotedReportId(reportId);

        _reports[index] = report.copyWith(
          upvoteCount: report.upvoteCount + 1,
          isUpvoted: true,
        );
        notifyListeners();
      }
    }
  }
}
