import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppTheme {
  static final ValueNotifier<bool> isDarkMode = ValueNotifier<bool>(false);

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkMode.value = prefs.getBool('isDarkMode') ?? false;
  }

  static void toggleDarkMode() async {
    isDarkMode.value = !isDarkMode.value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode.value);
  }

  static bool get isDark => isDarkMode.value;

  // Background and Surfaces
  static Color get bg => isDark ? const Color(0xFF111317) : const Color(0xFFF9F9FF);
  static Color get cardBg => isDark ? const Color(0xFF1E2023) : Colors.white;
  
  // Typography
  static Color get textPrimary => isDark ? const Color(0xFFE2E2E6) : const Color(0xFF111C2D);
  static Color get textSecondary => isDark ? const Color(0xFFBDC9C6) : const Color(0xFF3D4947);
  
  // Containers & Highlights
  static Color get highlight => isDark ? const Color(0xFF333538) : const Color(0xFFDEE8FF);
  static Color get subtle => isDark ? const Color(0xFF282A2D) : const Color(0xFFF0F3FF);
  
  static Color get purpleHighlight => isDark ? const Color(0xFF543589) : const Color(0xFFEBDCFF);
  static Color get deepPurpleText => isDark ? const Color(0xFFC6A5FF) : const Color(0xFF260058);
  
  static MaterialColor get grey => isDark ? Colors.blueGrey : Colors.grey;
  
  // Semantic Colors
  static Color get error => isDark ? const Color(0xFFFFB4AB) : const Color(0xFFBA1A1A);
  static Color get primaryText => isDark ? const Color(0xFF8EF4E9) : const Color(0xFF005049);
  static Color get primaryContainer => isDark ? const Color(0xFF005049) : const Color(0xFF84F5E8);
  
  // Brand Colors (Toggling them for contrast in Dark Mode)
  static Color get primary => isDark ? const Color(0xFF71D7CD) : const Color(0xFF006A62);
  static Color get tertiary => isDark ? const Color(0xFF66D9CC) : const Color(0xFF26A69A);
  static Color get secondary => isDark ? const Color(0xFFD4BBFF) : const Color(0xFF6F48B2);
}
