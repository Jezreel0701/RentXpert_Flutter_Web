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
import 'Routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;
  final token = prefs.getString('authToken');
  final isLoggedIn = token != null;

  runApp(
    ChangeNotifierProvider(
      // Use the public initialize method instead of direct field access
      create: (context) => ThemeProvider()..initializeTheme(isDarkMode),
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

  String _getInitialRoute(bool isLoggedIn) {
    if (kIsWeb) {
      final currentHash = html.window.location.hash.replaceFirst('#', '');
      if (_isValidRoute(currentHash)) return currentHash;
      return isLoggedIn ? '/dashboard' : '/login';
    }
    return isLoggedIn ? '/dashboard' : '/login';
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final initialRoute = _getInitialRoute(isLoggedIn);

    if (kIsWeb && html.window.location.hash.isEmpty) {
      html.window.location.replace(
          '${html.window.location.origin}/#$initialRoute'
      );
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
      onGenerateRoute: (settings) => _generateRoute(settings),
    );
  }

  Route<dynamic> _generateRoute(RouteSettings settings) {
    final sidebarRoutes = {
      '/dashboard': DashboardScreen(),
      '/users-tenant': UserManagementTenant(),
      '/users-landlord': UserManagementLandlord(),
      '/properties-management': PropertiesManagementScreen(),
      '/analytics': AnalyticsScreen(),
      '/settings': SettingsScreen(),
    };

    return MaterialPageRoute(
      builder: (context) => FutureBuilder<bool>(
        future: _checkLogin(),
        builder: (context, snapshot) {
          final loggedIn = snapshot.data ?? false;
          final isSidebarPage = sidebarRoutes.containsKey(settings.name);

          if (!loggedIn) return Login();

          return _buildAuthenticatedUI(
            isSidebarPage: isSidebarPage,
            settings: settings,
            sidebarRoutes: sidebarRoutes,
          );
        },
      ),
    );
  }

  Widget _buildAuthenticatedUI({
    required bool isSidebarPage,
    required RouteSettings settings,
    required Map<String, Widget> sidebarRoutes,
  }) {
    if (isSidebarPage) {
      return Routes(
        initialRoute: settings.name ?? '/dashboard',
        showSidebar: true,
      );
    }
    return settings.name == '/' ? MainScreen() : Login();
  }
}