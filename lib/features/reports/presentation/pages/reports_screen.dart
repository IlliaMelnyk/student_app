import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../widgets/report_card.dart';
import '../../../../l10n/generated/app_localizations.dart';
import './new_report_screen.dart';
import '../../data/reports_service.dart';
import '../../data/report_model.dart';
import './report_detail_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final ReportsService _reportsService = ReportsService();

  List<ReportModel> _reports = [];
  bool _isLoading = true;

  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final stazenaData = await _reportsService.fetchReports();
    setState(() {
      _reports = stazenaData;
      _isLoading = false;
    });
  }

  (String, Color) _getStatusInfo(String statusCode) {
    switch (statusCode) {
      case 'NEW':
        return ("Nový", AppColors.statusWaiting);
      default:
        return (statusCode, Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,

        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          centerTitle: true,

          title: Text(
            l10n.reports,
            style: const TextStyle(
              color: AppColors.textOnWhite,
              fontWeight: FontWeight.bold,
            ),
          ),

          iconTheme: const IconThemeData(color: AppColors.textOnWhite),

          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NewReportScreen(),
                    ),
                  );
                  _loadData();
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.textOnWhite,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: AppColors.textOnWhite,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],

          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: Container(
              color: AppColors.background,
              child: TabBar(
                labelColor: AppColors.primary,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                tabs: [
                  Tab(text: l10n.myReports),
                  Tab(text: l10n.allReports),
                ],
              ),
            ),
          ),
        ),

        body: TabBarView(
          children: [
            _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _reports.length,
                    itemBuilder: (context, index) {
                      final report = _reports[index];
                      final statusInfo = _getStatusInfo(report.status);

                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ReportDetailScreen(report: report),
                            ),
                          );
                        },
                        child: ReportCard(
                          title: report.title,
                          description: report.description,
                          date:
                              "${report.dateAdded.day}. ${report.dateAdded.month}. ${report.dateAdded.year}",
                          building: "Kampus",
                          statusText: statusInfo.$1,
                          statusColor: statusInfo.$2,
                          rating: report.upvotes.toString(),
                          comments: "0",
                        ),
                      );
                    },
                  ),
            Center(
              child: Text(
                l10n.allReports,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
