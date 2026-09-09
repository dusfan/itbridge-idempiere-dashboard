import 'package:flutter/material.dart';

/// Design tokens for the Executive Dashboard design system.
///
/// Taken from the approved mockups: white cards on a light canvas, a vivid
/// blue primary, and slate text. Screens pull from here instead of
/// hard-coding colors, so a palette change is a one-file change.
class AppColors {
  // Brand
  static const primary = Color(0xFF2563EB);
  static const primaryDark = Color(0xFF1D4ED8);
  static const primaryTint = Color(0xFFEFF4FF);

  // Surfaces
  static const background = Color(0xFFF5F7FA);
  static const surface = Color(0xFFFFFFFF);
  static const fieldFill = Color(0xFFF7F9FC);
  static const border = Color(0xFFE3E8EF);

  // Text
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const textTertiary = Color(0xFF9CA3AF);
  static const onPrimary = Color(0xFFFFFFFF);

  // Status (dashboard deltas, Paye / Non paye chips)
  static const success = Color(0xFF16A34A);
  static const danger = Color(0xFFDC2626);
  static const warning = Color(0xFFF59E0B);

  /// Login backdrop. A coded stand-in for the photograph so the screen ships
  /// before the asset is licensed; see [AuthBackground] for the swap point.
  static const backdropTop = Color(0xFF0A1F3D);
  static const backdropMid = Color(0xFF14468A);
  static const backdropBottom = Color(0xFF3B82D6);

  // --- Legacy aliases -------------------------------------------------
  // The orders screens still reference the original navy palette. These keep
  // them compiling and roughly on-palette until they are re-skinned.
  static const navy = primary;
  static const skyTop = background;
  static const label = textSecondary;

  static const backgroundGradient = BoxDecoration(color: background);
}

/// Corner radii. Cards are softer than controls, matching the mockups.
class AppRadius {
  static const card = 16.0;
  static const field = 10.0;
  static const button = 10.0;
  static const sheet = 28.0;
}

/// Elevation is expressed as shadow tokens rather than Material elevation so
/// cards look identical across platforms.
class AppShadows {
  static const card = <BoxShadow>[
    BoxShadow(color: Color(0x14101828), blurRadius: 16, offset: Offset(0, 4)),
  ];

  static const lifted = <BoxShadow>[
    BoxShadow(color: Color(0x1F101828), blurRadius: 32, offset: Offset(0, 12)),
  ];
}

/// Layout breakpoint between the phone layout (card pinned to the bottom)
/// and the tablet/desktop layout (card centered over the backdrop).
class AppBreakpoints {
  static const tablet = 600.0;
}

ThemeData buildAppTheme() {
  // NOTE: Inter is the mockup typeface. Bundling it means dropping the TTFs
  // into assets/fonts/ and declaring them in pubspec.yaml -- deliberately not
  // done via google_fonts, which fetches at runtime and fails offline.
  const scheme = ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    error: AppColors.danger,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: AppColors.textPrimary,
      surfaceTintColor: Colors.transparent,
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.2,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      bodyMedium: TextStyle(fontSize: 14, color: AppColors.textPrimary),
      labelMedium: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 1,
    ),
  );
}
