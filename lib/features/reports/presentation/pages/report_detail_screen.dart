import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../data/report_model.dart';
import '../../data/report_answer_model.dart';
import '../../data/reports_service.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../widgets/rating_dialog.dart';

class ReportDetailScreen extends StatefulWidget {
  final ReportModel report;

  const ReportDetailScreen({super.key, required this.report});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  final TextEditingController _commentController = TextEditingController();

  final ReportsService _reportsService = ReportsService();
  List<ReportAnswerModel> _comments = [];
  bool _isLoadingComments = true;
  bool _isSubmittingComment = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    final fetchedComments = await _reportsService.fetchReportAnswers(
      widget.report.id,
    );
    setState(() {
      _comments = fetchedComments;
      _isLoadingComments = false;
    });
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() {
      _isSubmittingComment = true;
    });

    bool success = await _reportsService.submitReportAnswer(
      widget.report.id,
      _commentController.text,
    );

    setState(() {
      _isSubmittingComment = false;
    });

    if (success) {
      _commentController.clear();
      _loadComments();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error submitting comment. Please try again.'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    if (status == 'NEW') return AppColors.statusWaiting;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.textOnWhite),
            onPressed: () {
              // TODO: Menu (např. smazat hlášení, pokud je moje)
            },
          ),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAuthorRow(),
                  const SizedBox(height: 16),

                  Text(
                    widget.report.description.isEmpty
                        ? widget.report.title
                        : widget.report.description,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildBadgesRow(),
                  const SizedBox(height: 24),

                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.image_outlined,
                        color: Colors.grey,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  _isLoadingComments
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        )
                      : Column(
                          children: _comments.map((comment) {
                            // Hezké naformátování data (např. 4. 3. 2026)
                            final dateText =
                                "${comment.createdAt.day}. ${comment.createdAt.month}. ${comment.createdAt.year}";
                            return _buildMockComment(
                              comment.authorName,
                              dateText,
                              comment.content,
                            );
                          }).toList(),
                        ),
                ],
              ),
            ),
          ),

          _buildCommentInputField(),
        ],
      ),
    );
  }

  Widget _buildAuthorRow() {
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
            "Eliška Borýsková • ${widget.report.dateAdded.day}. ${widget.report.dateAdded.month}. ${widget.report.dateAdded.year} • Budova Q",
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildBadgesRow() {
    return Row(
      children: [
        InkWell(
          onTap: () async {
            final int? submittedRating = await showDialog<int>(
              context: context,
              barrierColor: Colors.black.withOpacity(0.6),
              builder: (context) => const RatingDialog(),
            );

            if (submittedRating != null) {
              print("Rating submitted from UI: $submittedRating stars");

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Hodnocení $submittedRating hvězdiček uloženo (zatím jen lokálně).',
                    ),
                  ),
                );
              }
            }
          },
          child: _buildBadge(
            Icons.star,
            widget.report.upvotes.toString(),
            AppColors.white,
          ),
        ),
        const SizedBox(width: 8),
        // Počet komentářů
        _buildBadge(Icons.mode_comment_outlined, "2", AppColors.white),
        const SizedBox(width: 8),
        // Status hlášení
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusColor(widget.report.status),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            "Čeká na odpověď", // Zde pak dáme překlad statusu
            style: TextStyle(
              color: AppColors.background,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.background),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.background,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // Jeden komentář v seznamu
  Widget _buildMockComment(String name, String time, String text) {
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
                "$name • $time",
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(color: AppColors.white, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.favorite_border,
                color: Colors.white70,
                size: 16,
              ),
              const SizedBox(width: 4),
              const Text(
                "10",
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(width: 16),
              InkWell(
                onTap: () {},
                child: const Text(
                  "Odpovědět",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Spodní pole pro psaní zprávy
  Widget _buildCommentInputField() {
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
                  suffixIcon: const Icon(
                    Icons.mic,
                    color: Colors.white54,
                  ), // Ikonka mikrofonu z Figmy
                ),
              ),
            ),
            const SizedBox(width: 12),
            InkWell(
              onTap: _isSubmittingComment ? null : _submitComment,
              child: CircleAvatar(
                backgroundColor: AppColors.primary,
                radius: 22,
                child: _isSubmittingComment
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.send, color: AppColors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
