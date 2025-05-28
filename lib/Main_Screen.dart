import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'Dashboard_Screen.dart';
import 'User_ManagementTenant.dart';
import 'User_ManagementLandlord.dart';
import 'Properties_Management.dart';
import 'Analytics_Managenent.dart';
import 'Settings_Screen.dart';
import 'Sidebar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  VoidCallback? _refreshWebCallback;

  void _setRefreshCallback(VoidCallback callback) {
    _refreshWebCallback = callback;
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: !isLargeScreen
          ? AppBar(
        backgroundColor: const Color(0xFF4A758F),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      )
          : null,
      drawer: !isLargeScreen
          ? Drawer(
        child: Sidebar(
          currentRoute: GoRouterState.of(context).matchedLocation,
          parentContext: context,
          onWebRefresh: _refreshWebCallback,
        ),
      )
          : null,
      body: Row(
        children: [
          if (isLargeScreen)
            SizedBox(
              width: 250, // Fixed width for the sidebar
              child: Sidebar(
                currentRoute: GoRouterState.of(context).matchedLocation,
                parentContext: context,
                onWebRefresh: _refreshWebCallback,
              ),
            ),
          Expanded(
            child: _getCurrentContent(context),
          ),
        ],
      ),
    );
  }

  Widget _getCurrentContent(BuildContext context) {
    final route = GoRouterState.of(context).matchedLocation;

    switch (route) {
      case '/dashboard':
        return DashboardScreen();
      case '/users-tenant':
        return UserManagementTenant();
      case '/users-landlord':
        return UserManagementLandlord();
      case '/properties-management':
        return PropertiesManagementScreen();
      case '/analytics':
        return AnalyticsScreen();
      case '/settings':
        return SettingsScreen();
      default:
        return DashboardScreen();
    }
  }
}