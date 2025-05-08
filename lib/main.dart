import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;

import 'theme_provider.dart';
import 'Main_Screen.dart';
import 'login.dart';
import 'Dashboard_Screen.dart';
import 'User_ManagementTenant.dart';
import 'User_ManagementLandlord.dart';
import 'Properties_Management.dart';
import 'Analytics_Managenent.dart';
import 'Settings_Screen.dart';
import 'MainLayout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('authToken');
  final isLoggedIn = token != null;

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: AdminWeb(isLoggedIn: isLoggedIn),
    ),
  );
}

class AdminWeb extends StatelessWidget {
  final bool isLoggedIn;

  const AdminWeb({super.key, required this.isLoggedIn});

  Future<bool> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken') != null;
  }

  bool _isValidRoute(String route) {
    const validRoutes = {
      '/dashboard',
      '/users-tenant',
      '/users-landlord',
      '/properties-management',
      '/analytics',
      '/settings',
      '/login'
    };
    return validRoutes.contains(route);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final initialRoute = kIsWeb
        ? _isValidRoute(html.window.location.hash.replaceFirst('#', ''))
        ? html.window.location.hash.replaceFirst('#', '')
        : isLoggedIn ? '/dashboard' : '/login'
        : isLoggedIn ? '/dashboard' : '/login';

    // Force initial hash if empty
    if (kIsWeb && html.window.location.hash.isEmpty) {
      html.window.location.replace('${html.window.location.origin}/#$initialRoute');
    }

    return MaterialApp(
      title: 'Admin RentXpert',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Krub-Regular',
      ),
      darkTheme: ThemeData.dark(),
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: initialRoute,
      routes: {
        '/': (context) => MainScreen(),
      },
      onGenerateRoute: (settings) {
        final sidebarRoutes = {
          '/dashboard': DashboardScreen(),
          '/users-tenant': UserManagementTenant(),
          '/users-landlord': UserManagementLandlord(),
          '/properties-management': PropertiesManagementScreen(),
          '/analytics': AnalyticsScreen(),
          '/settings': SettingsScreen(),
        };

        final isSidebarPage = sidebarRoutes.containsKey(settings.name);

        return MaterialPageRoute(
          builder: (context) => FutureBuilder<bool>(
            future: _checkLogin(),
            builder: (context, snapshot) {
              final loggedIn = snapshot.data ?? false;

              if (loggedIn) {
                if (isSidebarPage) {
                  return MainLayout(
                    initialRoute: settings.name ?? '/dashboard',
                    showSidebar: true,
                  );
                } else if (settings.name == '/') {
                  return MainScreen();
                } else {
                  return Login(); // fallback for non-sidebar routes
                }
              }

              // Not logged in
              if (settings.name == '/login') {
                return Login();
              } else {
                return Login(); // redirect to login
              }
            },
          ),
        );
      },
    );
  }
}