import 'package:flutter/material.dart';

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Color(0xFF4F768E),
  scaffoldBackgroundColor: Color(0xFF121212),
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xFF1F1F1F),
    foregroundColor: Colors.white,
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white70),
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: Color(0xFF4F768E),
    textTheme: ButtonTextTheme.primary,
  ),
  colorScheme: ColorScheme.dark(
    primary: Color(0xFF4F768E),
    secondary: Color(0xFF4F768E),
    background: Color(0xFF121212),
    surface: Color(0xFF1F1F1F),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onBackground: Colors.white,
    onSurface: Colors.white,
    error: Colors.red,
    onError: Colors.black,
  ),
);