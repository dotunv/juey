import 'package:flutter/material.dart';

class AppColors {
  // 🌞 Light Theme
  static const lightColorScheme = ColorScheme.light(
    primary: Color(0xFF7986CB),          // Soft indigo for focus
    primaryContainer: Color(0xFFE8EAF6), // Light lavender background
    secondary: Color(0xFF81C784),        // Soft green for AI freshness
    secondaryContainer: Color(0xFFE8F5E8),
    surface: Color(0xFFFFFFFF),
    error: Color(0xFFE53935),
    onPrimary: Color(0xFFFFFFFF),
    onSecondary: Color(0xFF00332A),
    onSurface: Color(0xFF1A1C1E),
    onError: Color(0xFFFFFFFF),
    brightness: Brightness.light,
  );

  // 🌙 Dark Theme
  static const darkColorScheme = ColorScheme.dark(
    primary: Color(0xFF9FA8DA),          // Soft blue
    primaryContainer: Color(0xFF303F9F), // Darker indigo
    secondary: Color(0xFF81C784),        // Soft green
    secondaryContainer: Color(0xFF1B5E20),
    surface: Color(0xFF121212),
    error: Color(0xFFEF5350),
    onPrimary: Color(0xFF0B132B),
    onSecondary: Color(0xFF00332A),
    onSurface: Color(0xFFE5E5E5),
    onError: Color(0xFF000000),
    brightness: Brightness.dark,
  );

  // 🔹 Semantic aliases (easier to use across features)
  static Color get success => const Color(0xFF22C55E); // green
  static Color get warning => const Color(0xFFF59E42); // orange
  static Color get info => const Color(0xFF38BDF8);    // sky blue
}
