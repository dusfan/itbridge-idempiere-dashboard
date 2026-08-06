import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../session/auth_session.dart';
import '../theme.dart';
import '../widgets/app_text_field.dart';
import '../widgets/primary_button.dart';
import 'orders_screen.dart';

/// Fires the real one-step login: `/auth/tokens` with
/// {userName, password, parameters:{clientId, roleId, organizationId?, warehouseId?, language?}}.
class SelectRoleScreen extends StatefulWidget {
  final String baseUrl;
  final String userName;
  final String password;
  final String language;
  final bool rememberMe;

  const SelectRoleScreen({
    super.key,
    required this.baseUrl,
    required this.userName,
    required this.password,
    required this.language,
    required this.rememberMe,
  });

  @override
  State<SelectRoleScreen> createState() => _SelectRoleScreenState();
}

class _SelectRoleScreenState extends State<SelectRoleScreen> {
  final _clientController = TextEditingController();
  final _roleController = TextEditingController();
  final _orgController = TextEditingController();
  final _warehouseController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _clientController.dispose();
    _roleController.dispose();
    _orgController.dispose();
    _warehouseController.dispose();
    super.dispose();
  }

  Future<void> _enter() async {
    final clientId = int.tryParse(_clientController.text.trim());
    final roleId = int.tryParse(_roleController.text.trim());
    final orgId = int.tryParse(_orgController.text.trim());
    final warehouseText = _warehouseController.text.trim();
    final warehouseId = warehouseText.isEmpty ? null : int.tryParse(warehouseText);

    if (clientId == null || roleId == null || orgId == null) {
      setState(() => _error = 'Tenant, Role and Default Org must be numbers.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final auth = context.read<AuthSession>();
    try {
      await auth.oneStepLogin(
        baseUrl: widget.baseUrl,
        userName: widget.userName,
        password: widget.password,
        clientId: clientId,
        roleId: roleId,
        organizationId: orgId,
        warehouseId: warehouseId,
        language: widget.language,
      );
      if (widget.rememberMe) {
        await auth.rememberLogin(baseUrl: widget.baseUrl, email: widget.userName);
      }
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const OrdersScreen()),
        (route) => false,
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
                const Text('Select Role', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.navy)),
                const SizedBox(height: 24),
                AppTextField(label: 'Tenant', controller: _clientController, keyboardType: TextInputType.number, hintText: 'Client ID'),
                AppTextField(label: 'Role', controller: _roleController, keyboardType: TextInputType.number, hintText: 'Role ID'),
                AppTextField(label: 'Defaults Org', controller: _orgController, keyboardType: TextInputType.number, hintText: 'Organization ID'),
                AppTextField(
                  label: 'Warehouse (optional)',
                  controller: _warehouseController,
                  keyboardType: TextInputType.number,
                  hintText: 'Warehouse ID',
                ),
                if (_error != null) ...[
                  const SizedBox(height: 4),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 4),
                ],
                const SizedBox(height: 20),
                PrimaryButton(label: 'ENTER', onPressed: _enter, loading: _loading),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
