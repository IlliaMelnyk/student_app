import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/app_sidebar.dart';
import '../viewmodels/reports_viewmodel.dart';
import '../widgets/report_card.dart';
import './report_detail_screen.dart';
import './new_report_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportsViewModel>().loadReports();
    });
  }

  (String, Color) _getStatusInfo(String statusCode, AppLocalizations l10n) {
    switch (statusCode) {
      case 'NEW':
        return (l10n.statusNew, AppColors.statusWaiting);
      case 'IN_PROGRESS':
        return (l10n.statusInProgress, const Color.fromARGB(255, 63, 134, 211));
      case 'SOLVED':
        return (l10n.statusSolved, Colors.green);
      case 'HIDDEN':
        return (l10n.statusHidden, Colors.grey);
      default:
        return (statusCode, Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final viewModel = context.watch<ReportsViewModel>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.background,
        drawer: const AppSidebar(),
        appBar: CustomAppBar(
          title: l10n.reports,
          onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NewReportScreen()),
                ),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.textOnWhite,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: AppColors.textOnWhite,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Container(
              color: AppColors.background,
              child: TabBar(
                labelColor: AppColors.primary,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.label,
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
            viewModel.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : RefreshIndicator(
                    onRefresh: () => viewModel.loadReports(),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: viewModel.reports.length,
                      itemBuilder: (context, index) {
                        final report = viewModel.reports[index];
                        final statusInfo = _getStatusInfo(report.status, l10n);

                        return InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ReportDetailScreen(report: report),
                            ),
                          ),
                          child: ReportCard(
                            report: report,
                            statusText: statusInfo.$1,
                            statusColor: statusInfo.$2,
                          ),
                        );
                      },
                    ),
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
