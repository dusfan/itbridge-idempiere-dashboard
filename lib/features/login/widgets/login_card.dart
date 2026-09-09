import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:idempiere_sales_app/core/app_config.dart';
import 'package:idempiere_sales_app/core/app_strings.dart';
import 'package:idempiere_sales_app/widgets/app_text_field.dart';
import 'package:idempiere_sales_app/widgets/primary_button.dart';

typedef LoginSubmit =
    void Function({
      required String email,
      required String password,
      required String serverUrl,
      required bool rememberMe,
    });

class LoginCard extends StatefulWidget {
  final LoginSubmit onSubmit;
  final VoidCallback onForgotPassword;
  final bool loading;
  final String? initialEmail;
  final String? initialServerUrl;
  final BorderRadius borderRadius;
  final double extraBottomPadding;

  const LoginCard({
    required this.onSubmit,
    required this.onForgotPassword,
    super.key,
    this.loading = false,
    this.initialEmail,
    this.initialServerUrl,
    this.borderRadius = const BorderRadius.all(Radius.circular(24.0)),
    this.extraBottomPadding = 0,
  });

  @override
  State<LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<LoginCard> {
  late final TextEditingController _emailController = TextEditingController(
    text: widget.initialEmail ?? '',
  );
  late final TextEditingController _serverController = TextEditingController(
    text: widget.initialServerUrl ?? AppConfig.defaultBaseUrl,
  );
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocus = FocusNode();

  bool _rememberMe = true;
  bool _showAdvanced = false;
  String? _emailError;
  String? _passwordError;
  String? _serverError;

  static final RegExp _emailPattern = RegExp(
    r'^[\w.+-]+\s*@\s*[\w-]+\.[\w.-]+$',
  );

  @override
  void dispose() {
    _emailController.dispose();
    _serverController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  String? _validateEmail(String value) {
    if (value.isEmpty) return AppStrings.emailRequired;
    if (!_emailPattern.hasMatch(value)) return AppStrings.emailInvalid;
    return null;
  }

  String? _validateServer(String value) {
    if (value.isEmpty) return AppStrings.serverRequired;
    final Uri? uri = Uri.tryParse(value);
    if (uri == null || (!uri.isScheme('http') && !uri.isScheme('https'))) {
      return AppStrings.serverInvalid;
    }
    return null;
  }

  void _submit() {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;
    final String serverUrl = _serverController.text.trim();

    final String? emailError = _validateEmail(email);
    final String? passwordError = password.isEmpty
        ? AppStrings.passwordRequired
        : null;
    final String? serverError = _validateServer(serverUrl);

    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
      _serverError = serverError;
      if (serverError != null) _showAdvanced = true;
    });

    if (emailError != null || passwordError != null || serverError != null) {
      return;
    }

    FocusScope.of(context).unfocus();
    widget.onSubmit(
      email: email,
      password: password,
      serverUrl: serverUrl,
      rememberMe: _rememberMe,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: widget.borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: widget.borderRadius,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.50),
                width: 1.5,
              ),
            ),
            padding: EdgeInsets.fromLTRB(
              28,
              32,
              28,
              28 + widget.extraBottomPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  AppStrings.loginTitle,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Veuillez vous connecter à votre compte',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 24),
                AppTextField(
                  label: AppStrings.email,
                  controller: _emailController,
                  hintText: AppStrings.emailHint,
                  prefixIcon: Icons.person_outline,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  enabled: !widget.loading,
                  errorText: _emailError,
                  onSubmitted: (_) => _passwordFocus.requestFocus(),
                ),
                AppTextField(
                  label: AppStrings.password,
                  controller: _passwordController,
                  hintText: AppStrings.passwordHint,
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  focusNode: _passwordFocus,
                  textInputAction: TextInputAction.done,
                  enabled: !widget.loading,
                  errorText: _passwordError,
                  onSubmitted: (_) => _submit(),
                ),
                if (AppConfig.allowServerOverride) ...<Widget>[
                  _buildAdvancedSection(),
                  const SizedBox(height: 6),
                ],
                const SizedBox(height: 4),
                _buildRememberAndForgotRow(),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: AppStrings.signIn,
                  onPressed: widget.loading ? null : _submit,
                  loading: widget.loading,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF39C12), Color(0xFFE67E22)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF39C12).withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdvancedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _showAdvanced = !_showAdvanced),
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  AppStrings.advanced,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(width: 2),
                AnimatedRotation(
                  turns: _showAdvanced ? 0.5 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: _showAdvanced
              ? Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: AppTextField(
                    label: AppStrings.serverUrl,
                    controller: _serverController,
                    hintText: AppStrings.serverUrlHint,
                    prefixIcon: Icons.dns_outlined,
                    keyboardType: TextInputType.url,
                    enabled: !widget.loading,
                    errorText: _serverError,
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }

  Widget _buildRememberAndForgotRow() {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 8,
      spacing: 8,
      children: [
        InkWell(
          onTap: widget.loading
              ? null
              : () => setState(() => _rememberMe = !_rememberMe),
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  width: 20,
                  height: 20,
                  child: Checkbox(
                    value: _rememberMe,
                    onChanged: widget.loading
                        ? null
                        : (bool? v) => setState(() => _rememberMe = v ?? false),
                    activeColor: const Color(0xFFF39C12),
                    side: const BorderSide(
                      color: Color(0xFFCBD5E1),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  AppStrings.rememberMe,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF475569),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        TextButton(
          onPressed: widget.loading ? null : widget.onForgotPassword,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            AppStrings.forgotPassword,
            style: TextStyle(
              color: Color(0xFFD97706),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
