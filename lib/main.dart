import 'package:flutter/material.dart';
import 'Main_Screen.dart';
import 'login.dart';

void main() {
  runApp(AdminWeb());
}

class AdminWeb extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/', // Start with SplashScreen
        theme: ThemeData(
          fontFamily: 'Krub-Regular',
        ),
        routes: {
          //'/': (context) => MainScreen(), // Main screen
          '/': (context) => Login(), // Login screen
        }
    );
  }
}