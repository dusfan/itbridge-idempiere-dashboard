import 'package:dashboard_app/dashboard_app.dart' as dashboard;
import 'package:flutter/material.dart';
import 'package:idempiere_sales_app/features/auth/auth_session.dart';
import 'package:idempiere_sales_app/features/login/login_screen.dart';
import 'package:idempiere_sales_app/features/orders/orders_screen.dart';
import 'package:provider/provider.dart';

/// App integration point for the dashboard feature package.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _logout(BuildContext context) {
    context.read<AuthSession>().logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _openOrders(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const OrdersScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: dashboard.AppTheme.light,
      child: dashboard.DashboardPage(
        onLogout: () => _logout(context),
        onOpenOrders: () => _openOrders(context),
      ),
    );
  }
}
