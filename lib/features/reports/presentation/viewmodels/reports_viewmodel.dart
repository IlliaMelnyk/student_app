import 'package:flutter/material.dart';
import '../../domain/repositories/reports_repository.dart';
import '../../data/models/report_model.dart';
import '../../data/models/report_answer_model.dart';
import '../../../../core/utils/shared_prefs_service.dart';
import '../../../../core/utils/secure_storage_service.dart';

class ReportsViewModel extends ChangeNotifier {
  final ReportsRepository repository;
  final SharedPrefsService _prefsService = SharedPrefsService();
  final SecureStorageService _secureStorage = SecureStorageService();

  ReportsViewModel({required this.repository});

  List<ReportModel> _reports = [];
  bool _isLoading = false;

  List<ReportAnswerModel> _currentComments = [];
  bool _isLoadingComments = false;

  String? _currentUserEmail;
  String? _currentUserName;

  List<ReportModel> get reports => _reports;

  List<ReportModel> get myReports {
    if (_currentUserName == null) return [];
    return _reports.where((r) => r.authorName == _currentUserName).toList();
  }

  bool get isLoading => _isLoading;
  List<ReportAnswerModel> get currentComments => _currentComments;
  bool get isLoadingComments => _isLoadingComments;

  void clearData() {
    _reports = [];
    _currentUserEmail = null;
    _currentUserName = null;
    notifyListeners();
  }

  Future<void> loadReports() async {
    _isLoading = true;
    notifyListeners();

    _currentUserEmail = await _secureStorage.getUserEmail() ?? "anon_email";
    _currentUserName = await _secureStorage.getUserName();

    final fetchedReports = await repository.getAllReports();

    final upvotedIds = await _prefsService.getUpvotedReportIds(
      _currentUserEmail!,
    );

    _reports = fetchedReports.map((report) {
      if (upvotedIds.contains(report.id)) {
        return report.copyWith(isUpvoted: true);
      }
      return report;
    }).toList();

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addReport(String title, String desc, String place) async {
    final success = await repository.createReport(title, desc, place);
    if (success) await loadReports();
    return success;
  }

  Future<void> toggleUpvote(int reportId) async {
    if (_currentUserEmail == null) return;

    final index = _reports.indexWhere((r) => r.id == reportId);
    if (index == -1) return;

    final report = _reports[index];
    final bool wasUpvoted = report.isUpvoted;
    final int oldUpvoteCount = report.upvoteCount;

    if (wasUpvoted) {
      _reports[index] = report.copyWith(
        upvoteCount: oldUpvoteCount > 0 ? oldUpvoteCount - 1 : 0,
        isUpvoted: false,
      );
      await _prefsService.removeUpvotedReportId(reportId, _currentUserEmail!);
    } else {
      _reports[index] = report.copyWith(
        upvoteCount: oldUpvoteCount + 1,
        isUpvoted: true,
      );
      await _prefsService.saveUpvotedReportId(reportId, _currentUserEmail!);
    }
    notifyListeners();

    bool success = false;
    try {
      if (wasUpvoted) {
        success = await repository.unvoteReport(reportId);
      } else {
        success = await repository.upvoteReport(reportId);
      }
    } catch (e) {
      success = false;
    }

    if (!success) {
      _reports[index] = report.copyWith(
        upvoteCount: oldUpvoteCount,
        isUpvoted: wasUpvoted,
      );

      if (wasUpvoted) {
        await _prefsService.saveUpvotedReportId(reportId, _currentUserEmail!);
      } else {
        await _prefsService.removeUpvotedReportId(reportId, _currentUserEmail!);
      }
      notifyListeners();
    }
  }

  Future<void> loadComments(int reportId) async {
    _isLoadingComments = true;
    _currentComments = [];
    notifyListeners();
    _currentComments = await repository.getAnswers(reportId);
    _isLoadingComments = false;
    notifyListeners();
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
}
