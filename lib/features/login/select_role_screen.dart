import 'package:flutter/material.dart';
import 'package:idempiere_rest/idempiere_rest.dart';
import 'package:idempiere_sales_app/core/theme.dart';
import 'package:idempiere_sales_app/features/auth/auth_session.dart';
import 'package:idempiere_sales_app/features/dashboard/dashboard_screen.dart';
import 'package:idempiere_sales_app/widgets/primary_button.dart';
import 'package:provider/provider.dart';

class SelectRoleScreen extends StatefulWidget {
  const SelectRoleScreen({
    required this.baseUrl,
    required this.userName,
    required this.password,
    required this.language,
    required this.rememberMe,
    super.key,
  });

  final String baseUrl;
  final String userName;
  final String password;
  final String language;
  final bool rememberMe;

  @override
  State<SelectRoleScreen> createState() => _SelectRoleScreenState();
}

class _SelectRoleScreenState extends State<SelectRoleScreen> {
  int? _clientId;

  List<Role> _roles = [];
  Role? _selectedRole;

  List<Organization> _orgs = [];
  Organization? _selectedOrg;

  List<Warehouse> _warehouses = [];
  Warehouse? _selectedWarehouse;

  bool _loadingRoles = true;
  bool _loadingOrgs = false;
  bool _loadingWarehouses = false;
  bool _entering = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRoles();
  }

  Future<void> _loadRoles() async {
    final auth = context.read<AuthSession>();
    final clientId = auth.loginResponse?.clients.first.id;

    if (clientId == null) {
      setState(() {
        _error = 'No client available for this user.';
        _loadingRoles = false;
      });
      return;
    }

    _clientId = clientId;

    try {
      final roles = await auth.getRoles(clientId);
      if (!mounted) return;
      setState(() {
        _roles = roles;
        _loadingRoles = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load roles.';
        _loadingRoles = false;
      });
    }
  }

  Future<void> _onRoleSelected(Role? role) async {
    if (role == null || _clientId == null) return;
    setState(() {
      _selectedRole = role;
      _orgs = [];
      _selectedOrg = null;
      _warehouses = [];
      _selectedWarehouse = null;
      _loadingOrgs = true;
      _error = null;
    });

    final auth = context.read<AuthSession>();
    try {
      final orgs = await auth.getOrganizations(_clientId!, role.id!);
      if (!mounted) return;
      setState(() {
        _orgs = orgs;
        _loadingOrgs = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load organizations.';
        _loadingOrgs = false;
      });
    }
  }

  Future<void> _onOrgSelected(Organization? org) async {
    if (org == null || _clientId == null || _selectedRole == null) return;
    setState(() {
      _selectedOrg = org;
      _warehouses = [];
      _selectedWarehouse = null;
      _loadingWarehouses = true;
      _error = null;
    });

    final auth = context.read<AuthSession>();
    try {
      final warehouses = await auth.getWarehouses(
        _clientId!,
        _selectedRole!.id!,
        org.id!,
      );
      if (!mounted) return;
      setState(() {
        _warehouses = warehouses;
        _loadingWarehouses = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load warehouses.';
        _loadingWarehouses = false;
      });
    }
  }

  Future<void> _enter() async {
    if (_clientId == null || _selectedRole == null || _selectedOrg == null) {
      setState(() => _error = 'Please select a role and organization.');
      return;
    }

    setState(() {
      _entering = true;
      _error = null;
    });

    final auth = context.read<AuthSession>();
    try {
      await auth.oneStepLogin(
        baseUrl: widget.baseUrl,
        userName: widget.userName,
        password: widget.password,
        clientId: _clientId!,
        roleId: _selectedRole!.id!,
        organizationId: _selectedOrg!.id,
        warehouseId: _selectedWarehouse?.id,
        language: widget.language,
      );
      if (widget.rememberMe) {
        await auth.rememberLogin(
          baseUrl: widget.baseUrl,
          email: widget.userName,
        );
      }
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
        (route) => false,
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _entering = false);
    }
  }

  Widget _dropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) itemLabel,
    required ValueChanged<T?> onChanged,
    bool loading = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.label,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: loading
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : DropdownButtonHideUnderline(
                  child: DropdownButton<T>(
                    value: value,
                    isExpanded: true,
                    hint: const Text('Select...'),
                    items: items
                        .map(
                          (item) => DropdownMenuItem<T>(
                            value: item,
                            child: Text(itemLabel(item)),
                          ),
                        )
                        .toList(),
                    onChanged: items.isEmpty ? null : onChanged,
                  ),
                ),
        ),
        const SizedBox(height: 14),
      ],
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
                const Text(
                  'Select Role',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 24),
                _dropdown<Role>(
                  label: 'Role',
                  value: _selectedRole,
                  items: _roles,
                  itemLabel: (r) => r.name,
                  onChanged: _onRoleSelected,
                  loading: _loadingRoles,
                ),
                _dropdown<Organization>(
                  label: 'Organization',
                  value: _selectedOrg,
                  items: _orgs,
                  itemLabel: (o) => o.name,
                  onChanged: _onOrgSelected,
                  loading: _loadingOrgs,
                ),
                _dropdown<Warehouse>(
                  label: 'Warehouse (optional)',
                  value: _selectedWarehouse,
                  items: _warehouses,
                  itemLabel: (w) => w.name,
                  onChanged: (w) => setState(() => _selectedWarehouse = w),
                  loading: _loadingWarehouses,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 4),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 4),
                ],
                const SizedBox(height: 20),
                PrimaryButton(
                  label: 'ENTER',
                  onPressed: _enter,
                  loading: _entering,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
