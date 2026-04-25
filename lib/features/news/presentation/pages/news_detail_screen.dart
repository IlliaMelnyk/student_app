import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../data/models/news_model.dart';
import '../../../../l10n/generated/app_localizations.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class NewsDetailScreen extends StatelessWidget {
  final NewsModel news;

  const NewsDetailScreen({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.white,
                child: news.imageUrl != null
                    ? Image.network(news.imageUrl!, fit: BoxFit.cover)
                    : const Center(
                        child: Icon(
                          Icons.image_outlined,
                          color: Colors.grey,
                          size: 50,
                        ),
                      ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(news.categoryName),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      news.categoryName.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    news.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildIconRow(
                    Icons.calendar_today,
                    "${news.startDate.day}. ${news.startDate.month}. ${news.startDate.year}",
                  ),

                  if (news.customPlace != null) ...[
                    const SizedBox(height: 16),
                    _buildIconRow(
                      Icons.location_on_outlined,
                      news.customPlace!,
                    ),
                  ],

                  // Oddělovač
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Divider(color: Colors.white10),
                  ),

                  MarkdownBody(
                    data: news.text,
                    styleSheet: MarkdownStyleSheet(
                      p: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.5,
                      ),
                      strong: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      listBullet: const TextStyle(color: Colors.white),
                    ),
                  ),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 14)),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('událost')) return const Color(0xFF9C27B0);
    if (lower.contains('stud')) return const Color(0xFF2196F3);
    if (lower.contains('důlež')) return const Color(0xFFF44336);
    if (lower.contains('termín')) return const Color(0xFFFFB300);
    return AppColors.primary;
  }
}
