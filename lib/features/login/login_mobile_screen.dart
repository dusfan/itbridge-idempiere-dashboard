import 'package:flutter/material.dart';
import 'package:idempiere_sales_app/core/theme.dart';

/// Phone-specific login presentation. It deliberately contains no auth logic.
class LoginMobileScreen extends StatelessWidget {
  const LoginMobileScreen({required this.loginCard, super.key});

  final Widget loginCard;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/mobile_bg.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(color: AppColors.backdropTop),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 300,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.black.withValues(alpha: 0.3),
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
                child: loginCard,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
