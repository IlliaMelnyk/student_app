import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_app/features/auth/presentation/pages/welcome_screen.dart';
import '../../../../main.dart';
import '../viewmodels/login_viewmodel.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthViewModel>().checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthViewModel>();

    if (viewModel.isCheckingAuth) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (viewModel.isAuthenticated) {
      return const MainScreen();
    }

    return const WelcomeScreen();
  }
}
