import 'package:flutter/material.dart';
import 'package:student_app/features/auth/presentation/pages/login_screen.dart';
import 'package:student_app/features/auth/presentation/viewmodels/login_viewmodel.dart';
import 'package:student_app/features/news/presentation/pages/news_screen.dart';
import 'features/chatbot/presentation/pages/chat_screen.dart';
import 'features/reports/presentation/pages/reports_screen.dart';
import 'injection_container.dart';
import 'theme/app_colors.dart';
import 'l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'features/auth/presentation/pages/auth_wrapper.dart';
import 'core/provider/locale_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final providers = await initDependencies();
  providers.add(ChangeNotifierProvider(create: (_) => LocaleProvider()));
  runApp(MultiProvider(providers: providers, child: const StudentApp()));
}

class StudentApp extends StatelessWidget {
  const StudentApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    return MaterialApp(
      title: 'Student App',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      locale: localeProvider.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: const AuthWrapper(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  void _showLoginPrompt(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.loginRequiredTitle),
          content: Text(l10n.loginRequiredMessage),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                l10n.cancel,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                l10n.loginAction,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final List<Widget> screens = [
      const NewsScreen(),
      const ChatScreen(),
      const ReportsScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.navbarBackground,
        selectedItemColor: AppColors.white,
        unselectedItemColor: AppColors.navbarIconUnselected,
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        onTap: (index) {
          final isAuthenticated = context.read<AuthViewModel>().isAuthenticated;

          if (!isAuthenticated && (index == 1 || index == 2)) {
            _showLoginPrompt(context);
          } else {
            setState(() => _currentIndex = index);
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_today_outlined),
            activeIcon: const Icon(Icons.calendar_today),
            label: l10n.news,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.smart_toy_outlined),
            activeIcon: const Icon(Icons.smart_toy),
            label: l10n.aiAgent,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.history),
            label: l10n.reports,
          ),
        ],
      ),
    );
  }
}
