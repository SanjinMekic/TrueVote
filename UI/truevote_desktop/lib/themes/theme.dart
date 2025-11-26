import 'package:flutter/material.dart';

ThemeData buildLightTheme(BuildContext context) {
  return ThemeData(
    scaffoldBackgroundColor: const Color(0xFFF2F6FF),
    cardColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.blueAccent,
      elevation: 8,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),
    colorScheme: ColorScheme.light(
      primary: Colors.blueAccent,
      secondary: Colors.lightBlueAccent,
      surface: Colors.white,
      background: const Color(0xFFF2F6FF),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.black87,
      onBackground: Colors.black87,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF2F6FF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      labelStyle: const TextStyle(color: Colors.blueAccent),
      prefixIconColor: Colors.blueAccent,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.blueAccent,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        elevation: 8,
      ),
    ),
  );
}