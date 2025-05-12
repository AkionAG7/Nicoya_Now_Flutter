import 'package:flutter/material.dart';

class AppTheme{
  static ThemeData get lightTheme{
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xff000000),
        primary: const Color(0xff000000),
        secondary: const Color(0xff000000),
        surface: const Color(0xffffffff),
        error: const Color(0xfff44336),
      ),

      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            
        ),
      ),
     
    );
  }
}