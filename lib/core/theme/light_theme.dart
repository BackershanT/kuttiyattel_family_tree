import 'package:flutter/material.dart';

ThemeData get lightTheme => ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.indigo,
        brightness: Brightness.light,
        primary: Colors.indigo,
        secondary: Colors.indigoAccent,
        tertiary: Colors.teal,
        surface: Colors.white,
        background: Colors.grey[100]!,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        
      ),
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(),
    );
