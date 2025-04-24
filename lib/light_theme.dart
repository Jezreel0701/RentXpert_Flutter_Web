import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Color(0xFF4F768E),
  scaffoldBackgroundColor: Color(0xFFF5F5F5),
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xFF4F768E),
    foregroundColor: Colors.white,
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: Colors.black87),
    bodyMedium: TextStyle(color: Colors.black54),
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: Color(0xFF4F768E),
    textTheme: ButtonTextTheme.primary,
  ),
  colorScheme: ColorScheme.light(
    primary: Color(0xFF4F768E),
    secondary: Color(0xFF4F768E),
    background: Color(0xFFF5F5F5),
    surface: Colors.white,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onBackground: Colors.black87,
    onSurface: Colors.black87,
    error: Colors.red,
    onError: Colors.white,
  ),
);