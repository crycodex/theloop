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
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: LoopColors.surfaceElevated,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: const TextStyle(
          color: LoopColors.textMuted,
          fontWeight: FontWeight.w400,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: LoopColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: LoopColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(
            color: LoopColors.onboardingGreen,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: LoopColors.accentGreen,
      brightness: Brightness.dark,
      primary: LoopColors.accentGreen,
      secondary: LoopColors.accentGreen,
      surface: LoopColors.surfaceBlack,
      error: LoopColors.danger,
    );

    const textPrimary = Colors.white;
    const textMuted = Color(0xFFB9C2B0);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: LoopColors.surfaceBlack,
      fontFamily: 'Inter',
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          fontSize: 34,
          height: 1.05,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.1,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          height: 1.1,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.8,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          height: 1.15,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 17,
          height: 1.25,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          height: 1.45,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.35,
          fontWeight: FontWeight.w500,
          color: textMuted,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          height: 1.2,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xFF151B12),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: LoopColors.accentGreen,
          foregroundColor: LoopColors.brandGreen,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF151B12),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: const TextStyle(
          color: textMuted,
          fontWeight: FontWeight.w400,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: Color(0xFF3D4736)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: Color(0xFF3D4736)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(
            color: LoopColors.accentGreen,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
