import 'package:flutter/material.dart';

ThemeData get darkTheme => ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.indigo,
        brightness: Brightness.dark,
        primary: Colors.indigoAccent,
        secondary: Colors.deepPurpleAccent,
        tertiary: Colors.tealAccent,
        surface: Color(0xFF1E1E1E),
        background: Color(0xFF121212),
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
