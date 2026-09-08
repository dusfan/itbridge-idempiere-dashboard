import 'package:flutter/material.dart';
import 'package:idempiere_sales_app/core/theme.dart';
import 'package:idempiere_sales_app/features/auth/auth_session.dart';
import 'package:idempiere_sales_app/features/login/login_screen.dart';
import 'package:idempiere_sales_app/features/orders/orders_screen.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final AuthSession auth = context.read<AuthSession>();
    await auth.loadRemembered();
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) =>
            auth.isLoggedIn ? const OrdersScreen() : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/mobile_bg.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                Container(color: AppColors.backdropTop),
          ),
          const Center(
            child: SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
