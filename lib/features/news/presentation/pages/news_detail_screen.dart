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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leadingWidth: 100,
        leading: TextButton.icon(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.primary,
            size: 16,
          ),
          label: Text(
            l10n.back,
            style: const TextStyle(color: AppColors.primary, fontSize: 16),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.white,
                    child: Text(
                      'M',
                      style: TextStyle(
                        color: AppColors.background,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.mendelUniversity,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 16),

              // 2. Nadpis
              Text(
                news.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildFigmaBadge(
                    Icons.calendar_today,
                    "${news.startDate.day}. ${news.startDate.month}. ${news.startDate.year}",
                  ),
                  if (news.customPlace != null)
                    _buildFigmaBadge(Icons.location_on, news.customPlace!),
                ],
              ),
              const SizedBox(height: 24),

              MarkdownBody(
                data: news.text,
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.6,
                  ),
                  strong: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  listBullet: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 32),

              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: news.imageUrl != null && news.imageUrl!.isNotEmpty
                    ? Image.network(
                        news.imageUrl!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildImagePlaceholder(),
                      )
                    : _buildImagePlaceholder(),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFigmaBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.background,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 200,
      color: Colors.white,
      child: const Center(
        child: Icon(Icons.image_outlined, color: Colors.grey, size: 50),
      ),
    );
  }
}
