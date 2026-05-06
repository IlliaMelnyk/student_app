import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_app/features/auth/presentation/pages/registration_flow_screen.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../main.dart';
import '../../../../theme/app_colors.dart';
import '../viewmodels/login_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  InputDecoration _buildInputDecoration({
    required String labelText,
    required bool hasError,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      filled: true,
      fillColor: hasError
          ? Colors.red.withOpacity(0.05)
          : Colors.grey.withOpacity(0.1),
      labelStyle: TextStyle(color: hasError ? Colors.red : Colors.grey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: hasError ? Colors.red : Colors.transparent,
          width: 1.5,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: hasError ? Colors.red : Colors.transparent,
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: hasError ? Colors.red : AppColors.primary,
          width: 2.0,
        ),
      ),
      suffixIcon: suffixIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final viewModel = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo_white.png',
                      height: 40,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.broken_image,
                          color: Colors.white,
                          size: 40,
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.loginWelcomeText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              flex: 6,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                  top: 24,
                  left: 24,
                  right: 24,
                  bottom: 16,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Text(
                          l10n.loginTitle,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textOnWhite,
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 32),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (viewModel.errorMessage != null) ...[
                              Text(
                                viewModel.errorMessage!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: _buildInputDecoration(
                                labelText: l10n.email,
                                hasError:
                                    viewModel.errorMessage != null &&
                                    _emailController.text.isEmpty,
                              ),
                            ),
                            const SizedBox(height: 16),

                            TextField(
                              controller: _passwordController,
                              obscureText: !viewModel.isPasswordVisible,
                              decoration: _buildInputDecoration(
                                labelText: l10n.password,
                                hasError:
                                    viewModel.errorMessage != null &&
                                    _passwordController.text.isEmpty,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    viewModel.isPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () =>
                                      viewModel.togglePasswordVisibility(),
                                ),
                              ),
                            ),

                            // ZAKOMENTOVANÉ ZAPOMENUTÉ HESLO
                            /*
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  print("Forgot password tapped");
                                },
                                child: Text(
                                  l10n.forgotPassword,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            */
                            const SizedBox(height: 48),

                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "${l10n.noAccount} ",
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const RegistrationFlowScreen(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        l10n.register,
                                        style: const TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                SizedBox(
                                  width: double.infinity,
                                  height: 54,
                                  child: ElevatedButton(
                                    onPressed:
                                        viewModel.state == AuthState.loading
                                        ? null
                                        : () async {
                                            final email = _emailController.text
                                                .trim();
                                            final password = _passwordController
                                                .text
                                                .trim();

                                            // Skrytí klávesnice po kliknutí na tlačítko (dobrá praxe)
                                            FocusScope.of(context).unfocus();

                                            final success = await viewModel
                                                .login(
                                                  email: email,
                                                  password: password,
                                                  emptyFieldsText: l10n
                                                      .loginGeneralErrorMessage,
                                                  serverErrorText:
                                                      l10n.communicationError,
                                                );

                                            if (success && mounted) {
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const MainScreen(),
                                                ),
                                              );
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                    ),
                                    child: viewModel.state == AuthState.loading
                                        ? const CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                        : Text(
                                            l10n.continueButton,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const MainScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    l10n.continueAsGuest,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
