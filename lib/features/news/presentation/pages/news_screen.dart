import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_app/features/news/presentation/pages/news_settings_screen.dart';
import '../../../../theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../viewmodels/news_viewmodel.dart';
import '../widgets/news_card.dart';
import './news_detail_screen.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/app_sidebar.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final lang = Localizations.localeOf(context).languageCode;
      context.read<NewsViewModel>().loadNews(lang);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. NAČTENÍ PŘEKLADŮ
    final l10n = AppLocalizations.of(context)!;
    final viewModel = context.watch<NewsViewModel>();
    final lang = Localizations.localeOf(context).languageCode;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: const AppSidebar(),
      appBar: CustomAppBar(
        onMenuPressed: _isSearching
            ? null
            : () => _scaffoldKey.currentState?.openDrawer(),
        leading: _isSearching
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.textDarkPurple,
                ),
                onPressed: () {
                  setState(() => _isSearching = false);
                  _searchController.clear();
                  viewModel.filterNews("");
                },
              )
            : null,
        titleWidget: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(
                  color: AppColors.textDarkPurple,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: l10n.searchInNews,
                  border: InputBorder.none,
                  hintStyle: const TextStyle(color: Colors.grey),
                ),
                onChanged: (val) => viewModel.filterNews(val),
              )
            : null,
        title: _isSearching ? null : l10n.news,
        actions: [
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search, color: AppColors.textDarkPurple),
              onPressed: () => setState(() => _isSearching = true),
            ),
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: AppColors.textDarkPurple,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NewsSettingsScreen()),
              ).then((shouldRefresh) {
                if (shouldRefresh == true) {
                  viewModel.refreshAfterSettings(lang);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.black,
                      behavior: SnackBarBehavior.floating,
                      elevation: 0,
                      margin: const EdgeInsets.only(
                        bottom: 30,
                        left: 16,
                        right: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      content: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.primary,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            l10n.changesSaved,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              });
            },
          ),
        ],
      ),
      body: viewModel.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : RefreshIndicator(
              onRefresh: () => viewModel.loadNews(lang),
              child: ListView.builder(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 8,
                  bottom: 16,
                ),
                itemCount: viewModel.newsItems.length,
                itemBuilder: (context, index) {
                  final news = viewModel.newsItems[index];
                  return NewsCard(
                    news: news,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NewsDetailScreen(news: news),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
