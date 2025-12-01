import 'package:flutter/material.dart';

class AppTheme {
  // Light theme colors - Clean & Modern
  static const Color _lightBg = Color(0xFFFAFBFC);
  static const Color _lightSurface = Colors.white;
  static const Color _lightPrimary = Color(0xFF00B4DB);
  static const Color _lightAccent = Color(0xFFFF6B6B);

  // Dark theme colors - Deep & Modern
  static const Color _darkBg = Color(0xFF0F1419);
  static const Color _darkSurface = Color(0xFF1A1F2E);
  static const Color _darkPrimary = Color(0xFF00D9FF);
  static const Color _darkAccent = Color(0xFFFF6B6B);

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: _lightBg,
        colorScheme: const ColorScheme.light(
          primary: _lightPrimary,
          secondary: _lightAccent,
          surface: _lightSurface,
          background: _lightBg,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: _darkBg,
        colorScheme: const ColorScheme.dark(
          primary: _darkPrimary,
          secondary: _darkAccent,
          surface: _darkSurface,
          background: _darkBg,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
        ),
      );
}
