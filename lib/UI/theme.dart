import 'package:flutter/material.dart';
import 'package:hidaya_app/Utils/colors.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: AppColors.background,
  );
  final lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF2BAE66),          // Islamic mint green
    onPrimary: Colors.white,
    secondary: Color(0xFFD4AF37),        // Soft gold
    onSecondary: Colors.white,
    background: Color(0xFFF7F3E9),       // Warm sand background
    onBackground: Color(0xFF1F1F1F),     // Deep charcoal text
    surface: Color(0xFFFFFFFF),          // White cards
    onSurface: Color(0xFF2C2C2C),        // Soft black text
    surfaceVariant: Color(0xFFE9E6D9),   // Subtle beige for inputs
    onSurfaceVariant: Color(0xFF555555), // Secondary text
    error: Colors.red,
    onError: Colors.white,
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Colors.black,
  );

  final darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF3CCF78),          // Lighter emerald green
    onPrimary: Colors.black,
    secondary: Color(0xFFE0C15A),        // Softer gold for contrast
    onSecondary: Colors.black,
    background: Color(0xFF0D0D0D),       // Deep onyx background
    onBackground: Color(0xFFEDEDED),     // Snow white text
    surface: Color(0xFF1A1A1A),          // Dark cards
    onSurface: Color(0xFFE0E0E0),        // Light grey text
    surfaceVariant: Color(0xFF2A2A2A),   // Input/search field dark bg
    onSurfaceVariant: Color(0xFFB5B5B5), // Secondary text
    error: Colors.redAccent,
    onError: Colors.black,
  );

}