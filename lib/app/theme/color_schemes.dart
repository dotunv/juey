import 'package:flutter/material.dart';

class AppColors {
  static const lightColorScheme = ColorScheme.light(
    primary: Color(0xFFFFCB47),
    primaryContainer: Color(0xFFFFE49B),
    secondary: Color(0xFF2B2B2B),
    secondaryContainer: Color(0xFFEDEDED),
    surface: Color(0xFFFFFFFF),
    background: Color(0xFFF7F7F7),
    error: Color(0xFFE53935),
    onPrimary: Color(0xFF0E0E0E),
    onSecondary: Color(0xFF0E0E0E),
    onSurface: Color(0xFF1A1A1A),
    onBackground: Color(0xFF1A1A1A),
    onError: Color(0xFFFFFFFF),
    brightness: Brightness.light,
  );

  static const darkColorScheme = ColorScheme.dark(
    primary: Color(0xFFFFCB47),
    primaryContainer: Color(0xFF2B2B2B),
    secondary: Color(0xFF2B2B2B),
    secondaryContainer: Color(0xFF1A1A1A),
    surface: Color(0xFF1A1A1A),
    background: Color(0xFF0E0E0E),
    error: Color(0xFFEF5350),
    onPrimary: Color(0xFF0E0E0E),
    onSecondary: Color(0xFFEDEDED),
    onSurface: Color(0xFFEDEDED),
    onBackground: Color(0xFFEDEDED),
    onError: Color(0xFF0E0E0E),
    brightness: Brightness.dark,
  );

  static Color get success => const Color(0xFF22C55E);
  static Color get warning => const Color(0xFFF59E42);
  static Color get info => const Color(0xFF38BDF8);
  static const Color textPrimary = Color(0xFFEDEDED);
  static const Color textSecondary = Color(0xFF9C9C9C);
}
