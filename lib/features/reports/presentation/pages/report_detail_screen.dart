import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../theme/app_colors.dart';
import '../../data/models/report_model.dart';
import '../../data/models/report_answer_model.dart';
import '../viewmodels/reports_viewmodel.dart';
import '../../../../l10n/generated/app_localizations.dart';

class ReportDetailScreen extends StatefulWidget {
  final ReportModel report;

  const ReportDetailScreen({super.key, required this.report});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportsViewModel>().loadComments(widget.report.id);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
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

    final currentReport = viewModel.reports.firstWhere(
      (r) => r.id == widget.report.id,
      orElse: () => widget.report,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 80,
        leading: InkWell(
          onTap: () => Navigator.of(context).pop(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.arrow_back_ios,
                color: AppColors.primary,
                size: 18,
              ),
              Text(
                l10n.back,
                style: const TextStyle(color: AppColors.primary, fontSize: 16),
              ),
            ],
          ),
        ),
        title: const Text(
          "Detail hlášení",
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAuthorRow(currentReport),
                  const SizedBox(height: 16),
                  Text(
                    currentReport.title,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentReport.description,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildBadgesRow(viewModel, currentReport),
                  const SizedBox(height: 24),
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: currentReport.imageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              currentReport.imageUrl!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Center(
                            child: Icon(
                              Icons.image_outlined,
                              color: Colors.grey,
                              size: 40,
                            ),
                          ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    "Komentáře",
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  viewModel.isLoadingComments
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        )
                      : Column(
                          children: viewModel.currentComments.isEmpty
                              ? [
                                  const Text(
                                    "Zatím žádné komentáře",
                                    style: TextStyle(color: Colors.white54),
                                  ),
                                ]
                              : viewModel.currentComments
                                    .map(
                                      (comment) => _buildCommentItem(comment),
                                    )
                                    .toList(),
                        ),
                ],
              ),
            ),
          ),
          _buildCommentInputField(viewModel, currentReport),
        ],
      ),
    );
  }

  Widget _buildAuthorRow(ReportModel report) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 16,
          backgroundColor: Colors.grey,
          child: Icon(Icons.person, color: AppColors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            "${report.authorName} • ${report.dateAdded.day}. ${report.dateAdded.month}. ${report.dateAdded.year} • ${report.place}",
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildBadgesRow(ReportsViewModel viewModel, ReportModel report) {
    final l10n = AppLocalizations.of(context)!;
    final statusInfo = _getStatusInfo(report.status, l10n);

    return Row(
      children: [
        InkWell(
          onTap: () {
            if (!report.isUpvoted) {
              viewModel.toggleUpvote(report.id);
            }
          },
          child: _buildBadge(
            report.isUpvoted ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
            report.upvoteCount.toString(),
            AppColors.white,
            isActive: report.isUpvoted,
          ),
        ),
        const SizedBox(width: 8),
        _buildBadge(
          Icons.mode_comment_outlined,
          report.commentCount.toString(),
          AppColors.white,
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusInfo.$2,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            statusInfo.$1,
            style: const TextStyle(
              color: AppColors.background,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(
    IconData icon,
    String text,
    Color backgroundColor, {
    bool isActive = false,
  }) {
    final contentColor = isActive ? AppColors.primary : AppColors.background;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: contentColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: contentColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(ReportAnswerModel comment) {
    final dateText =
        "${comment.createdAt.day}. ${comment.createdAt.month}. ${comment.createdAt.year}";
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 12,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, color: AppColors.white, size: 14),
              ),
              const SizedBox(width: 8),
              Text(
                "${comment.authorName} • $dateText",
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment.content,
            style: const TextStyle(color: AppColors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInputField(
    ReportsViewModel viewModel,
    ReportModel report,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                style: const TextStyle(color: AppColors.white),
                decoration: InputDecoration(
                  hintText: "Přidejte komentář...",
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            InkWell(
              onTap: () async {
                if (_commentController.text.trim().isEmpty) return;
                final success = await viewModel.sendAnswer(
                  report.id,
                  _commentController.text,
                );
                if (success) {
                  _commentController.clear();
                }
              },
              child: const CircleAvatar(
                backgroundColor: AppColors.primary,
                radius: 22,
                child: Icon(Icons.send, color: AppColors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
