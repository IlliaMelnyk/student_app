import 'package:flutter/material.dart';
import 'package:student_app/features/news/presentation/pages/news_screen.dart';
import 'features/chatbot/presentation/pages/chat_screen.dart';
import 'features/reports/presentation/pages/reports_screen.dart';
import 'injection_container.dart';
import 'theme/app_colors.dart';
import 'l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'features/auth/presentation/pages/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final providers = await initDependencies();
  runApp(MultiProvider(providers: providers, child: const StudentApp()));
}

class StudentApp extends StatelessWidget {
  const StudentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student App',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
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
  int _currentIndex = 1;

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
        onTap: (index) => setState(() => _currentIndex = index),
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
