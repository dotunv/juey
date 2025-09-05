import 'package:flutter/material.dart';

class AppColors {
  // Brand palette
  static const accent = Color(0xFFFFCB47); // spark
  static const backgroundDark = Color(0xFF0E0E0E);
  static const surfaceDark = Color(0xFF1A1A1A);
  static const surfaceDark2 = Color(0xFF2B2B2B);
  static const textPrimaryDark = Color(0xFFEDEDED);
  static const textSecondaryDark = Color(0xFF9C9C9C);

  // Light Theme (kept minimal, accent-forward)
  static final lightColorScheme = ColorScheme.light(
    primary: accent,
    primaryContainer: const Color(0xFFFFE7A3),
    secondary: accent,
    secondaryContainer: const Color(0xFFFFF2CC),
    surface: Colors.white,
    background: Colors.white,
    error: const Color(0xFFE53935),
    onPrimary: Colors.black,
    onSecondary: Colors.black,
    onSurface: Colors.black,
    onBackground: Colors.black,
    onError: Colors.white,
    brightness: Brightness.light,
  );

  // Dark Theme (brand: dark grid + spark accent)
  static final darkColorScheme = const ColorScheme.dark(
    primary: accent,
    primaryContainer: surfaceDark2,
    secondary: accent,
    secondaryContainer: surfaceDark,
    surface: surfaceDark,
    background: backgroundDark,
    error: Color(0xFFEF5350),
    onPrimary: Colors.black,
    onSecondary: Colors.black,
    onSurface: textPrimaryDark,
    onBackground: textPrimaryDark,
    onError: Colors.black,
  );

  // Semantic aliases
  static Color get success => const Color(0xFF22C55E);
  static Color get warning => const Color(0xFFF59E42);
  static Color get info => const Color(0xFF38BDF8);
}
