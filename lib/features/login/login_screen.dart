import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:idempiere_sales_app/core/app_config.dart';
import 'package:idempiere_sales_app/core/app_strings.dart';
import 'package:idempiere_sales_app/core/theme.dart';
import 'package:idempiere_sales_app/features/auth/auth_session.dart';
import 'package:idempiere_sales_app/features/login/select_role_screen.dart';
import 'package:idempiere_sales_app/features/login/widgets/login_card.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;
  bool _initialized = false;
  String? _rememberedEmail;
  String? _rememberedServer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final AuthSession auth = context.read<AuthSession>();
    _rememberedEmail = auth.rememberedEmail;
    _rememberedServer = auth.baseUrl;
    _initialized = true;
  }

  void _showError(String message) {
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

  Future<void> _handleSubmit({
    required String email,
    required String password,
    required String serverUrl,
    required bool rememberMe,
  }) async {
    setState(() => _loading = true);
    final AuthSession auth = context.read<AuthSession>();

    try {
      await auth.login(
        baseUrl: serverUrl,
        userName: email,
        password: password,
      );
      if (!mounted) return;
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
    } on SocketException {
      if (mounted) _showError(AppStrings.networkError);
    } on TimeoutException {
      if (mounted) _showError(AppStrings.networkError);
    } catch (_) {
      if (mounted) _showError(AppStrings.invalidCredentials);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _handleForgotPassword() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text(AppStrings.forgotPasswordHelp),
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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool isWide =
              constraints.maxWidth >= AppBreakpoints.tablet;
          return isWide
              ? _buildWideLayout(constraints)
              : _buildCompactLayout(constraints);
        },
      ),
    );
  }

  Widget _buildCompactLayout(BoxConstraints constraints) {
    return _buildScreen(
      image: 'assets/images/mobile_bg.jpg',
      showBottomGradient: true,
    );
  }

  Widget _buildWideLayout(BoxConstraints constraints) {
    return _buildScreen(
      image: 'assets/images/tablet_bg.jpg',
      showBottomGradient: false,
    );
  }

  Widget _buildScreen({required String image, required bool showBottomGradient}) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          image,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              Container(color: AppColors.backdropTop),
        ),
        if (showBottomGradient)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 300,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: LoginCard(
                onSubmit: _handleSubmit,
                onForgotPassword: _handleForgotPassword,
                loading: _loading,
                initialEmail: _rememberedEmail,
                initialServerUrl: _rememberedServer,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
