import 'package:flutter/material.dart';
import 'package:idempiere_sales_app/core/theme.dart';

/// Tablet and desktop login presentation, kept separate from the phone design.
class LoginTabletScreen extends StatelessWidget {
  const LoginTabletScreen({required this.loginCard, super.key});

  final Widget loginCard;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/tablet_bg.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(color: AppColors.backdropTop),
          ),
          Align(
            alignment: Alignment.center,
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
