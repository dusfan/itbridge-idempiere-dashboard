import 'package:flutter/material.dart';

abstract final class AppColors {
  static const canvas = Color(0xFFF8FAFC);
  static const surface = Colors.white;
  static const ink = Color(0xFF111827);
  static const mutedInk = Color(0xFF64748B);
  static const line = Color(0xFFE8EDF3);
  static const blue = Color(0xFF1465DF);
  static const blueSoft = Color(0xFFEAF2FF);
  static const green = Color(0xFF14A34A);
  static const greenSoft = Color(0xFFEAF8EF);
  static const red = Color(0xFFEB3F38);
  static const redSoft = Color(0xFFFFEEEE);
}

abstract final class AppTheme {
  static ThemeData get light {
    const textTheme = TextTheme(
      headlineMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
        letterSpacing: -0.45,
      ),
      titleMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
      bodyMedium: TextStyle(
        fontSize: 13,
        color: AppColors.mutedInk,
      ),
      labelMedium: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.mutedInk,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.canvas,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.blue,
        brightness: Brightness.light,
        surface: AppColors.surface,
      ),
      textTheme: textTheme,
      dividerColor: AppColors.line,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
    );
  }
}
