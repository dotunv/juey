import 'package:flutter/material.dart';
import 'color_schemes.dart';

class AppTextTheme {
  static TextTheme get lightTextTheme {
    return const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontSize: 16, height: 1.5),
      bodyMedium: TextStyle(fontSize: 14, height: 1.5),
      labelSmall: TextStyle(fontSize: 12, letterSpacing: 0.2),
    );
  }

  static TextTheme get darkTextTheme {
    return lightTextTheme.apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
      decorationColor: AppColors.textSecondary,
    ).copyWith(
      bodyMedium: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.textSecondary),
    );
  }
}
