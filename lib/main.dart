import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'Main_Screen.dart';


void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: AdminWeb(),
    ),
  );
}

class AdminWeb extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // Start with MainScreen
      theme: ThemeData(
        fontFamily: 'Krub-Regular',
      ),
      darkTheme: ThemeData.dark(),  // Dark mode theme
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light, // Toggle based on dark mode state
      routes: {
        '/': (context) => MainScreen(),  // Main screen
        // '/': (context) => Login(), // Login screen (Uncomment if needed)
      },
    );

  }
}