import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login.dart';
import 'Dashboard_Screen.dart';
import 'User_ManagementTenant.dart';
import 'User_ManagementLandlord.dart';
import 'Properties_Management.dart';
import 'Analytics_Managenent.dart';
import 'Settings_Screen.dart';
import 'MainLayout.dart'; // contains Sidebar and layout
import 'dart:html' as html;



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('authToken');
  final isLoggedIn = token != null;

  runApp(AdminWeb(isLoggedIn: isLoggedIn));
}


class AdminWeb extends StatelessWidget {
  final bool isLoggedIn;

  const AdminWeb({super.key, required this.isLoggedIn});

  Future<bool> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken') != null;
  }



  @override
  Widget build(BuildContext context) {


    // Force hash URL on first load
    if (html.window.location.hash.isEmpty) {
      html.window.location.replace('${html.window.location.origin}/#/login');
    }

    return MaterialApp(
      title: 'Admin RentXpert',
      debugShowCheckedModeBanner: false,
      initialRoute: isLoggedIn ? '/dashboard' : '/login',
      onGenerateRoute: (settings) {
        // Define which pages should show the sidebar
        final sidebarRoutes = {
          '/dashboard':  DashboardScreen(),
          '/users-tenant':  UserManagementTenant(),
          '/users-landlord':  UserManagementLandlord(),
          '/properties-management':  PropertiesManagementScreen(),
          '/analytics':  AnalyticsScreen(),
          '/settings':  SettingsScreen(),
        };

        final isSidebarPage = sidebarRoutes.containsKey(settings.name);

        return MaterialPageRoute(
          builder: (context) => FutureBuilder<bool>(
            future: _checkLogin(),
            builder: (context, snapshot) {
              final loggedIn = snapshot.data ?? false;

              // ✅ Already logged in → show page (with or without sidebar)
              // In your route generator or MaterialApp.router configuration:
              if (loggedIn) {
                if (isSidebarPage) {
                  return MainLayout(
                    initialRoute: settings.name ?? '/dashboard',
                    showSidebar: true,
                  );
                } else {
                  return Login(); // fallback for non-sidebar routes
                }
              }

              // 🚫 Not logged in
              if (settings.name == '/login') {
                return  Login(); // show login normally
              } else {
                return  Login(); // redirect to login on any other page
              }
            },
          ),
        );
      },
    );
  }

}
