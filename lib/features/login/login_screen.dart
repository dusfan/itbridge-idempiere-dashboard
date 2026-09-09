import 'package:flutter/material.dart';
import 'package:idempiere_sales_app/core/app_config.dart';
import 'package:idempiere_sales_app/core/theme.dart';
import 'package:idempiere_sales_app/features/auth/auth_session.dart';
import 'package:idempiere_sales_app/features/login/login_controller.dart';
import 'package:idempiere_sales_app/features/login/login_mobile_screen.dart';
import 'package:idempiere_sales_app/features/login/login_tablet_screen.dart';
import 'package:idempiere_sales_app/features/login/select_role_screen.dart';
import 'package:idempiere_sales_app/features/login/widgets/login_card.dart';
import 'package:provider/provider.dart';

/// Chooses a device-specific login design and connects it to [LoginController].
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LoginController(context.read<AuthSession>()),
      child: const _LoginCoordinator(),
    );
  }
}

class _LoginCoordinator extends StatelessWidget {
  const _LoginCoordinator();

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.field),
          ),
        ),
      );
  }

  Future<void> _submit(
    BuildContext context, {
    required String email,
    required String password,
    required String serverUrl,
    required bool rememberMe,
  }) async {
    final result = await context.read<LoginController>().submit(
      email: email,
      password: password,
      serverUrl: serverUrl,
    );
    if (!context.mounted) return;
    if (!result.succeeded) {
      _showError(context, result.errorMessage!);
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SelectRoleScreen(
          baseUrl: serverUrl,
          userName: email,
          password: password,
          language: AppConfig.sessionLanguage,
          rememberMe: rememberMe,
        ),
      ),
    );
  }

  void _forgotPassword(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text(
            'Contact your administrator to reset your password.',
          ),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.field),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginController>(
      builder: (context, controller, _) {
        final card = LoginCard(
          loading: controller.isLoading,
          initialEmail: controller.initialEmail,
          initialServerUrl: controller.initialServerUrl,
          onSubmit:
              ({
                required email,
                required password,
                required serverUrl,
                required rememberMe,
              }) => _submit(
                context,
                email: email,
                password: password,
                serverUrl: serverUrl,
                rememberMe: rememberMe,
              ),
          onForgotPassword: () => _forgotPassword(context),
        );
        return LayoutBuilder(
          builder: (context, constraints) =>
              constraints.maxWidth >= AppBreakpoints.tablet
              ? LoginTabletScreen(loginCard: card)
              : LoginMobileScreen(loginCard: card),
        );
      },
    );
  }
}
