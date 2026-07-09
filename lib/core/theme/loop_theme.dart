import 'package:flutter/material.dart';

import 'loop_colors.dart';

abstract final class LoopTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: LoopColors.brandGreen,
      primary: LoopColors.brandGreen,
      secondary: LoopColors.accentGreen,
      surface: LoopColors.surface,
      error: LoopColors.danger,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: LoopColors.surface,
      fontFamily: 'Inter',
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          fontSize: 34,
          height: 1.05,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.1,
          color: LoopColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          height: 1.1,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.8,
          color: LoopColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          height: 1.15,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
          color: LoopColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 17,
          height: 1.25,
          fontWeight: FontWeight.w700,
          color: LoopColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          height: 1.45,
          fontWeight: FontWeight.w500,
          color: LoopColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.35,
          fontWeight: FontWeight.w500,
          color: LoopColors.textMuted,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          height: 1.2,
          fontWeight: FontWeight.w700,
          color: LoopColors.textPrimary,
        ),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: LoopColors.textPrimary,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: LoopColors.surfaceElevated,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: LoopColors.brandGreen,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
