import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../session/auth_session.dart';
import '../theme.dart';
import '../widgets/app_text_field.dart';
import '../widgets/primary_button.dart';
import 'select_role_screen.dart';

/// Gathers credentials + server + language, then hands off to
/// [SelectRoleScreen] which fires the actual one-step login call once the
/// tenant/role/org are known too.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _serverController = TextEditingController(text: 'https://test.idempiere.org/api/v1');
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _language = 'en_US';
  bool _rememberMe = true;
  bool _initialized = false;

  static const _languages = ['en_US', 'es_ES', 'pt_BR'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final auth = context.read<AuthSession>();
      if (auth.baseUrl != null) _serverController.text = auth.baseUrl!;
      if (auth.rememberedEmail != null) _emailController.text = auth.rememberedEmail!;
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _serverController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _continue() {
    final serverUrl = _serverController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (serverUrl.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Server URL, email and password are required.')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SelectRoleScreen(
          baseUrl: serverUrl,
          userName: email,
          password: password,
          language: _language,
          rememberMe: _rememberMe,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppColors.backgroundGradient,
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text('Login', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.navy)),
                const SizedBox(height: 24),
                AppTextField(
                  label: 'Server URL',
                  controller: _serverController,
                  hintText: 'http://host:port/api/v1',
                ),
                AppTextField(
                  label: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                AppTextField(
                  label: 'Password',
                  controller: _passwordController,
                  obscureText: true,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Language', style: TextStyle(fontSize: 12, color: AppColors.label, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _language,
                          isExpanded: true,
                          items: _languages.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                          onChanged: (v) => setState(() => _language = v ?? _language),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
                CheckboxListTile(
                  value: _rememberMe,
                  onChanged: (v) => setState(() => _rememberMe = v ?? true),
                  title: const Text('Remember me'),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
                const SizedBox(height: 24),
                PrimaryButton(label: 'LOGIN', onPressed: _continue),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Contact your iDempiere administrator to reset your password.')),
                      );
                    },
                    child: const Text(
                      'FORGOT MY PASSWORD',
                      style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
