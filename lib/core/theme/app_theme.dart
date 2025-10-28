import 'package:flutter/material.dart';

class AppTheme {
  static final darkTheme = ThemeData.dark(useMaterial3: true).copyWith(
    scaffoldBackgroundColor: const Color(0xFF2A2728),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF8E6E53),
      secondary: Color(0xFF201D1E),
      surface: Color(0xFF2A2728),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(
        fontFamily: 'Poppins',
        color: Color(0xFFC0B7B1),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF201D1E),
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
        fontSize: 20,
        color: Color(0xFFC0B7B1),
      ),
    ),
  );
}

