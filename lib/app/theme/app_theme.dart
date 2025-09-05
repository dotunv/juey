import 'package:flutter/material.dart';
import 'color_schemes.dart';
import 'text_theme.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final cs = AppColors.lightColorScheme;
    return ThemeData.from(
      colorScheme: cs,
      useMaterial3: true,
    ).copyWith(
      scaffoldBackgroundColor: cs.background,
      textTheme: AppTextTheme.lightTextTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        backgroundColor: cs.background,
        foregroundColor: cs.onBackground,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: cs.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        labelStyle: TextStyle(color: cs.onSurface.withOpacity(0.7)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
      cardTheme: CardTheme(
        color: cs.surface,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: EdgeInsets.zero,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: cs.primary,
        contentTextStyle: TextStyle(color: cs.onPrimary),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cs.surface,
        indicatorColor: cs.primary.withOpacity(0.15),
        labelTextStyle: WidgetStatePropertyAll(TextStyle(color: cs.onSurface)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cs.secondaryContainer,
        selectedColor: cs.primary.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        labelStyle: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w500),
      ),
    );
  }

  static ThemeData get darkTheme {
    final cs = AppColors.darkColorScheme;
    return ThemeData.from(
      colorScheme: cs,
      useMaterial3: true,
    ).copyWith(
      scaffoldBackgroundColor: cs.background,
      textTheme: AppTextTheme.darkTextTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        backgroundColor: cs.background,
        foregroundColor: cs.onBackground,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: cs.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        labelStyle: TextStyle(color: cs.onSurface.withOpacity(0.7)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
      cardTheme: CardTheme(
        color: cs.surface,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: EdgeInsets.zero,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: cs.primary,
        contentTextStyle: TextStyle(color: cs.onPrimary),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cs.surface,
        indicatorColor: cs.primary.withOpacity(0.2),
        labelTextStyle: WidgetStatePropertyAll(TextStyle(color: cs.onSurface)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cs.secondaryContainer,
        selectedColor: cs.primary.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        labelStyle: const TextStyle(color: AppColors.textPrimary),
      ),
    );
  }
}
