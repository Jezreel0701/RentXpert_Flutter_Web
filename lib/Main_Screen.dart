import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'Dashboard_Screen.dart';
import 'User_ManagementTenant.dart';
import 'User_ManagementLandlord.dart';
import 'Properties_Management.dart';
import 'Analytics_Managenent.dart';
import 'Settings_Screen.dart';
import 'Sidebar.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A758F),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        child: Sidebar(
          currentRoute: GoRouterState.of(context).matchedLocation,
          parentContext: context,
        ),
      ),
      body: _getCurrentContent(context),
    );
  }

  Widget _getCurrentContent(BuildContext context) {
    final route = GoRouterState.of(context).matchedLocation;

    switch (route) {
      case '/dashboard':
        return  DashboardScreen();
      case '/users-tenant':
        return  UserManagementTenant();
      case '/users-landlord':
        return  UserManagementLandlord();
      case '/properties-management':
        return  PropertiesManagementScreen();
      case '/analytics':
        return  AnalyticsScreen();
      case '/settings':
        return  SettingsScreen();
      default:
        return  DashboardScreen();
    }
  }
}