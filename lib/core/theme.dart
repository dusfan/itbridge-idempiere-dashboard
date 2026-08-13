import 'package:flutter/material.dart';

/// Navy gradient background, white rounded cards/inputs, solid navy pill
/// buttons.
class AppColors {
  static const navy = Color(0xFF1D3557);
  static const navyDark = Color(0xFF14283D);
  static const skyTop = Color(0xFFDCEEF9);
  static const skyBottom = Color(0xFFAED4E8);
  static const label = Color(0xFF6B7A8F);

  static const backgroundGradient = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [skyTop, skyBottom],
    ),
  );
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.navy),
    scaffoldBackgroundColor: AppColors.skyTop,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: AppColors.navy,
    ),
  );
}
