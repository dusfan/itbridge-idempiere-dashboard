import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth_session.dart';
import '../../core/theme.dart';
import '../login/login_screen.dart';
import '../orders/orders_screen.dart';

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
    final auth = context.read<AuthSession>();
    await auth.loadRemembered();
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => auth.isLoggedIn ? const OrdersScreen() : const LoginScreen(),
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
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppColors.navy.withValues(alpha: 0.15), blurRadius: 20, spreadRadius: 2),
                  ],
                ),
                child: const Icon(Icons.storefront_rounded, size: 56, color: AppColors.navy),
              ),
              const SizedBox(height: 18),
              const Text(
                'iDempiere Sales',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.navy, letterSpacing: 0.5),
              ),
              const SizedBox(height: 40),
              Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(2)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
