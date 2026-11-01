import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background = Color(0xFF0E1014);
  static const surface = Color(0xFF1C1F25);
  static const surfaceHigh = Color(0xFF262A31);
  static const text = Color(0xFFECECEC);
  static const muted = Color(0xFF8C919A);
  static const gold = Color(0xFFF0A93B);
  static const goldDeep = Color(0xFFE8922A);
  static const green = Color(0xFF3CCB9A);
  static const greenDeep = Color(0xFF2E8B6C);
  static const amber = Color(0xFFA67C1E);
  static const red = Color(0xFF8A2E2E);
  static const stop = Color(0xFFE5484D);
}

ThemeData buildTheme() {
  // The variable font defaults to its Light master, so set Regular explicitly.
  final regular = TextStyle(fontVariations: [FontVariation('wght', 400)]);
  return ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'SpaceGrotesk',
    textTheme: TextTheme(
      bodyLarge: regular,
      bodyMedium: regular,
      bodySmall: regular,
      titleMedium: regular,
      titleLarge: regular,
      labelLarge: regular,
    ),
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.gold,
      secondaryContainer: AppColors.surfaceHigh,
      onSecondaryContainer: AppColors.text,
      surface: AppColors.surface,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.text,
      centerTitle: false,
      elevation: 0,
    ),
  );
}

/// The bundled font is variable, so weight is set through its axis.
TextStyle weighted(TextStyle style, double weight) =>
    style.copyWith(fontVariations: [FontVariation('wght', weight)]);
