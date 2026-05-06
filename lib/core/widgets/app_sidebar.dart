import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_app/core/provider/locale_provider.dart';
import 'package:student_app/features/auth/presentation/pages/welcome_screen.dart';
import 'package:student_app/features/auth/presentation/viewmodels/login_viewmodel.dart';
import 'package:student_app/features/news/presentation/viewmodels/news_viewmodel.dart';
import 'package:student_app/features/reports/presentation/viewmodels/reports_viewmodel.dart';
import 'package:student_app/l10n/generated/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../utils/secure_storage_service.dart';

class AppSidebar extends StatefulWidget {
  const AppSidebar({super.key});

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> {
  final SecureStorageService _storage = SecureStorageService();

  String _userName = "Načítám...";
  String _faculty = "MENDELU";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final name = await _storage.read('user_name');

    if (mounted) {
      setState(() {
        _userName = name ?? "Student MENDELU";
      });
    }
  }

  Future<void> _logout() async {
    if (!mounted) return;

    context.read<ReportsViewModel>().clearData();
    await context.read<AuthViewModel>().logout();

    if (mounted) {
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: AppColors.primary,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 32.0),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/loho_wh.png',
                      height: 24,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Text(
                        "Citymind STUDENT",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 40, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),

                    Text(
                      _userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),

                    Text(
                      " $_faculty ",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: Container(
              color: Colors.white,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Text(
                      l10n.history,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.language, color: Colors.grey),
                  title: Text(
                    l10n.language,
                    style: const TextStyle(fontSize: 14),
                  ),
                  trailing: Consumer<LocaleProvider>(
                    builder: (context, localeProvider, child) {
                      final isCs = localeProvider.locale.languageCode == 'cs';
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () {
                              localeProvider.setLocale(const Locale('cs'));
                              context.read<NewsViewModel>().loadNews('cs');
                            },
                            child: Text(
                              "CZ",
                              style: TextStyle(
                                fontWeight: isCs
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isCs ? AppColors.primary : Colors.grey,
                              ),
                            ),
                          ),
                          const Text(
                            " / ",
                            style: TextStyle(color: Colors.grey),
                          ),

                          InkWell(
                            onTap: () {
                              localeProvider.setLocale(const Locale('en'));
                              context.read<NewsViewModel>().loadNews('en');
                            },
                            child: Text(
                              "EN",
                              style: TextStyle(
                                fontWeight: !isCs
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: !isCs ? AppColors.primary : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _logout,
                    style: ElevatedButton.styleFrom(
                      splashFactory: NoSplash.splashFactory,
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text(
                      l10n.logout,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(String title) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
      ),
      visualDensity: VisualDensity.compact,
      onTap: () {},
    );
  }
}
